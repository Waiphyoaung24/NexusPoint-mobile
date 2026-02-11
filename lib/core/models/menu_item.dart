import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item.freezed.dart';
part 'menu_item.g.dart';

@freezed
class MenuItem with _$MenuItem {
  const factory MenuItem({
    required String id,
    String? organizationId,
    String? branchId,
    required String sku,
    required String name,
    String? nameTh,
    String? description,
    required double price,
    String? category,
    String? imageUrl,
    @Default(true) bool isAvailable,
    int? sortOrder,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
}
