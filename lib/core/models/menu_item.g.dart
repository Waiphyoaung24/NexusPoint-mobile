// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuItemImpl _$$MenuItemImplFromJson(Map<String, dynamic> json) =>
    _$MenuItemImpl(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String?,
      branchId: json['branchId'] as String?,
      sku: json['sku'] as String,
      name: json['name'] as String,
      nameTh: json['nameTh'] as String?,
      description: json['description'] as String?,
      price: _parsePrice(json['price']),
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$MenuItemImplToJson(_$MenuItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'branchId': instance.branchId,
      'sku': instance.sku,
      'name': instance.name,
      'nameTh': instance.nameTh,
      'description': instance.description,
      'price': instance.price,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'isAvailable': instance.isAvailable,
      'sortOrder': instance.sortOrder,
    };
