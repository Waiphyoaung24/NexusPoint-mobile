import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/features/cart/providers/cart_provider.dart';

void main() {
  group('VAT calculation', () {
    test('default vatRate is 7%', () {
      const state = CartState();
      expect(state.vatRate, 0.07);
    });

    test('VAT is 7% of subtotal (default rate)', () {
      const subtotal = 310.0;
      const state = CartState(vatRate: 0.07);
      final vat = subtotal * state.vatRate;
      expect(vat, closeTo(21.7, 0.01));
      expect(subtotal + vat, closeTo(331.7, 0.01));
    });

    test('zero subtotal yields zero VAT', () {
      const state = CartState(vatRate: 0.07);
      final vat = 0.0 * state.vatRate;
      expect(vat, 0.0);
    });

    test('large order VAT calculation', () {
      const subtotal = 5000.0;
      const state = CartState(vatRate: 0.07);
      final vat = subtotal * state.vatRate;
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

    test('custom VAT rate 10%', () {
      const subtotal = 1000.0;
      const state = CartState(vatRate: 0.10);
      final vat = subtotal * state.vatRate;
      expect(vat, closeTo(100.0, 0.01));
      expect(subtotal + vat, closeTo(1100.0, 0.01));
    });

    test('custom VAT rate 0% (no VAT)', () {
      const subtotal = 500.0;
      const state = CartState(vatRate: 0.0);
      final vat = subtotal * state.vatRate;
      expect(vat, 0.0);
      expect(subtotal + vat, 500.0);
    });

    test('custom VAT rate 15%', () {
      const subtotal = 200.0;
      const state = CartState(vatRate: 0.15);
      final vat = subtotal * state.vatRate;
      expect(vat, closeTo(30.0, 0.01));
      expect(subtotal + vat, closeTo(230.0, 0.01));
    });

    test('vatRate is preserved in CartState', () {
      const state = CartState(
        items: [],
        subtotal: 100.0,
        tax: 10.0,
        total: 110.0,
        vatRate: 0.10,
      );
      expect(state.vatRate, 0.10);
    });
  });
}
