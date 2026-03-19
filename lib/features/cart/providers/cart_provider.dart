import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/menu_item.dart';
import '../../../core/models/cart_item.dart';

part 'cart_provider.freezed.dart';

@freezed
class CartState with _$CartState {
  const factory CartState({
    @Default([]) List<CartItem> items,
    @Default(0.0) double subtotal,
    @Default(0.0) double discountPercent,
    @Default(0.0) double discountAmount,
    @Default(0.0) double tax,
    @Default(0.0) double total,
    @Default(0.07) double vatRate,
    String? discountApproverId,
    String? discountReason,
  }) = _CartState;

  const CartState._();

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  bool get hasDiscount => discountPercent > 0;

  /// Alias for consistency with checkout UI labels
  double get taxAmount => tax;
  double get grandTotal => total;
}

/// Reads the cached VAT rate from SharedPreferences, falling back to 0.07 (7%).
final vatRateProvider = FutureProvider<double>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('org_vat_rate') ?? 0.07;
});

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final vatRate = ref.watch(vatRateProvider).valueOrNull ?? 0.07;
  return CartNotifier(vatRate: vatRate);
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier({double vatRate = 0.07}) : super(CartState(vatRate: vatRate));

  void addItem(
    MenuItem item, {
    int quantity = 1,
    String? notes,
    List<SelectedModifierOption> selectedModifiers = const [],
  }) {
    // Items with different modifier selections are treated as separate line items
    final modifierKey = selectedModifiers.map((m) => m.optionId).join(',');
    final existingIndex = state.items.indexWhere(
      (cartItem) =>
          cartItem.menuItem.id == item.id &&
          cartItem.notes == notes &&
          cartItem.selectedModifiers.map((m) => m.optionId).join(',') ==
              modifierKey,
    );

    List<CartItem> updatedItems;

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final existing = state.items[existingIndex];
      updatedItems = [...state.items];
      updatedItems[existingIndex] = CartItem(
        menuItem: existing.menuItem,
        quantity: existing.quantity + quantity,
        unitPrice: existing.unitPrice,
        notes: existing.notes,
        selectedModifiers: existing.selectedModifiers,
      );
    } else {
      // Add new item
      updatedItems = [
        ...state.items,
        CartItem(
          menuItem: item,
          quantity: quantity,
          unitPrice: item.price,
          notes: notes,
          selectedModifiers: selectedModifiers,
        ),
      ];
    }

    state = _recalculate(updatedItems);
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(index);
      return;
    }

    final updatedItems = [...state.items];
    final item = updatedItems[index];
    updatedItems[index] = CartItem(
      menuItem: item.menuItem,
      quantity: newQuantity,
      unitPrice: item.unitPrice,
      notes: item.notes,
    );

    state = _recalculate(updatedItems);
  }

  void removeItem(int index) {
    final updatedItems = [...state.items]..removeAt(index);
    state = _recalculate(updatedItems);
  }

  /// Apply a percentage discount (F-008).
  void applyDiscount({
    required double percent,
    required String approverId,
    String? reason,
  }) {
    state = _recalculate(
      state.items,
      discountPercent: percent,
      discountApproverId: approverId,
      discountReason: reason,
    );
  }

  /// Remove any applied discount.
  void removeDiscount() {
    state = _recalculate(state.items);
  }

  void clear() {
    state = CartState(vatRate: state.vatRate);
  }

  CartState _recalculate(
    List<CartItem> items, {
    double? discountPercent,
    String? discountApproverId,
    String? discountReason,
  }) {
    final pct = discountPercent ?? state.discountPercent;
    final subtotal = items.fold(0.0, (sum, item) => sum + item.lineTotal);

    // F-008: Discount applies to subtotal BEFORE VAT (Thai accounting)
    final discount = subtotal * (pct / 100.0);
    final taxableAmount = subtotal - discount;
    final tax = taxableAmount * state.vatRate;
    final total = taxableAmount + tax;

    return CartState(
      items: items,
      subtotal: subtotal,
      discountPercent: pct,
      discountAmount: discount,
      tax: tax,
      total: total,
      vatRate: state.vatRate,
      discountApproverId: discountApproverId ?? state.discountApproverId,
      discountReason: discountReason ?? state.discountReason,
    );
  }
}
