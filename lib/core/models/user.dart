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
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? tenantId,
    @JsonKey(name: 'organizationId') String? organizationId,
    UserRole? role,
    String? name,
    String? image,
    bool? emailVerified,
    String? managerPinHash,
    @Default(true) bool isActive,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
}
