import 'package:freezed_annotation/freezed_annotation.dart';
import 'menu_item.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

double _parsePrice(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class SelectedModifierOption {
  final String optionId;
  final String groupId;
  final String groupName;
  final String name;
  final double priceAdjustment;

  const SelectedModifierOption({
    required this.optionId,
    required this.groupId,
    required this.groupName,
    required this.name,
    required this.priceAdjustment,
  });

  factory SelectedModifierOption.fromJson(Map<String, dynamic> json) =>
      SelectedModifierOption(
        optionId: json['optionId'] as String,
        groupId: json['groupId'] as String,
        groupName: json['groupName'] as String,
        name: json['name'] as String,
        priceAdjustment: (json['priceAdjustment'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'optionId': optionId,
        'groupId': groupId,
        'groupName': groupName,
        'name': name,
        'priceAdjustment': priceAdjustment,
      };
}

List<SelectedModifierOption> _parseModifiers(dynamic value) {
  if (value is List) {
    return value
        .map((e) =>
            SelectedModifierOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

List<Map<String, dynamic>> _modifiersToJson(
        List<SelectedModifierOption> modifiers) =>
    modifiers.map((m) => m.toJson()).toList();

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required MenuItem menuItem,
    required int quantity,
    @JsonKey(fromJson: _parsePrice) required double unitPrice,
    String? notes,
    @JsonKey(fromJson: _parseModifiers, toJson: _modifiersToJson)
    @Default([])
    List<SelectedModifierOption> selectedModifiers,
  }) = _CartItem;

  const CartItem._();

  double get modifierTotal =>
      selectedModifiers.fold(0.0, (sum, m) => sum + m.priceAdjustment);

  double get lineTotal => (unitPrice + modifierTotal) * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}
