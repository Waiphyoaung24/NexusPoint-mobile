import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order.dart';

enum CheckoutStatus { idle, processing, success, error }

/// A single payment entry in a split payment.
class PaymentEntry {
  final PaymentMethod method;
  final double amount;

  const PaymentEntry({required this.method, required this.amount});

  Map<String, String> toJson() => {
        'method': method.name,
        'amount': amount.toStringAsFixed(2),
      };
}

class CheckoutState {
  final CheckoutStatus status;
  final PaymentMethod paymentMethod;
  final double orderTotal;
  final double? tenderedAmount;
  final double changeAmount;
  final String? errorMessage;
  final String? orderNumber;
  // F-006: Split payment support
  final bool isSplit;
  final List<PaymentEntry> payments;

  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.paymentMethod = PaymentMethod.cash,
    this.orderTotal = 0.0,
    this.tenderedAmount,
    this.changeAmount = 0.0,
    this.errorMessage,
    this.orderNumber,
    this.isSplit = false,
    this.payments = const [],
  });

  /// Remaining balance after non-cash split payments.
  double get remainingBalance {
    if (!isSplit || payments.isEmpty) return orderTotal;
    final paid = payments.fold(0.0, (sum, p) => sum + p.amount);
    return (orderTotal - paid).clamp(0.0, orderTotal);
  }

  /// Whether the full amount is covered.
  bool get isFullyPaid {
    if (isSplit) {
      final paid = payments.fold(0.0, (sum, p) => sum + p.amount);
      // Cash component covers remainder via tenderedAmount
      if (paymentMethod == PaymentMethod.cash) {
        return tenderedAmount != null && tenderedAmount! >= remainingBalance;
      }
      return (paid - orderTotal).abs() < 0.01;
    }
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return tenderedAmount != null && tenderedAmount! >= orderTotal;
      case PaymentMethod.promptpay:
      case PaymentMethod.card:
        return orderTotal > 0;
    }
  }

  bool get canSubmit {
    if (status == CheckoutStatus.processing) return false;
    return isFullyPaid;
  }

  /// All payment entries for API submission (including cash remainder).
  List<PaymentEntry> get allPayments {
    if (!isSplit) {
      return [PaymentEntry(method: paymentMethod, amount: orderTotal)];
    }
    // Add cash remainder as final entry
    final entries = [...payments];
    if (remainingBalance > 0 && paymentMethod == PaymentMethod.cash) {
      entries.add(PaymentEntry(method: PaymentMethod.cash, amount: remainingBalance));
    }
    return entries;
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
    bool? isSplit,
    List<PaymentEntry>? payments,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderTotal: orderTotal ?? this.orderTotal,
      tenderedAmount: clearTendered ? null : (tenderedAmount ?? this.tenderedAmount),
      changeAmount: changeAmount ?? this.changeAmount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      orderNumber: orderNumber ?? this.orderNumber,
      isSplit: isSplit ?? this.isSplit,
      payments: payments ?? this.payments,
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
      isSplit: false,
      payments: [],
    );
  }

  void setOrderTotal(double total) {
    state = state.copyWith(orderTotal: total);
  }

  void setTenderedAmount(double amount) {
    final effectiveTotal = state.isSplit ? state.remainingBalance : state.orderTotal;
    final change = amount - effectiveTotal;
    state = state.copyWith(
      tenderedAmount: amount,
      changeAmount: change,
    );
  }

  /// Enable split payment mode with the first non-cash method + amount.
  void enableSplit(PaymentMethod firstMethod, double firstAmount) {
    state = state.copyWith(
      isSplit: true,
      payments: [PaymentEntry(method: firstMethod, amount: firstAmount)],
      // Switch main method to cash for remainder
      paymentMethod: PaymentMethod.cash,
      clearTendered: true,
      changeAmount: 0.0,
    );
  }

  /// Cancel split and return to single payment.
  void cancelSplit() {
    state = state.copyWith(
      isSplit: false,
      payments: [],
      clearTendered: true,
      changeAmount: 0.0,
    );
  }

  List<double> quickCashSuggestions() {
    final total = state.isSplit ? state.remainingBalance : state.orderTotal;
    if (total <= 0) return [100, 500, 1000];

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
