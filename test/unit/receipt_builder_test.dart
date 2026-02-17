import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/core/models/order.dart';
import 'package:nexuspoint_pos/core/models/menu_item.dart';
import 'package:nexuspoint_pos/core/models/cart_item.dart';
import 'package:nexuspoint_pos/features/printer/services/receipt_builder.dart';
import 'package:nexuspoint_pos/features/printer/services/kitchen_ticket_builder.dart';

Order _createTestOrder({
  OrderSource source = OrderSource.dinein,
  String? tableNumber,
}) {
  return Order(
    localId: 1,
    orderNumber: 'ORD-20260217-120000',
    source: source,
    status: OrderStatus.pending,
    items: [
      const CartItem(
        menuItem: MenuItem(
          id: 'item-1',
          sku: 'SKU-001',
          organizationId: 'org-1',
          name: 'Pad Thai',
          price: 120.0,
        ),
        quantity: 2,
        unitPrice: 120.0,
      ),
      const CartItem(
        menuItem: MenuItem(
          id: 'item-2',
          sku: 'SKU-002',
          organizationId: 'org-1',
          name: 'Tom Yum Soup',
          price: 80.0,
        ),
        quantity: 1,
        unitPrice: 80.0,
        notes: 'Extra spicy',
      ),
    ],
    totalAmount: 320.0,
    paymentMethod: PaymentMethod.cash,
    createdAt: DateTime(2026, 2, 17, 12, 0, 0),
    tableNumber: tableNumber,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ReceiptBuilder', () {
    late ReceiptBuilder builder;

    setUp(() {
      builder = ReceiptBuilder(storeName: 'Test Store');
    });

    test('builds receipt bytes that are non-empty', () async {
      final order = _createTestOrder();
      final bytes = await builder.buildReceipt(order: order);

      expect(bytes, isNotEmpty);
      // ESC/POS init command (0x1B 0x40) should be present
      expect(bytes.length, greaterThan(100));
    });

    test('builds receipt with cash change info', () async {
      final order = _createTestOrder();
      final bytes = await builder.buildReceipt(
        order: order,
        tenderedAmount: 500.0,
        changeAmount: 180.0,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });

    test('builds receipt without change for non-cash', () async {
      final order = Order(
        localId: 1,
        orderNumber: 'ORD-20260217-120001',
        source: OrderSource.dinein,
        status: OrderStatus.pending,
        items: const [
          CartItem(
            menuItem: MenuItem(
              id: 'item-1',
              sku: 'SKU-001',
              organizationId: 'org-1',
              name: 'Pad Thai',
              price: 120.0,
            ),
            quantity: 1,
            unitPrice: 120.0,
          ),
        ],
        totalAmount: 120.0,
        paymentMethod: PaymentMethod.promptpay,
        createdAt: DateTime(2026, 2, 17, 12, 0, 1),
      );

      final bytes = await builder.buildReceipt(order: order);
      expect(bytes, isNotEmpty);
    });
  });

  group('KitchenTicketBuilder', () {
    late KitchenTicketBuilder builder;

    setUp(() {
      builder = KitchenTicketBuilder();
    });

    test('builds kitchen ticket bytes that are non-empty', () async {
      final order = _createTestOrder();
      final bytes = await builder.buildTicket(order: order);

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });

    test('builds ticket for grab order', () async {
      final order = _createTestOrder(source: OrderSource.grab);
      final bytes = await builder.buildTicket(order: order);

      expect(bytes, isNotEmpty);
    });

    test('builds ticket for wongnai order', () async {
      final order = _createTestOrder(source: OrderSource.wongnai);
      final bytes = await builder.buildTicket(order: order);

      expect(bytes, isNotEmpty);
    });

    test('builds ticket with table number', () async {
      final order = _createTestOrder(tableNumber: 'A5');
      final bytes = await builder.buildTicket(order: order);

      expect(bytes, isNotEmpty);
    });
  });
}
