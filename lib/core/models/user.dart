import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole {
  @JsonValue('owner')
  owner,
  @JsonValue('manager')
  manager,
  @JsonValue('cashier')
  cashier,
  @JsonValue('waiter')
  waiter,
  @JsonValue('kitchen')
  kitchen,
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? tenantId,
    @JsonKey(name: 'organizationId') String? organizationId,
    UserRole? role,
    @JsonKey(name: 'staffRole') UserRole? staffRole,
    String? name,
    String? image,
    bool? emailVerified,
    String? branchId,
    String? managerPinHash,
    @Default(true) bool isActive,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
}
