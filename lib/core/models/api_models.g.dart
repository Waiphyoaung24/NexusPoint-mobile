// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      activeOrganizationId: json['activeOrganizationId'] as String?,
      organizations: (json['organizations'] as List<dynamic>?)
          ?.map((e) => Organization.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
      'activeOrganizationId': instance.activeOrganizationId,
      'organizations': instance.organizations,
    };

_$SessionResponseImpl _$$SessionResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SessionResponseImpl(
      session: json['session'] as Map<String, dynamic>,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SessionResponseImplToJson(
        _$SessionResponseImpl instance) =>
    <String, dynamic>{
      'session': instance.session,
      'user': instance.user,
    };

_$OrganizationImpl _$$OrganizationImplFromJson(Map<String, dynamic> json) =>
    _$OrganizationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$$OrganizationImplToJson(_$OrganizationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
    };

_$OrderItemDtoImpl _$$OrderItemDtoImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemDtoImpl(
      skuId: json['skuId'] as String,
      name: json['name'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: _parsePrice(json['unitPrice']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$OrderItemDtoImplToJson(_$OrderItemDtoImpl instance) =>
    <String, dynamic>{
      'skuId': instance.skuId,
      'name': instance.name,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'notes': instance.notes,
    };

_$BackendOrderItemDtoImpl _$$BackendOrderItemDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$BackendOrderItemDtoImpl(
      menuItemId: json['menuItemId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: json['price'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$BackendOrderItemDtoImplToJson(
        _$BackendOrderItemDtoImpl instance) =>
    <String, dynamic>{
      'menuItemId': instance.menuItemId,
      'name': instance.name,
      'quantity': instance.quantity,
      'price': instance.price,
      'notes': instance.notes,
    };

_$OrderRequestImpl _$$OrderRequestImplFromJson(Map<String, dynamic> json) =>
    _$OrderRequestImpl(
      branchId: json['branchId'] as String?,
      source: json['source'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => BackendOrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: json['subtotal'] as String,
      total: json['total'] as String,
      discount: json['discount'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$OrderRequestImplToJson(_$OrderRequestImpl instance) =>
    <String, dynamic>{
      'branchId': instance.branchId,
      'source': instance.source,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'subtotal': instance.subtotal,
      'total': instance.total,
      'discount': instance.discount,
      'notes': instance.notes,
    };

_$OrderResponseImpl _$$OrderResponseImplFromJson(Map<String, dynamic> json) =>
    _$OrderResponseImpl(
      orderId: json['orderId'] as String,
      orderNumber: json['order_number'] as String? ?? '',
      status: json['status'] as String,
      totalAmount:
          json['totalAmount'] == null ? 0.0 : _parsePrice(json['totalAmount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      source: json['source'] as String? ?? 'pos',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  BackendOrderItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$OrderResponseImplToJson(_$OrderResponseImpl instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'order_number': instance.orderNumber,
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'createdAt': instance.createdAt.toIso8601String(),
      'source': instance.source,
      'items': instance.items,
    };

_$ModifierOptionDtoImpl _$$ModifierOptionDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ModifierOptionDtoImpl(
      id: json['id'] as String,
      modifierGroupId: json['modifierGroupId'] as String,
      organizationId: json['organizationId'] as String?,
      name: json['name'] as String,
      nameTh: json['nameTh'] as String?,
      priceAdjustment: json['priceAdjustment'] == null
          ? 0.0
          : _parsePrice(json['priceAdjustment']),
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ModifierOptionDtoImplToJson(
        _$ModifierOptionDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modifierGroupId': instance.modifierGroupId,
      'organizationId': instance.organizationId,
      'name': instance.name,
      'nameTh': instance.nameTh,
      'priceAdjustment': instance.priceAdjustment,
      'isDefault': instance.isDefault,
      'isActive': instance.isActive,
      'sortOrder': instance.sortOrder,
    };

_$ModifierGroupDtoImpl _$$ModifierGroupDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ModifierGroupDtoImpl(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String?,
      name: json['name'] as String,
      nameTh: json['nameTh'] as String?,
      isRequired: json['isRequired'] as bool? ?? false,
      minSelections: (json['minSelections'] as num?)?.toInt(),
      maxSelections: (json['maxSelections'] as num?)?.toInt(),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      isActive: json['isActive'] as bool? ?? true,
      options: (json['options'] as List<dynamic>?)
              ?.map(
                  (e) => ModifierOptionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ModifierGroupDtoImplToJson(
        _$ModifierGroupDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'name': instance.name,
      'nameTh': instance.nameTh,
      'isRequired': instance.isRequired,
      'minSelections': instance.minSelections,
      'maxSelections': instance.maxSelections,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'options': instance.options,
    };

_$ItemModifierLinkDtoImpl _$$ItemModifierLinkDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ItemModifierLinkDtoImpl(
      id: json['id'] as String,
      menuItemId: json['menuItemId'] as String,
      modifierGroupId: json['modifierGroupId'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ItemModifierLinkDtoImplToJson(
        _$ItemModifierLinkDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menuItemId': instance.menuItemId,
      'modifierGroupId': instance.modifierGroupId,
      'sortOrder': instance.sortOrder,
    };

_$MenuWithModifiersDtoImpl _$$MenuWithModifiersDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$MenuWithModifiersDtoImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => MenuItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      modifierGroups: (json['modifierGroups'] as List<dynamic>)
          .map((e) => ModifierGroupDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemModifierLinks: (json['itemModifierLinks'] as List<dynamic>)
          .map((e) => ItemModifierLinkDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MenuWithModifiersDtoImplToJson(
        _$MenuWithModifiersDtoImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'modifierGroups': instance.modifierGroups,
      'itemModifierLinks': instance.itemModifierLinks,
    };

_$MenuItemDtoImpl _$$MenuItemDtoImplFromJson(Map<String, dynamic> json) =>
    _$MenuItemDtoImpl(
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
      isAvailable: json['isAvailable'] as bool,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$MenuItemDtoImplToJson(_$MenuItemDtoImpl instance) =>
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
