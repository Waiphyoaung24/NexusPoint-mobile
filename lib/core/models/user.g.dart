// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      tenantId: json['tenantId'] as String?,
      organizationId: json['organizationId'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
      name: json['name'] as String?,
      image: json['image'] as String?,
      emailVerified: json['emailVerified'] as bool?,
      managerPinHash: json['managerPinHash'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'tenantId': instance.tenantId,
      'organizationId': instance.organizationId,
      'role': _$UserRoleEnumMap[instance.role],
      'name': instance.name,
      'image': instance.image,
      'emailVerified': instance.emailVerified,
      'managerPinHash': instance.managerPinHash,
      'isActive': instance.isActive,
    };

const _$UserRoleEnumMap = {
  UserRole.owner: 'owner',
  UserRole.manager: 'manager',
  UserRole.cashier: 'cashier',
};
