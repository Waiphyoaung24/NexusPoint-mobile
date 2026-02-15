import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuspoint_pos/core/models/menu_item.dart';
import 'package:nexuspoint_pos/features/cart/providers/cart_provider.dart';

void main() {
  group('CartProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty', () {
      final cart = container.read(cartProvider);
      expect(cart.items, isEmpty);
      expect(cart.total, 0.0);
    });

    test('addItem adds item to cart', () {
      const item = MenuItem(
        id: '1',
        sku: 'sku-pad-thai',
        organizationId: 'org-1',
        name: 'Pad Thai',
        price: 120.0,
      );

      container.read(cartProvider.notifier).addItem(item);

      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.menuItem.name, 'Pad Thai');
      expect(cart.items.first.quantity, 1);
    });

    test('addItem with same item increases quantity', () {
      const item = MenuItem(
        id: '1',
        sku: 'sku-pad-thai',
        organizationId: 'org-1',
        name: 'Pad Thai',
        price: 120.0,
      );

      container.read(cartProvider.notifier).addItem(item);
      container.read(cartProvider.notifier).addItem(item);

      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 2);
    });

    test('total calculates correctly with tax', () {
      const item = MenuItem(
        id: '1',
        sku: 'sku-pad-thai',
        organizationId: 'org-1',
        name: 'Pad Thai',
        price: 100.0,
      );

      container.read(cartProvider.notifier).addItem(item, quantity: 2);

      final cart = container.read(cartProvider);
      expect(cart.subtotal, 200.0);
      expect(cart.tax, closeTo(14.0, 0.01)); // 7% of 200
      expect(cart.total, closeTo(214.0, 0.01));
    });
  });
}
