import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuspoint_pos/core/models/order.dart';
import 'package:nexuspoint_pos/features/checkout/providers/checkout_provider.dart';

void main() {
  group('CheckoutProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is idle', () {
      final state = container.read(checkoutProvider);
      expect(state.status, CheckoutStatus.idle);
      expect(state.paymentMethod, PaymentMethod.cash);
      expect(state.tenderedAmount, isNull);
      expect(state.changeAmount, 0.0);
    });

    test('selectPaymentMethod updates method', () {
      container.read(checkoutProvider.notifier).selectPaymentMethod(PaymentMethod.promptpay);
      final state = container.read(checkoutProvider);
      expect(state.paymentMethod, PaymentMethod.promptpay);
    });

    test('setTenderedAmount calculates change for cash', () {
      container.read(checkoutProvider.notifier).selectPaymentMethod(PaymentMethod.cash);
      container.read(checkoutProvider.notifier).setOrderTotal(214.0);
      container.read(checkoutProvider.notifier).setTenderedAmount(300.0);

      final state = container.read(checkoutProvider);
      expect(state.tenderedAmount, 300.0);
      expect(state.changeAmount, closeTo(86.0, 0.01));
    });

    test('insufficient cash shows negative change', () {
      container.read(checkoutProvider.notifier).setOrderTotal(214.0);
      container.read(checkoutProvider.notifier).setTenderedAmount(100.0);

      final state = container.read(checkoutProvider);
      expect(state.changeAmount, closeTo(-114.0, 0.01));
      expect(state.canSubmit, false);
    });

    test('exact cash shows zero change and canSubmit', () {
      container.read(checkoutProvider.notifier).setOrderTotal(214.0);
      container.read(checkoutProvider.notifier).setTenderedAmount(214.0);

      final state = container.read(checkoutProvider);
      expect(state.changeAmount, closeTo(0.0, 0.01));
      expect(state.canSubmit, true);
    });

    test('promptpay always canSubmit', () {
      container.read(checkoutProvider.notifier).selectPaymentMethod(PaymentMethod.promptpay);
      container.read(checkoutProvider.notifier).setOrderTotal(214.0);

      final state = container.read(checkoutProvider);
      expect(state.canSubmit, true);
    });

    test('reset clears all state', () {
      container.read(checkoutProvider.notifier).selectPaymentMethod(PaymentMethod.promptpay);
      container.read(checkoutProvider.notifier).setOrderTotal(500.0);
      container.read(checkoutProvider.notifier).reset();

      final state = container.read(checkoutProvider);
      expect(state.status, CheckoutStatus.idle);
      expect(state.paymentMethod, PaymentMethod.cash);
      expect(state.orderTotal, 0.0);
    });

    test('quick cash buttons work correctly', () {
      container.read(checkoutProvider.notifier).setOrderTotal(85.0);

      // Test rounding up to nearest 100
      final suggestions = container.read(checkoutProvider.notifier).quickCashSuggestions();
      expect(suggestions, contains(100.0));
      expect(suggestions, contains(200.0));
      expect(suggestions, contains(500.0));
      expect(suggestions, contains(1000.0));
    });
  });
}
