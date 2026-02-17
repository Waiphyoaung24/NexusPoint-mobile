import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/models/order.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/api_models.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/order_dao.dart';
import '../../../core/database/daos/sync_queue_dao.dart';
import '../../../core/api/api_service.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../auth/providers/auth_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(
    ref.read(posApiServiceProvider),
    ref.read(appDatabaseProvider).orderDao,
    ref.read(appDatabaseProvider).syncQueueDao,
    ref,
  );
});

class OrderRepository {
  // ignore: unused_field
  final PosApiService _api; // TODO: Will be used in background sync service
  final OrderDao _localDb;
  final SyncQueueDao _syncQueue;
  final Ref _ref;

  OrderRepository(this._api, this._localDb, this._syncQueue, this._ref);

  Future<Order> createOrder({
    required OrderSource source,
    required List<OrderItemDto> items,
    required double totalAmount,
    required PaymentMethod paymentMethod,
    String? tableNumber,
  }) async {
    final authState = _ref.read(authProvider);
    if (authState is! Authenticated) {
      throw Exception('User not authenticated');
    }

    final user = authState.user;
    if (user.tenantId == null) {
      throw Exception('User tenant ID is required');
    }

    final orderNumber = _generateOrderNumber();

    // PHASE 1: Local write (always succeeds)
    final localOrder = await _localDb.insertOrder(
      OrdersCompanion(
        orderNumber: drift.Value(orderNumber),
        source: drift.Value(source.name),
        status: drift.Value(OrderStatus.pending.name),
        totalAmount: drift.Value(totalAmount),
        paymentMethod: drift.Value(paymentMethod.name),
        itemsJson: drift.Value(jsonEncode(items.map((e) => e.toJson()).toList())),
        tableNumber: drift.Value(tableNumber),
        createdAt: drift.Value(DateTime.now()),
        isSynced: const drift.Value(false),
      ),
    );

    // PHASE 2: Attempt server sync (if online)
    // For MVP, we'll implement sync in background service
    // Queue for sync
    await _syncQueue.enqueue(
      entityType: 'order',
      entityId: localOrder.id,
      action: 'create',
      payloadJson: jsonEncode(OrderRequest(
        branchId: user.branchId ?? user.tenantId!,
        // Map Flutter enum to backend DB enum value (dinein → pos)
        source: source.backendValue,
        items: items
            .map(BackendOrderItemDto.fromOrderItemDto)
            .toList(),
        subtotal: totalAmount.toStringAsFixed(2),
        total: totalAmount.toStringAsFixed(2),
      ).toJson()),
      priority: 1,
    );

    return _localToModel(localOrder, items);
  }

  Future<List<Order>> getAllOrders() async {
    final localOrders = await _localDb.getAllOrders();
    return localOrders.map((local) {
      final items = (jsonDecode(local.itemsJson) as List)
          .map((e) => OrderItemDto.fromJson(e))
          .toList();
      return _localToModel(local, items);
    }).toList();
  }

  /// Updates order status locally and pushes to cloud if synced.
  /// Looks up the serverId from local DB — works on any device.
  Future<void> updateStatus(int localId, OrderStatus newStatus) async {
    await _localDb.updateOrder(
      localId,
      OrdersCompanion(status: drift.Value(newStatus.name)),
    );

    final local = await _localDb.getOrderById(localId);
    final serverId = local?.orderId;
    if (local != null && local.isSynced && serverId != null && serverId.isNotEmpty) {
      try {
        await _api.updateOrderStatus(orderId: serverId, status: newStatus.backendValue);
        debugPrint('✅ Order $serverId status → ${newStatus.backendValue}');
      } catch (e) {
        debugPrint('⚠️ Could not push status to cloud: $e');
      }
    }
  }

