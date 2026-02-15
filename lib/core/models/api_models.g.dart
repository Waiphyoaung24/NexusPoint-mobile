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

_$OrderRequestImpl _$$OrderRequestImplFromJson(Map<String, dynamic> json) =>
    _$OrderRequestImpl(
      tenantId: json['tenantId'] as String,
      branchId: json['branchId'] as String,
      source: json['source'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: _parsePrice(json['totalAmount']),
      paymentMethod: json['paymentMethod'] as String,
      tableNumber: json['tableNumber'] as String?,
    );

Map<String, dynamic> _$$OrderRequestImplToJson(_$OrderRequestImpl instance) =>
    <String, dynamic>{
      'tenantId': instance.tenantId,
      'branchId': instance.branchId,
      'source': instance.source,
      'items': instance.items,
      'totalAmount': instance.totalAmount,
      'paymentMethod': instance.paymentMethod,
      'tableNumber': instance.tableNumber,
    };

_$OrderResponseImpl _$$OrderResponseImplFromJson(Map<String, dynamic> json) =>
    _$OrderResponseImpl(
      orderId: json['orderId'] as String,
      orderNumber: json['order_number'] as String?,
      status: json['status'] as String,
      totalAmount: _parsePrice(json['totalAmount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$OrderResponseImplToJson(_$OrderResponseImpl instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'order_number': instance.orderNumber,
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'createdAt': instance.createdAt.toIso8601String(),
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
