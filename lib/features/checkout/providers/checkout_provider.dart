import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order.dart';

enum CheckoutStatus { idle, processing, success, error }

class CheckoutState {
  final CheckoutStatus status;
  final PaymentMethod paymentMethod;
  final double orderTotal;
  final double? tenderedAmount;
  final double changeAmount;
  final String? errorMessage;
  final String? orderNumber;

  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.paymentMethod = PaymentMethod.cash,
    this.orderTotal = 0.0,
    this.tenderedAmount,
    this.changeAmount = 0.0,
    this.errorMessage,
    this.orderNumber,
  });

  bool get canSubmit {
    if (status == CheckoutStatus.processing) return false;
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return tenderedAmount != null && tenderedAmount! >= orderTotal;
      case PaymentMethod.promptpay:
        return orderTotal > 0;
      case PaymentMethod.card:
        return orderTotal > 0;
    }
  }

  CheckoutState copyWith({
    CheckoutStatus? status,
    PaymentMethod? paymentMethod,
    double? orderTotal,
    double? tenderedAmount,
    bool clearTendered = false,
    double? changeAmount,
    String? errorMessage,
    bool clearError = false,
    String? orderNumber,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderTotal: orderTotal ?? this.orderTotal,
      tenderedAmount: clearTendered ? null : (tenderedAmount ?? this.tenderedAmount),
      changeAmount: changeAmount ?? this.changeAmount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      orderNumber: orderNumber ?? this.orderNumber,
    );
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier();
});

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(const CheckoutState());

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(
      paymentMethod: method,
      clearTendered: true,
      changeAmount: 0.0,
    );
  }

  void setOrderTotal(double total) {
    state = state.copyWith(orderTotal: total);
  }

  void setTenderedAmount(double amount) {
    final change = amount - state.orderTotal;
    state = state.copyWith(
      tenderedAmount: amount,
      changeAmount: change,
    );
  }

  List<double> quickCashSuggestions() {
    final total = state.orderTotal;
    if (total <= 0) return [100, 500, 1000];

    // Return all common bills that cover the total
    final bills = [100.0, 200.0, 500.0, 1000.0];
    final covering = bills.where((b) => b >= total).toList();
    if (covering.isEmpty) return [1000.0, 2000.0, 5000.0];
    return covering;
  }

  void setProcessing() {
    state = state.copyWith(status: CheckoutStatus.processing, clearError: true);
  }

  void setSuccess(String orderNumber) {
    state = state.copyWith(
      status: CheckoutStatus.success,
      orderNumber: orderNumber,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      status: CheckoutStatus.error,
      errorMessage: message,
    );
  }

  void reset() {
    state = const CheckoutState();
  }
}
