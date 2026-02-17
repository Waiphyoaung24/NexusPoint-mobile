import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuspoint_pos/core/models/menu_item.dart';
import 'package:nexuspoint_pos/features/cart/providers/cart_provider.dart';

void main() {
  group('Cart Panel in SpeedRegister', () {
    testWidgets('displays cart item name and quantity', (tester) async {
      final container = ProviderContainer();

      // Add item to cart
      container.read(cartProvider.notifier).addItem(
        const MenuItem(
          id: 'item-1',
          sku: 'SKU-001',
          organizationId: 'org-1',
          name: 'Pad Thai',
          price: 120.0,
        ),
        quantity: 2,
      );

      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.menuItem.name, 'Pad Thai');
      expect(cart.items.first.quantity, 2);

      container.dispose();
    });

    test('cart summary shows subtotal, tax, and total', () {
      final container = ProviderContainer();

      container.read(cartProvider.notifier).addItem(
        const MenuItem(
          id: 'item-1',
          sku: 'SKU-001',
          organizationId: 'org-1',
          name: 'Pad Thai',
          price: 100.0,
        ),
        quantity: 3,
      );

      final cart = container.read(cartProvider);
      expect(cart.subtotal, 300.0);
      expect(cart.tax, closeTo(21.0, 0.01));
      expect(cart.total, closeTo(321.0, 0.01));

      container.dispose();
    });

    test('clear cart resets everything', () {
      final container = ProviderContainer();

      container.read(cartProvider.notifier).addItem(
        const MenuItem(
          id: 'item-1',
          sku: 'SKU-001',
          organizationId: 'org-1',
          name: 'Pad Thai',
          price: 100.0,
        ),
      );
      container.read(cartProvider.notifier).clear();

      final cart = container.read(cartProvider);
      expect(cart.items, isEmpty);
      expect(cart.total, 0.0);

      container.dispose();
    });
  });
}