  /// Fetches orders from the cloud API and merges them into local DB.
  /// Returns the merged list. Silently returns local orders if cloud is
  /// unavailable (network error) or the procedure isn't implemented yet (404).
  Future<List<Order>> fetchAndMergeFromCloud({
    required String tenantId,
    required String branchId,
  }) async {
    try {
      final remote = await _api.getOrders(
        tenantId: tenantId,
        branchId: branchId,
      );

      // Load all local orders once (avoid O(n²) per-item queries)
      final localOrders = await _localDb.getAllOrders();
      final localByServerId = {
        for (final o in localOrders)
          if (o.orderId != null) o.orderId!: o,
      };

      for (final r in remote) {
        final existing = localByServerId[r.orderId];
        final serverStatus = OrderStatusBackend.fromBackend(r.status).name;

        if (existing == null) {
          // Convert backend items to local OrderItemDto format for storage
          final localItems = r.items.map((bi) => OrderItemDto(
            skuId: bi.menuItemId,
            name: bi.name,
            quantity: bi.quantity,
            unitPrice: double.tryParse(bi.price) ?? 0.0,
            notes: bi.notes,
          )).toList();

          // Map backend source value to Flutter enum
          final sourceEnum = OrderSourceBackend.fromBackend(r.source);

          // New order from another device — insert locally as synced
          final orderNum = (r.orderNumber != null && r.orderNumber!.isNotEmpty)
              ? r.orderNumber!
              : r.orderId;
          await _localDb.insertOrder(
            OrdersCompanion(
              orderNumber: drift.Value(orderNum),
              orderId: drift.Value(r.orderId),
              source: drift.Value(sourceEnum.name),
              status: drift.Value(serverStatus),
              totalAmount: drift.Value(r.totalAmount),
              paymentMethod: const drift.Value('cash'),
              itemsJson: drift.Value(jsonEncode(localItems.map((e) => e.toJson()).toList())),
              createdAt: drift.Value(r.createdAt),
              isSynced: const drift.Value(true),
              syncedAt: drift.Value(DateTime.now()),
            ),
          );
        } else {
          final needsStatusUpdate = existing.status != serverStatus;
          final hasEmptyItems = existing.itemsJson == '[]' || existing.itemsJson.isEmpty;
          final needsItemsUpdate = hasEmptyItems && r.items.isNotEmpty;

          if (needsStatusUpdate || needsItemsUpdate) {
            var companion = OrdersCompanion(
              status: drift.Value(serverStatus),
            );

            if (needsItemsUpdate) {
              final localItems = r.items.map((bi) => OrderItemDto(
                skuId: bi.menuItemId,
                name: bi.name,
                quantity: bi.quantity,
                unitPrice: double.tryParse(bi.price) ?? 0.0,
                notes: bi.notes,
              )).toList();
              companion = OrdersCompanion(
                status: drift.Value(serverStatus),
                itemsJson: drift.Value(jsonEncode(localItems.map((e) => e.toJson()).toList())),
                totalAmount: drift.Value(r.totalAmount),
              );
            }

            await _localDb.updateOrder(existing.id, companion);
          }
        }
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        // Backend order.list not yet implemented — skip silently
        debugPrint('⚠️ order.list not found on backend (404). Using local orders only.');
      } else {
        debugPrint('⚠️ Cloud fetch failed: $e');
      }
    } catch (e) {
      debugPrint('⚠️ Cloud fetch failed: $e');
    }

    return getAllOrders();
  }

  Stream<List<Order>> watchAllOrders() {
    return _localDb.watchAllOrders().map((localOrders) {
      return localOrders.map((local) {
        final items = (jsonDecode(local.itemsJson) as List)
            .map((e) => OrderItemDto.fromJson(e))
            .toList();
        return _localToModel(local, items);
      }).toList();
    });
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final timeStr = DateFormat('HHmmss').format(now);
    return 'ORD-$dateStr-$timeStr';
  }

  Order _localToModel(LocalOrder local, List<OrderItemDto> items) {
    // Convert DTOs back to CartItems for display
    final cartItems = items.map((dto) {
      return CartItem(
        menuItem: MenuItem(
          id: dto.skuId,
          sku: dto.skuId,
          organizationId: '',
          name: dto.name ?? dto.skuId,
          price: dto.unitPrice,
        ),
        quantity: dto.quantity,
        unitPrice: dto.unitPrice,
        notes: dto.notes,
      );
    }).toList();

    return Order(
      localId: local.id,
      orderId: local.orderId,
      orderNumber: local.orderNumber,
      source: OrderSource.values.firstWhere((e) => e.name == local.source),
      status: OrderStatus.values.firstWhere((e) => e.name == local.status),
      items: cartItems,
      totalAmount: local.totalAmount,
      paymentMethod: PaymentMethod.values.firstWhere((e) => e.name == local.paymentMethod),
      createdAt: local.createdAt,
      syncedAt: local.syncedAt,
      isSynced: local.isSynced,
      tableNumber: local.tableNumber,
    );
  }
}
