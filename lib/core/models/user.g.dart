// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      managerPinHash: json['managerPinHash'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'managerPinHash': instance.managerPinHash,
      'isActive': instance.isActive,
    };

const _$UserRoleEnumMap = {
  UserRole.owner: 'owner',
  UserRole.manager: 'manager',
  UserRole.cashier: 'cashier',
};
