import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item.freezed.dart';
part 'menu_item.g.dart';

@freezed
class MenuItem with _$MenuItem {
  const factory MenuItem({
    required String id,
    required String tenantId,
    required String name,
    required double price,
    String? category,
    String? imageUrl,
    @Default(true) bool isAvailable,
    @Default(0) int inventoryQty,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
}
