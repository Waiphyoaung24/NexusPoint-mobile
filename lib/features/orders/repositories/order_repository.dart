import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';

import '../../../core/models/order.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/api_models.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/order_dao.dart';
import '../../../core/database/daos/sync_queue_dao.dart';
import '../../../core/api/api_service.dart';
import '../../../core/providers/dio_provider.dart';
import '../../menu/repositories/menu_repository.dart';
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
  final PosApiService _api;
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
        tenantId: user.tenantId,
        branchId: 'default', // TODO: Get from settings
        source: source.name,
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
    // In real app, we'd need to fetch MenuItem details
    final cartItems = items.map((dto) {
      // Simplified - in production, fetch from menu cache
      return CartItem(
        menuItem: MenuItem(
          id: dto.skuId,
          tenantId: 'tenant-1',
          name: 'Item ${dto.skuId}',
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
