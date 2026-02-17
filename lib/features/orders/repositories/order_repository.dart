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
        tenantId: user.tenantId!,
        branchId: 'default', // TODO: Get from settings
        // Map Flutter enum to backend DB enum value (dinein → pos)
        source: source.backendValue,
        items: items,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod.name,
        tableNumber: tableNumber,
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

  Future<void> updateStatus(int localId, OrderStatus newStatus) async {
    await _localDb.updateOrder(
      localId,
      OrdersCompanion(status: drift.Value(newStatus.name)),
    );
  }

  /// Marks an order as delivered locally and syncs to cloud only if the
  /// order was previously synced (has a server orderId). Never creates a
  /// new remote record.
  Future<void> markDelivered(int localId, {String? serverId}) async {
    // 1. Update local DB first (offline-safe)
    await _localDb.updateOrder(
      localId,
      OrdersCompanion(status: drift.Value(OrderStatus.delivered.name)),
    );

    // 2. Push status to cloud only if already synced
    if (serverId != null && serverId.isNotEmpty) {
      try {
        await _api.updateOrderStatus(
          orderId: serverId,
          status: OrderStatus.delivered.name,
        );
        debugPrint('✅ Order $serverId marked delivered on cloud');
      } catch (e) {
        // Non-fatal — local state is already updated
        debugPrint('⚠️ Could not sync delivered status to cloud: $e');
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

      for (final r in remote) {
        // Try to find an existing local order by server ID
        final localOrders = await _localDb.getAllOrders();
        final existing = localOrders
            .where((o) => o.orderId == r.orderId)
            .toList();

        if (existing.isEmpty) {
          // Insert cloud order as a synced local record
          await _localDb.insertOrder(
            OrdersCompanion(
              orderNumber: drift.Value(r.orderNumber ?? r.orderId),
              orderId: drift.Value(r.orderId),
              source: drift.Value(OrderSource.dinein.name), // default
              status: drift.Value(
                OrderStatusBackend.fromBackend(r.status).name,
              ),
              totalAmount: drift.Value(r.totalAmount),
              paymentMethod: const drift.Value('cash'),
              itemsJson: const drift.Value('[]'),
              createdAt: drift.Value(r.createdAt),
              isSynced: const drift.Value(true),
              syncedAt: drift.Value(DateTime.now()),
            ),
          );
        }
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        // Backend order.list procedure not implemented yet — skip silently
        debugPrint(
          '⚠️ order.list not found on backend (404). '
          'Using local orders only.',
        );
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
