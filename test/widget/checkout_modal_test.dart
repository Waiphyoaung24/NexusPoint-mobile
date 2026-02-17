import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuspoint_pos/core/models/order.dart';
import 'package:nexuspoint_pos/features/checkout/providers/checkout_provider.dart';

void main() {
  group('CheckoutProvider integration', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('cash flow: set total → set tendered → verify change', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.setOrderTotal(321.0);
      notifier.selectPaymentMethod(PaymentMethod.cash);
      notifier.setTenderedAmount(500.0);

      final state = container.read(checkoutProvider);
      expect(state.changeAmount, closeTo(179.0, 0.01));
      expect(state.canSubmit, true);
    });

    test('promptpay flow: set total → select promptpay → canSubmit', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.setOrderTotal(321.0);
      notifier.selectPaymentMethod(PaymentMethod.promptpay);

      final state = container.read(checkoutProvider);
      expect(state.canSubmit, true);
    });

    test('switching payment method clears tendered amount', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.setOrderTotal(200.0);
      notifier.setTenderedAmount(300.0);
      notifier.selectPaymentMethod(PaymentMethod.promptpay);

      final state = container.read(checkoutProvider);
      expect(state.tenderedAmount, isNull);
    });

    test('processing state disables submit', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.setOrderTotal(100.0);
      notifier.selectPaymentMethod(PaymentMethod.promptpay);
      notifier.setProcessing();

      final state = container.read(checkoutProvider);
      expect(state.canSubmit, false);
    });

    test('success state records order number', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.setSuccess('ORD-20260217-143000');

      final state = container.read(checkoutProvider);
      expect(state.status, CheckoutStatus.success);
      expect(state.orderNumber, 'ORD-20260217-143000');
    });

    test('error state records message', () {
      final notifier = container.read(checkoutProvider.notifier);
      notifier.setError('Network error');

      final state = container.read(checkoutProvider);
      expect(state.status, CheckoutStatus.error);
      expect(state.errorMessage, 'Network error');
    });
  });
}
