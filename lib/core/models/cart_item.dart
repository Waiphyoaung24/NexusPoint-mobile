import 'package:freezed_annotation/freezed_annotation.dart';
import 'menu_item.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

double _parsePrice(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required MenuItem menuItem,
    required int quantity,
    @JsonKey(fromJson: _parsePrice) required double unitPrice,
    String? notes,
  }) = _CartItem;

  const CartItem._();

  double get lineTotal => unitPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}
