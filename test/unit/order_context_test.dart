import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/features/orders/providers/order_context_provider.dart';

void main() {
  group('OrderContext', () {
    test('dine-in context holds tableId and tableNumber', () {
      const ctx = OrderContext(
        orderType: OrderType.dineIn,
        tableId: 'uuid-123',
        tableNumber: 5,
      );

      expect(ctx.orderType, OrderType.dineIn);
      expect(ctx.tableId, 'uuid-123');
      expect(ctx.tableNumber, 5);
      expect(ctx.ticketNumber, isNull);
      expect(ctx.deliveryPlatform, isNull);
    });

    test('takeaway context holds ticketNumber', () {
      const ctx = OrderContext(
        orderType: OrderType.takeaway,
        ticketNumber: 'T-001',
      );

      expect(ctx.orderType, OrderType.takeaway);
      expect(ctx.ticketNumber, 'T-001');
      expect(ctx.tableId, isNull);
      expect(ctx.tableNumber, isNull);
    });

    test('delivery context holds deliveryPlatform', () {
      const ctx = OrderContext(
        orderType: OrderType.delivery,
        deliveryPlatform: 'grab',
      );

      expect(ctx.orderType, OrderType.delivery);
      expect(ctx.deliveryPlatform, 'grab');
      expect(ctx.tableId, isNull);
    });

    test('equality works via freezed', () {
      const a = OrderContext(
        orderType: OrderType.dineIn,
        tableId: 'abc',
        tableNumber: 3,
      );
      const b = OrderContext(
        orderType: OrderType.dineIn,
        tableId: 'abc',
        tableNumber: 3,
      );

      expect(a, equals(b));
    });

    test('copyWith updates fields', () {
      const original = OrderContext(
        orderType: OrderType.takeaway,
        ticketNumber: 'T-001',
      );

      final updated = original.copyWith(ticketNumber: 'T-002');

      expect(updated.ticketNumber, 'T-002');
      expect(updated.orderType, OrderType.takeaway);
    });
  });

  group('OrderType enum', () {
    test('has three values', () {
      expect(OrderType.values, hasLength(3));
      expect(OrderType.values, contains(OrderType.dineIn));
      expect(OrderType.values, contains(OrderType.takeaway));
      expect(OrderType.values, contains(OrderType.delivery));
    });
  });
}
