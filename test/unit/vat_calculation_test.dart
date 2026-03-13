import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/features/cart/providers/cart_provider.dart';

void main() {
  group('VAT calculation', () {
    test('taxRate is 7%', () {
      expect(CartState.taxRate, 0.07);
    });

    test('VAT is 7% of subtotal', () {
      const subtotal = 310.0;
      final vat = subtotal * CartState.taxRate;
      expect(vat, closeTo(21.7, 0.01));
      expect(subtotal + vat, closeTo(331.7, 0.01));
    });

    test('zero subtotal yields zero VAT', () {
      final vat = 0.0 * CartState.taxRate;
      expect(vat, 0.0);
    });

    test('large order VAT calculation', () {
      const subtotal = 5000.0;
      final vat = subtotal * CartState.taxRate;
      expect(vat, closeTo(350.0, 0.01));
      expect(subtotal + vat, closeTo(5350.0, 0.01));
    });

    test('CartState aliases taxAmount and grandTotal', () {
      const state = CartState(
        items: [],
        subtotal: 100.0,
        tax: 7.0,
        total: 107.0,
      );

      expect(state.taxAmount, 7.0);
      expect(state.grandTotal, 107.0);
    });
  });
}
