// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuItemImpl _$$MenuItemImplFromJson(Map<String, dynamic> json) =>
    _$MenuItemImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      inventoryQty: (json['inventoryQty'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MenuItemImplToJson(_$MenuItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'price': instance.price,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'isAvailable': instance.isAvailable,
      'inventoryQty': instance.inventoryQty,
    };
