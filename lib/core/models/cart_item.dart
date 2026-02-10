import 'package:freezed_annotation/freezed_annotation.dart';
import 'menu_item.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required MenuItem menuItem,
    required int quantity,
    required double unitPrice,
    String? notes,
  }) = _CartItem;

  const CartItem._();

  double get lineTotal => unitPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}
