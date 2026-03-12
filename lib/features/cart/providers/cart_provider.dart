import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/menu_item.dart';
import '../../../core/models/cart_item.dart';

part 'cart_provider.freezed.dart';

@freezed
class CartState with _$CartState {
  const factory CartState({
    @Default([]) List<CartItem> items,
    @Default(0.0) double subtotal,
    @Default(0.0) double tax,
    @Default(0.0) double total,
  }) = _CartState;

  const CartState._();

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

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

  void clear() {
    state = const CartState();
  }

  CartState _recalculate(List<CartItem> items) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.lineTotal);
    const taxRate = 0.07; // 7% VAT (Thailand)
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    return CartState(
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
    );
  }
}
