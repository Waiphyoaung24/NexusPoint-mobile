import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuspoint_pos/core/models/order.dart';
import 'package:nexuspoint_pos/core/models/cart_item.dart';
import 'package:nexuspoint_pos/core/models/menu_item.dart';
import 'package:nexuspoint_pos/features/orders/providers/order_provider.dart';
import 'package:nexuspoint_pos/features/orders/repositories/order_repository.dart';

// ---------------------------------------------------------------------------
// Fake OrderRepository that returns in-memory data (no Drift / DB needed)
// ---------------------------------------------------------------------------
class _FakeOrderRepository implements OrderRepository {
  final List<Order> _orders;

  _FakeOrderRepository(this._orders);

  @override
  Stream<List<Order>> watchAllOrders() => Stream.value(_orders);

  @override
  Future<List<Order>> getAllOrders() async => _orders;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Order _makeOrder({
  int localId = 1,
  String orderNumber = 'ORD-TEST-001',
  bool isSynced = false,
  OrderStatus status = OrderStatus.pending,
  PaymentMethod paymentMethod = PaymentMethod.cash,
}) {
  return Order(
    localId: localId,
    orderNumber: orderNumber,
    source: OrderSource.dinein,
    status: status,
    items: [
      CartItem(
        menuItem: const MenuItem(
          id: 'sku-1',
          sku: 'sku-1',
          organizationId: 'org-1',
          name: 'Pad Thai',
          price: 100.0,
        ),
        quantity: 2,
        unitPrice: 100.0,
      ),
    ],
    totalAmount: 200.0,
    paymentMethod: paymentMethod,
    createdAt: DateTime(2026, 2, 15, 12, 0),
    isSynced: isSynced,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  group('ordersProvider', () {
    test('emits empty list when no orders exist', () async {
      final repo = _FakeOrderRepository([]);

      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(ordersProvider.future);
      expect(result, isEmpty);
    });

    test('emits list of orders from repository', () async {
      final orders = [
        _makeOrder(localId: 1, orderNumber: 'ORD-001'),
        _makeOrder(localId: 2, orderNumber: 'ORD-002', isSynced: true),
      ];

      final repo = _FakeOrderRepository(orders);

      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(ordersProvider.future);
      expect(result.length, 2);
      expect(result[0].orderNumber, 'ORD-001');
      expect(result[1].orderNumber, 'ORD-002');
    });

    test('order sync status is preserved', () async {
      final orders = [
        _makeOrder(localId: 1, isSynced: false),
        _makeOrder(localId: 2, isSynced: true),
      ];

      final repo = _FakeOrderRepository(orders);

      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(ordersProvider.future);
      expect(result[0].isSynced, isFalse);
      expect(result[1].isSynced, isTrue);
    });

    test('order total amount is preserved', () async {
      final order = _makeOrder(localId: 1);
      final repo = _FakeOrderRepository([order]);

      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(ordersProvider.future);
      expect(result.first.totalAmount, 200.0);
    });

    test('order items are accessible', () async {
      final order = _makeOrder(localId: 1);
      final repo = _FakeOrderRepository([order]);

      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(ordersProvider.future);
      expect(result.first.items.length, 1);
      expect(result.first.items.first.menuItem.name, 'Pad Thai');
      expect(result.first.items.first.quantity, 2);
    });
  });
}
