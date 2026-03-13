// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  return _LoginRequest.fromJson(json);
}

/// @nodoc
mixin _$LoginRequest {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LoginRequestCopyWith<LoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestCopyWith<$Res> {
  factory $LoginRequestCopyWith(
          LoginRequest value, $Res Function(LoginRequest) then) =
      _$LoginRequestCopyWithImpl<$Res, LoginRequest>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$LoginRequestCopyWithImpl<$Res, $Val extends LoginRequest>
    implements $LoginRequestCopyWith<$Res> {
  _$LoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginRequestImplCopyWith<$Res>
    implements $LoginRequestCopyWith<$Res> {
  factory _$$LoginRequestImplCopyWith(
          _$LoginRequestImpl value, $Res Function(_$LoginRequestImpl) then) =
      __$$LoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$LoginRequestImplCopyWithImpl<$Res>
    extends _$LoginRequestCopyWithImpl<$Res, _$LoginRequestImpl>
    implements _$$LoginRequestImplCopyWith<$Res> {
  __$$LoginRequestImplCopyWithImpl(
      _$LoginRequestImpl _value, $Res Function(_$LoginRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_$LoginRequestImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginRequestImpl implements _LoginRequest {
  const _$LoginRequestImpl({required this.email, required this.password});

  factory _$LoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'LoginRequest(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      __$$LoginRequestImplCopyWithImpl<_$LoginRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginRequestImplToJson(
      this,
    );
  }
}

abstract class _LoginRequest implements LoginRequest {
  const factory _LoginRequest(
      {required final String email,
      required final String password}) = _$LoginRequestImpl;

  factory _LoginRequest.fromJson(Map<String, dynamic> json) =
      _$LoginRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get password;
  @override
  @JsonKey(ignore: true)
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return _AuthResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthResponse {
  String get token => throw _privateConstructorUsedError;
  User get user => throw _privateConstructorUsedError;
  String? get activeOrganizationId => throw _privateConstructorUsedError;
  List<Organization>? get organizations => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
          AuthResponse value, $Res Function(AuthResponse) then) =
      _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call(
      {String token,
      User user,
      String? activeOrganizationId,
      List<Organization>? organizations});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? user = null,
    Object? activeOrganizationId = freezed,
    Object? organizations = freezed,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      activeOrganizationId: freezed == activeOrganizationId
          ? _value.activeOrganizationId
          : activeOrganizationId // ignore: cast_nullable_to_non_nullable
              as String?,
      organizations: freezed == organizations
          ? _value.organizations
          : organizations // ignore: cast_nullable_to_non_nullable
              as List<Organization>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
          _$AuthResponseImpl value, $Res Function(_$AuthResponseImpl) then) =
      __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String token,
      User user,
      String? activeOrganizationId,
      List<Organization>? organizations});

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
      _$AuthResponseImpl _value, $Res Function(_$AuthResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? user = null,
    Object? activeOrganizationId = freezed,
    Object? organizations = freezed,
  }) {
    return _then(_$AuthResponseImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      activeOrganizationId: freezed == activeOrganizationId
          ? _value.activeOrganizationId
          : activeOrganizationId // ignore: cast_nullable_to_non_nullable
              as String?,
      organizations: freezed == organizations
          ? _value._organizations
          : organizations // ignore: cast_nullable_to_non_nullable
              as List<Organization>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl(
      {required this.token,
      required this.user,
      this.activeOrganizationId,
      final List<Organization>? organizations})
      : _organizations = organizations;

  factory _$AuthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseImplFromJson(json);

  @override
  final String token;
  @override
  final User user;
  @override
  final String? activeOrganizationId;
  final List<Organization>? _organizations;
  @override
  List<Organization>? get organizations {
    final value = _organizations;
    if (value == null) return null;
    if (_organizations is EqualUnmodifiableListView) return _organizations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AuthResponse(token: $token, user: $user, activeOrganizationId: $activeOrganizationId, organizations: $organizations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.activeOrganizationId, activeOrganizationId) ||
                other.activeOrganizationId == activeOrganizationId) &&
            const DeepCollectionEquality()
                .equals(other._organizations, _organizations));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      token,
      user,
      activeOrganizationId,
      const DeepCollectionEquality().hash(_organizations));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseImplToJson(
      this,
    );
  }
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse(
      {required final String token,
      required final User user,
      final String? activeOrganizationId,
      final List<Organization>? organizations}) = _$AuthResponseImpl;

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =
      _$AuthResponseImpl.fromJson;

  @override
  String get token;
  @override
  User get user;
  @override
  String? get activeOrganizationId;
  @override
  List<Organization>? get organizations;
  @override
  @JsonKey(ignore: true)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) {
  return _SessionResponse.fromJson(json);
}

/// @nodoc
mixin _$SessionResponse {
  Map<String, dynamic> get session => throw _privateConstructorUsedError;
  User get user => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SessionResponseCopyWith<SessionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionResponseCopyWith<$Res> {
  factory $SessionResponseCopyWith(
          SessionResponse value, $Res Function(SessionResponse) then) =
      _$SessionResponseCopyWithImpl<$Res, SessionResponse>;
  @useResult
  $Res call({Map<String, dynamic> session, User user});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$SessionResponseCopyWithImpl<$Res, $Val extends SessionResponse>
    implements $SessionResponseCopyWith<$Res> {
  _$SessionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? session = null,
    Object? user = null,
  }) {
    return _then(_value.copyWith(
      session: null == session
          ? _value.session
          : session // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SessionResponseImplCopyWith<$Res>
    implements $SessionResponseCopyWith<$Res> {
  factory _$$SessionResponseImplCopyWith(_$SessionResponseImpl value,
          $Res Function(_$SessionResponseImpl) then) =
      __$$SessionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, dynamic> session, User user});

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$SessionResponseImplCopyWithImpl<$Res>
    extends _$SessionResponseCopyWithImpl<$Res, _$SessionResponseImpl>
    implements _$$SessionResponseImplCopyWith<$Res> {
  __$$SessionResponseImplCopyWithImpl(
      _$SessionResponseImpl _value, $Res Function(_$SessionResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? session = null,
    Object? user = null,
  }) {
    return _then(_$SessionResponseImpl(
      session: null == session
          ? _value._session
          : session // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionResponseImpl implements _SessionResponse {
  const _$SessionResponseImpl(
      {required final Map<String, dynamic> session, required this.user})
      : _session = session;

  factory _$SessionResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionResponseImplFromJson(json);

  final Map<String, dynamic> _session;
  @override
  Map<String, dynamic> get session {
    if (_session is EqualUnmodifiableMapView) return _session;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_session);
  }

  @override
  final User user;

  @override
  String toString() {
    return 'SessionResponse(session: $session, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionResponseImpl &&
            const DeepCollectionEquality().equals(other._session, _session) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_session), user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionResponseImplCopyWith<_$SessionResponseImpl> get copyWith =>
      __$$SessionResponseImplCopyWithImpl<_$SessionResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionResponseImplToJson(
      this,
    );
  }
}

abstract class _SessionResponse implements SessionResponse {
  const factory _SessionResponse(
      {required final Map<String, dynamic> session,
      required final User user}) = _$SessionResponseImpl;

  factory _SessionResponse.fromJson(Map<String, dynamic> json) =
      _$SessionResponseImpl.fromJson;

  @override
  Map<String, dynamic> get session;
  @override
  User get user;
  @override
  @JsonKey(ignore: true)
  _$$SessionResponseImplCopyWith<_$SessionResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Organization _$OrganizationFromJson(Map<String, dynamic> json) {
  return _Organization.fromJson(json);
}

/// @nodoc
mixin _$Organization {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OrganizationCopyWith<Organization> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationCopyWith<$Res> {
  factory $OrganizationCopyWith(
          Organization value, $Res Function(Organization) then) =
      _$OrganizationCopyWithImpl<$Res, Organization>;
  @useResult
  $Res call({String id, String name, String? role});
}

/// @nodoc
class _$OrganizationCopyWithImpl<$Res, $Val extends Organization>
    implements $OrganizationCopyWith<$Res> {
  _$OrganizationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? role = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrganizationImplCopyWith<$Res>
    implements $OrganizationCopyWith<$Res> {
  factory _$$OrganizationImplCopyWith(
          _$OrganizationImpl value, $Res Function(_$OrganizationImpl) then) =
      __$$OrganizationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? role});
}

/// @nodoc
class __$$OrganizationImplCopyWithImpl<$Res>
    extends _$OrganizationCopyWithImpl<$Res, _$OrganizationImpl>
    implements _$$OrganizationImplCopyWith<$Res> {
  __$$OrganizationImplCopyWithImpl(
      _$OrganizationImpl _value, $Res Function(_$OrganizationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? role = freezed,
  }) {
    return _then(_$OrganizationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationImpl implements _Organization {
  const _$OrganizationImpl({required this.id, required this.name, this.role});

  factory _$OrganizationImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? role;

  @override
  String toString() {
    return 'Organization(id: $id, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, role);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationImplCopyWith<_$OrganizationImpl> get copyWith =>
      __$$OrganizationImplCopyWithImpl<_$OrganizationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationImplToJson(
      this,
    );
  }
}

abstract class _Organization implements Organization {
  const factory _Organization(
      {required final String id,
      required final String name,
      final String? role}) = _$OrganizationImpl;

  factory _Organization.fromJson(Map<String, dynamic> json) =
      _$OrganizationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get role;
  @override
  @JsonKey(ignore: true)
  _$$OrganizationImplCopyWith<_$OrganizationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderItemDto _$OrderItemDtoFromJson(Map<String, dynamic> json) {
  return _OrderItemDto.fromJson(json);
}

/// @nodoc
mixin _$OrderItemDto {
  String get skuId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parsePrice)
  double get unitPrice => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OrderItemDtoCopyWith<OrderItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemDtoCopyWith<$Res> {
  factory $OrderItemDtoCopyWith(
          OrderItemDto value, $Res Function(OrderItemDto) then) =
      _$OrderItemDtoCopyWithImpl<$Res, OrderItemDto>;
  @useResult
  $Res call(
      {String skuId,
      String? name,
      int quantity,
      @JsonKey(fromJson: _parsePrice) double unitPrice,
      String? notes});
}

/// @nodoc
class _$OrderItemDtoCopyWithImpl<$Res, $Val extends OrderItemDto>
    implements $OrderItemDtoCopyWith<$Res> {
  _$OrderItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skuId = null,
    Object? name = freezed,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      skuId: null == skuId
          ? _value.skuId
          : skuId // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderItemDtoImplCopyWith<$Res>
    implements $OrderItemDtoCopyWith<$Res> {
  factory _$$OrderItemDtoImplCopyWith(
          _$OrderItemDtoImpl value, $Res Function(_$OrderItemDtoImpl) then) =
      __$$OrderItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String skuId,
      String? name,
      int quantity,
      @JsonKey(fromJson: _parsePrice) double unitPrice,
      String? notes});
}

/// @nodoc
class __$$OrderItemDtoImplCopyWithImpl<$Res>
    extends _$OrderItemDtoCopyWithImpl<$Res, _$OrderItemDtoImpl>
    implements _$$OrderItemDtoImplCopyWith<$Res> {
  __$$OrderItemDtoImplCopyWithImpl(
      _$OrderItemDtoImpl _value, $Res Function(_$OrderItemDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skuId = null,
    Object? name = freezed,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? notes = freezed,
  }) {
    return _then(_$OrderItemDtoImpl(
      skuId: null == skuId
          ? _value.skuId
          : skuId // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemDtoImpl implements _OrderItemDto {
  const _$OrderItemDtoImpl(
      {required this.skuId,
      this.name,
      required this.quantity,
      @JsonKey(fromJson: _parsePrice) required this.unitPrice,
      this.notes});

  factory _$OrderItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemDtoImplFromJson(json);

  @override
  final String skuId;
  @override
  final String? name;
  @override
  final int quantity;
  @override
  @JsonKey(fromJson: _parsePrice)
  final double unitPrice;
  @override
  final String? notes;

  @override
  String toString() {
    return 'OrderItemDto(skuId: $skuId, name: $name, quantity: $quantity, unitPrice: $unitPrice, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemDtoImpl &&
            (identical(other.skuId, skuId) || other.skuId == skuId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, skuId, name, quantity, unitPrice, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemDtoImplCopyWith<_$OrderItemDtoImpl> get copyWith =>
      __$$OrderItemDtoImplCopyWithImpl<_$OrderItemDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemDtoImplToJson(
      this,
    );
  }
}

abstract class _OrderItemDto implements OrderItemDto {
  const factory _OrderItemDto(
      {required final String skuId,
      final String? name,
      required final int quantity,
      @JsonKey(fromJson: _parsePrice) required final double unitPrice,
      final String? notes}) = _$OrderItemDtoImpl;

  factory _OrderItemDto.fromJson(Map<String, dynamic> json) =
      _$OrderItemDtoImpl.fromJson;

  @override
  String get skuId;
  @override
  String? get name;
  @override
  int get quantity;
  @override
  @JsonKey(fromJson: _parsePrice)
  double get unitPrice;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$OrderItemDtoImplCopyWith<_$OrderItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BackendOrderItemDto _$BackendOrderItemDtoFromJson(Map<String, dynamic> json) {
  return _BackendOrderItemDto.fromJson(json);
}

/// @nodoc
mixin _$BackendOrderItemDto {
  String get menuItemId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  String get price =>
      throw _privateConstructorUsedError; // decimal string e.g. "50.00"
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BackendOrderItemDtoCopyWith<BackendOrderItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackendOrderItemDtoCopyWith<$Res> {
  factory $BackendOrderItemDtoCopyWith(
          BackendOrderItemDto value, $Res Function(BackendOrderItemDto) then) =
      _$BackendOrderItemDtoCopyWithImpl<$Res, BackendOrderItemDto>;
  @useResult
  $Res call(
      {String menuItemId,
      String name,
      int quantity,
      String price,
      String? notes});
}

/// @nodoc
class _$BackendOrderItemDtoCopyWithImpl<$Res, $Val extends BackendOrderItemDto>
    implements $BackendOrderItemDtoCopyWith<$Res> {
  _$BackendOrderItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItemId = null,
    Object? name = null,
    Object? quantity = null,
    Object? price = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      menuItemId: null == menuItemId
          ? _value.menuItemId
          : menuItemId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BackendOrderItemDtoImplCopyWith<$Res>
    implements $BackendOrderItemDtoCopyWith<$Res> {
  factory _$$BackendOrderItemDtoImplCopyWith(_$BackendOrderItemDtoImpl value,
          $Res Function(_$BackendOrderItemDtoImpl) then) =
      __$$BackendOrderItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String menuItemId,
      String name,
      int quantity,
      String price,
      String? notes});
}

/// @nodoc
class __$$BackendOrderItemDtoImplCopyWithImpl<$Res>
    extends _$BackendOrderItemDtoCopyWithImpl<$Res, _$BackendOrderItemDtoImpl>
    implements _$$BackendOrderItemDtoImplCopyWith<$Res> {
  __$$BackendOrderItemDtoImplCopyWithImpl(_$BackendOrderItemDtoImpl _value,
      $Res Function(_$BackendOrderItemDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItemId = null,
    Object? name = null,
    Object? quantity = null,
    Object? price = null,
    Object? notes = freezed,
  }) {
    return _then(_$BackendOrderItemDtoImpl(
      menuItemId: null == menuItemId
          ? _value.menuItemId
          : menuItemId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BackendOrderItemDtoImpl implements _BackendOrderItemDto {
  const _$BackendOrderItemDtoImpl(
      {required this.menuItemId,
      required this.name,
      required this.quantity,
      required this.price,
      this.notes});

  factory _$BackendOrderItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackendOrderItemDtoImplFromJson(json);

  @override
  final String menuItemId;
  @override
  final String name;
  @override
  final int quantity;
  @override
  final String price;
// decimal string e.g. "50.00"
  @override
  final String? notes;

  @override
  String toString() {
    return 'BackendOrderItemDto(menuItemId: $menuItemId, name: $name, quantity: $quantity, price: $price, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackendOrderItemDtoImpl &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, menuItemId, name, quantity, price, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BackendOrderItemDtoImplCopyWith<_$BackendOrderItemDtoImpl> get copyWith =>
      __$$BackendOrderItemDtoImplCopyWithImpl<_$BackendOrderItemDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackendOrderItemDtoImplToJson(
      this,
    );
  }
}

abstract class _BackendOrderItemDto implements BackendOrderItemDto {
  const factory _BackendOrderItemDto(
      {required final String menuItemId,
      required final String name,
      required final int quantity,
      required final String price,
      final String? notes}) = _$BackendOrderItemDtoImpl;

  factory _BackendOrderItemDto.fromJson(Map<String, dynamic> json) =
      _$BackendOrderItemDtoImpl.fromJson;

  @override
  String get menuItemId;
  @override
  String get name;
  @override
  int get quantity;
  @override
  String get price;
  @override // decimal string e.g. "50.00"
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$BackendOrderItemDtoImplCopyWith<_$BackendOrderItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderRequest _$OrderRequestFromJson(Map<String, dynamic> json) {
  return _OrderRequest.fromJson(json);
}

/// @nodoc
mixin _$OrderRequest {
  String? get branchId => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  String? get orderType => throw _privateConstructorUsedError;
  String? get tableId => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  String? get vatAmount => throw _privateConstructorUsedError;
  String? get vatRate => throw _privateConstructorUsedError;
  List<BackendOrderItemDto> get items => throw _privateConstructorUsedError;
  String get subtotal =>
      throw _privateConstructorUsedError; // decimal string e.g. "100.00"
  String get total =>
      throw _privateConstructorUsedError; // decimal string e.g. "100.00"
  String? get discount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OrderRequestCopyWith<OrderRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderRequestCopyWith<$Res> {
  factory $OrderRequestCopyWith(
          OrderRequest value, $Res Function(OrderRequest) then) =
      _$OrderRequestCopyWithImpl<$Res, OrderRequest>;
  @useResult
  $Res call(
      {String? branchId,
      String source,
      String? orderType,
      String? tableId,
      String? createdBy,
      String? vatAmount,
      String? vatRate,
      List<BackendOrderItemDto> items,
      String subtotal,
      String total,
      String? discount,
      String? notes});
}

/// @nodoc
class _$OrderRequestCopyWithImpl<$Res, $Val extends OrderRequest>
    implements $OrderRequestCopyWith<$Res> {
  _$OrderRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? branchId = freezed,
    Object? source = null,
    Object? orderType = freezed,
    Object? tableId = freezed,
    Object? createdBy = freezed,
    Object? vatAmount = freezed,
    Object? vatRate = freezed,
    Object? items = null,
    Object? subtotal = null,
    Object? total = null,
    Object? discount = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      branchId: freezed == branchId
          ? _value.branchId
          : branchId // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      orderType: freezed == orderType
          ? _value.orderType
          : orderType // ignore: cast_nullable_to_non_nullable
              as String?,
      tableId: freezed == tableId
          ? _value.tableId
          : tableId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      vatAmount: freezed == vatAmount
          ? _value.vatAmount
          : vatAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      vatRate: freezed == vatRate
          ? _value.vatRate
          : vatRate // ignore: cast_nullable_to_non_nullable
              as String?,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<BackendOrderItemDto>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as String,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderRequestImplCopyWith<$Res>
    implements $OrderRequestCopyWith<$Res> {
  factory _$$OrderRequestImplCopyWith(
          _$OrderRequestImpl value, $Res Function(_$OrderRequestImpl) then) =
      __$$OrderRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? branchId,
      String source,
      String? orderType,
      String? tableId,
      String? createdBy,
      String? vatAmount,
      String? vatRate,
      List<BackendOrderItemDto> items,
      String subtotal,
      String total,
      String? discount,
      String? notes});
}

/// @nodoc
class __$$OrderRequestImplCopyWithImpl<$Res>
    extends _$OrderRequestCopyWithImpl<$Res, _$OrderRequestImpl>
    implements _$$OrderRequestImplCopyWith<$Res> {
  __$$OrderRequestImplCopyWithImpl(
      _$OrderRequestImpl _value, $Res Function(_$OrderRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? branchId = freezed,
    Object? source = null,
    Object? orderType = freezed,
    Object? tableId = freezed,
    Object? createdBy = freezed,
    Object? vatAmount = freezed,
    Object? vatRate = freezed,
    Object? items = null,
    Object? subtotal = null,
    Object? total = null,
    Object? discount = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$OrderRequestImpl(
      branchId: freezed == branchId
          ? _value.branchId
          : branchId // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      orderType: freezed == orderType
          ? _value.orderType
          : orderType // ignore: cast_nullable_to_non_nullable
              as String?,
      tableId: freezed == tableId
          ? _value.tableId
          : tableId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      vatAmount: freezed == vatAmount
          ? _value.vatAmount
          : vatAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      vatRate: freezed == vatRate
          ? _value.vatRate
          : vatRate // ignore: cast_nullable_to_non_nullable
              as String?,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<BackendOrderItemDto>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as String,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$OrderRequestImpl implements _OrderRequest {
  const _$OrderRequestImpl(
      {this.branchId,
      required this.source,
      this.orderType,
      this.tableId,
      this.createdBy,
      this.vatAmount,
      this.vatRate,
      required final List<BackendOrderItemDto> items,
      required this.subtotal,
      required this.total,
      this.discount,
      this.notes})
      : _items = items;

  factory _$OrderRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderRequestImplFromJson(json);

  @override
  final String? branchId;
  @override
  final String source;
  @override
  final String? orderType;
  @override
  final String? tableId;
  @override
  final String? createdBy;
  @override
  final String? vatAmount;
  @override
  final String? vatRate;
  final List<BackendOrderItemDto> _items;
  @override
  List<BackendOrderItemDto> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String subtotal;
// decimal string e.g. "100.00"
  @override
  final String total;
// decimal string e.g. "100.00"
  @override
  final String? discount;
  @override
  final String? notes;

  @override
  String toString() {
    return 'OrderRequest(branchId: $branchId, source: $source, orderType: $orderType, tableId: $tableId, createdBy: $createdBy, vatAmount: $vatAmount, vatRate: $vatRate, items: $items, subtotal: $subtotal, total: $total, discount: $discount, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderRequestImpl &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.orderType, orderType) ||
                other.orderType == orderType) &&
            (identical(other.tableId, tableId) || other.tableId == tableId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.vatAmount, vatAmount) ||
                other.vatAmount == vatAmount) &&
            (identical(other.vatRate, vatRate) || other.vatRate == vatRate) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      branchId,
      source,
      orderType,
      tableId,
      createdBy,
      vatAmount,
      vatRate,
      const DeepCollectionEquality().hash(_items),
      subtotal,
      total,
      discount,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderRequestImplCopyWith<_$OrderRequestImpl> get copyWith =>
      __$$OrderRequestImplCopyWithImpl<_$OrderRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderRequestImplToJson(
      this,
    );
  }
}

abstract class _OrderRequest implements OrderRequest {
  const factory _OrderRequest(
      {final String? branchId,
      required final String source,
      final String? orderType,
      final String? tableId,
      final String? createdBy,
      final String? vatAmount,
      final String? vatRate,
      required final List<BackendOrderItemDto> items,
      required final String subtotal,
      required final String total,
      final String? discount,
      final String? notes}) = _$OrderRequestImpl;

  factory _OrderRequest.fromJson(Map<String, dynamic> json) =
      _$OrderRequestImpl.fromJson;

  @override
  String? get branchId;
  @override
  String get source;
  @override
  String? get orderType;
  @override
  String? get tableId;
  @override
  String? get createdBy;
  @override
  String? get vatAmount;
  @override
  String? get vatRate;
  @override
  List<BackendOrderItemDto> get items;
  @override
  String get subtotal;
  @override // decimal string e.g. "100.00"
  String get total;
  @override // decimal string e.g. "100.00"
  String? get discount;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$OrderRequestImplCopyWith<_$OrderRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) {
  return _OrderResponse.fromJson(json);
}

/// @nodoc
mixin _$OrderResponse {
  String get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_number', defaultValue: '')
  String? get orderNumber => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parsePrice)
  double get totalAmount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  List<BackendOrderItemDto> get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OrderResponseCopyWith<OrderResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderResponseCopyWith<$Res> {
  factory $OrderResponseCopyWith(
          OrderResponse value, $Res Function(OrderResponse) then) =
      _$OrderResponseCopyWithImpl<$Res, OrderResponse>;
  @useResult
  $Res call(
      {String orderId,
      @JsonKey(name: 'order_number', defaultValue: '') String? orderNumber,
      String status,
      @JsonKey(fromJson: _parsePrice) double totalAmount,
      DateTime createdAt,
      String source,
      List<BackendOrderItemDto> items});
}

/// @nodoc
class _$OrderResponseCopyWithImpl<$Res, $Val extends OrderResponse>
    implements $OrderResponseCopyWith<$Res> {
  _$OrderResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? orderNumber = freezed,
    Object? status = null,
    Object? totalAmount = null,
    Object? createdAt = null,
    Object? source = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: freezed == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<BackendOrderItemDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderResponseImplCopyWith<$Res>
    implements $OrderResponseCopyWith<$Res> {
  factory _$$OrderResponseImplCopyWith(
          _$OrderResponseImpl value, $Res Function(_$OrderResponseImpl) then) =
      __$$OrderResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String orderId,
      @JsonKey(name: 'order_number', defaultValue: '') String? orderNumber,
      String status,
      @JsonKey(fromJson: _parsePrice) double totalAmount,
      DateTime createdAt,
      String source,
      List<BackendOrderItemDto> items});
}

/// @nodoc
class __$$OrderResponseImplCopyWithImpl<$Res>
    extends _$OrderResponseCopyWithImpl<$Res, _$OrderResponseImpl>
    implements _$$OrderResponseImplCopyWith<$Res> {
  __$$OrderResponseImplCopyWithImpl(
      _$OrderResponseImpl _value, $Res Function(_$OrderResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? orderNumber = freezed,
    Object? status = null,
    Object? totalAmount = null,
    Object? createdAt = null,
    Object? source = null,
    Object? items = null,
  }) {
    return _then(_$OrderResponseImpl(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: freezed == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<BackendOrderItemDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderResponseImpl implements _OrderResponse {
  const _$OrderResponseImpl(
      {required this.orderId,
      @JsonKey(name: 'order_number', defaultValue: '') this.orderNumber,
      required this.status,
      @JsonKey(fromJson: _parsePrice) this.totalAmount = 0.0,
      required this.createdAt,
      this.source = 'pos',
      final List<BackendOrderItemDto> items = const []})
      : _items = items;

  factory _$OrderResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderResponseImplFromJson(json);

  @override
  final String orderId;
  @override
  @JsonKey(name: 'order_number', defaultValue: '')
  final String? orderNumber;
  @override
  final String status;
  @override
  @JsonKey(fromJson: _parsePrice)
  final double totalAmount;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final String source;
  final List<BackendOrderItemDto> _items;
  @override
  @JsonKey()
  List<BackendOrderItemDto> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'OrderResponse(orderId: $orderId, orderNumber: $orderNumber, status: $status, totalAmount: $totalAmount, createdAt: $createdAt, source: $source, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderResponseImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      orderId,
      orderNumber,
      status,
      totalAmount,
      createdAt,
      source,
      const DeepCollectionEquality().hash(_items));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderResponseImplCopyWith<_$OrderResponseImpl> get copyWith =>
      __$$OrderResponseImplCopyWithImpl<_$OrderResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderResponseImplToJson(
      this,
    );
  }
}

abstract class _OrderResponse implements OrderResponse {
  const factory _OrderResponse(
      {required final String orderId,
      @JsonKey(name: 'order_number', defaultValue: '')
      final String? orderNumber,
      required final String status,
      @JsonKey(fromJson: _parsePrice) final double totalAmount,
      required final DateTime createdAt,
      final String source,
      final List<BackendOrderItemDto> items}) = _$OrderResponseImpl;

  factory _OrderResponse.fromJson(Map<String, dynamic> json) =
      _$OrderResponseImpl.fromJson;

  @override
  String get orderId;
  @override
  @JsonKey(name: 'order_number', defaultValue: '')
  String? get orderNumber;
  @override
  String get status;
  @override
  @JsonKey(fromJson: _parsePrice)
  double get totalAmount;
  @override
  DateTime get createdAt;
  @override
  String get source;
  @override
  List<BackendOrderItemDto> get items;
  @override
  @JsonKey(ignore: true)
  _$$OrderResponseImplCopyWith<_$OrderResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModifierOptionDto _$ModifierOptionDtoFromJson(Map<String, dynamic> json) {
  return _ModifierOptionDto.fromJson(json);
}

/// @nodoc
mixin _$ModifierOptionDto {
  String get id => throw _privateConstructorUsedError;
  String get modifierGroupId => throw _privateConstructorUsedError;
  String? get organizationId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nameTh => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parsePrice)
  double get priceAdjustment => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int? get sortOrder => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModifierOptionDtoCopyWith<ModifierOptionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModifierOptionDtoCopyWith<$Res> {
  factory $ModifierOptionDtoCopyWith(
          ModifierOptionDto value, $Res Function(ModifierOptionDto) then) =
      _$ModifierOptionDtoCopyWithImpl<$Res, ModifierOptionDto>;
  @useResult
  $Res call(
      {String id,
      String modifierGroupId,
      String? organizationId,
      String name,
      String? nameTh,
      @JsonKey(fromJson: _parsePrice) double priceAdjustment,
      bool isDefault,
      bool isActive,
      int? sortOrder});
}

/// @nodoc
class _$ModifierOptionDtoCopyWithImpl<$Res, $Val extends ModifierOptionDto>
    implements $ModifierOptionDtoCopyWith<$Res> {
  _$ModifierOptionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? modifierGroupId = null,
    Object? organizationId = freezed,
    Object? name = null,
    Object? nameTh = freezed,
    Object? priceAdjustment = null,
    Object? isDefault = null,
    Object? isActive = null,
    Object? sortOrder = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      modifierGroupId: null == modifierGroupId
          ? _value.modifierGroupId
          : modifierGroupId // ignore: cast_nullable_to_non_nullable
              as String,
      organizationId: freezed == organizationId
          ? _value.organizationId
          : organizationId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameTh: freezed == nameTh
          ? _value.nameTh
          : nameTh // ignore: cast_nullable_to_non_nullable
              as String?,
      priceAdjustment: null == priceAdjustment
          ? _value.priceAdjustment
          : priceAdjustment // ignore: cast_nullable_to_non_nullable
              as double,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModifierOptionDtoImplCopyWith<$Res>
    implements $ModifierOptionDtoCopyWith<$Res> {
  factory _$$ModifierOptionDtoImplCopyWith(_$ModifierOptionDtoImpl value,
          $Res Function(_$ModifierOptionDtoImpl) then) =
      __$$ModifierOptionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String modifierGroupId,
      String? organizationId,
      String name,
      String? nameTh,
      @JsonKey(fromJson: _parsePrice) double priceAdjustment,
      bool isDefault,
      bool isActive,
      int? sortOrder});
}

/// @nodoc
class __$$ModifierOptionDtoImplCopyWithImpl<$Res>
    extends _$ModifierOptionDtoCopyWithImpl<$Res, _$ModifierOptionDtoImpl>
    implements _$$ModifierOptionDtoImplCopyWith<$Res> {
  __$$ModifierOptionDtoImplCopyWithImpl(_$ModifierOptionDtoImpl _value,
      $Res Function(_$ModifierOptionDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? modifierGroupId = null,
    Object? organizationId = freezed,
    Object? name = null,
    Object? nameTh = freezed,
    Object? priceAdjustment = null,
    Object? isDefault = null,
    Object? isActive = null,
    Object? sortOrder = freezed,
  }) {
    return _then(_$ModifierOptionDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      modifierGroupId: null == modifierGroupId
          ? _value.modifierGroupId
          : modifierGroupId // ignore: cast_nullable_to_non_nullable
              as String,
      organizationId: freezed == organizationId
          ? _value.organizationId
          : organizationId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameTh: freezed == nameTh
          ? _value.nameTh
          : nameTh // ignore: cast_nullable_to_non_nullable
              as String?,
      priceAdjustment: null == priceAdjustment
          ? _value.priceAdjustment
          : priceAdjustment // ignore: cast_nullable_to_non_nullable
              as double,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModifierOptionDtoImpl implements _ModifierOptionDto {
  const _$ModifierOptionDtoImpl(
      {required this.id,
      required this.modifierGroupId,
      this.organizationId,
      required this.name,
      this.nameTh,
      @JsonKey(fromJson: _parsePrice) this.priceAdjustment = 0.0,
      this.isDefault = false,
      this.isActive = true,
      this.sortOrder});

  factory _$ModifierOptionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModifierOptionDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String modifierGroupId;
  @override
  final String? organizationId;
  @override
  final String name;
  @override
  final String? nameTh;
  @override
  @JsonKey(fromJson: _parsePrice)
  final double priceAdjustment;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final int? sortOrder;

  @override
  String toString() {
    return 'ModifierOptionDto(id: $id, modifierGroupId: $modifierGroupId, organizationId: $organizationId, name: $name, nameTh: $nameTh, priceAdjustment: $priceAdjustment, isDefault: $isDefault, isActive: $isActive, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModifierOptionDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.modifierGroupId, modifierGroupId) ||
                other.modifierGroupId == modifierGroupId) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameTh, nameTh) || other.nameTh == nameTh) &&
            (identical(other.priceAdjustment, priceAdjustment) ||
                other.priceAdjustment == priceAdjustment) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      modifierGroupId,
      organizationId,
      name,
      nameTh,
      priceAdjustment,
      isDefault,
      isActive,
      sortOrder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModifierOptionDtoImplCopyWith<_$ModifierOptionDtoImpl> get copyWith =>
      __$$ModifierOptionDtoImplCopyWithImpl<_$ModifierOptionDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModifierOptionDtoImplToJson(
      this,
    );
  }
}

abstract class _ModifierOptionDto implements ModifierOptionDto {
  const factory _ModifierOptionDto(
      {required final String id,
      required final String modifierGroupId,
      final String? organizationId,
      required final String name,
      final String? nameTh,
      @JsonKey(fromJson: _parsePrice) final double priceAdjustment,
      final bool isDefault,
      final bool isActive,
      final int? sortOrder}) = _$ModifierOptionDtoImpl;

  factory _ModifierOptionDto.fromJson(Map<String, dynamic> json) =
      _$ModifierOptionDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get modifierGroupId;
  @override
  String? get organizationId;
  @override
  String get name;
  @override
  String? get nameTh;
  @override
  @JsonKey(fromJson: _parsePrice)
  double get priceAdjustment;
  @override
  bool get isDefault;
  @override
  bool get isActive;
  @override
  int? get sortOrder;
  @override
  @JsonKey(ignore: true)
  _$$ModifierOptionDtoImplCopyWith<_$ModifierOptionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModifierGroupDto _$ModifierGroupDtoFromJson(Map<String, dynamic> json) {
  return _ModifierGroupDto.fromJson(json);
}

/// @nodoc
mixin _$ModifierGroupDto {
  String get id => throw _privateConstructorUsedError;
  String? get organizationId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nameTh => throw _privateConstructorUsedError;
  bool get isRequired => throw _privateConstructorUsedError;
  int? get minSelections => throw _privateConstructorUsedError;
  int? get maxSelections => throw _privateConstructorUsedError;
  int? get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<ModifierOptionDto> get options => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModifierGroupDtoCopyWith<ModifierGroupDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModifierGroupDtoCopyWith<$Res> {
  factory $ModifierGroupDtoCopyWith(
          ModifierGroupDto value, $Res Function(ModifierGroupDto) then) =
      _$ModifierGroupDtoCopyWithImpl<$Res, ModifierGroupDto>;
  @useResult
  $Res call(
      {String id,
      String? organizationId,
      String name,
      String? nameTh,
      bool isRequired,
      int? minSelections,
      int? maxSelections,
      int? sortOrder,
      bool isActive,
      List<ModifierOptionDto> options});
}

/// @nodoc
class _$ModifierGroupDtoCopyWithImpl<$Res, $Val extends ModifierGroupDto>
    implements $ModifierGroupDtoCopyWith<$Res> {
  _$ModifierGroupDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizationId = freezed,
    Object? name = null,
    Object? nameTh = freezed,
    Object? isRequired = null,
    Object? minSelections = freezed,
    Object? maxSelections = freezed,
    Object? sortOrder = freezed,
    Object? isActive = null,
    Object? options = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      organizationId: freezed == organizationId
          ? _value.organizationId
          : organizationId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameTh: freezed == nameTh
          ? _value.nameTh
          : nameTh // ignore: cast_nullable_to_non_nullable
              as String?,
      isRequired: null == isRequired
          ? _value.isRequired
          : isRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      minSelections: freezed == minSelections
          ? _value.minSelections
          : minSelections // ignore: cast_nullable_to_non_nullable
              as int?,
      maxSelections: freezed == maxSelections
          ? _value.maxSelections
          : maxSelections // ignore: cast_nullable_to_non_nullable
              as int?,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<ModifierOptionDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModifierGroupDtoImplCopyWith<$Res>
    implements $ModifierGroupDtoCopyWith<$Res> {
  factory _$$ModifierGroupDtoImplCopyWith(_$ModifierGroupDtoImpl value,
          $Res Function(_$ModifierGroupDtoImpl) then) =
      __$$ModifierGroupDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? organizationId,
      String name,
      String? nameTh,
      bool isRequired,
      int? minSelections,
      int? maxSelections,
      int? sortOrder,
      bool isActive,
      List<ModifierOptionDto> options});
}

/// @nodoc
class __$$ModifierGroupDtoImplCopyWithImpl<$Res>
    extends _$ModifierGroupDtoCopyWithImpl<$Res, _$ModifierGroupDtoImpl>
    implements _$$ModifierGroupDtoImplCopyWith<$Res> {
  __$$ModifierGroupDtoImplCopyWithImpl(_$ModifierGroupDtoImpl _value,
      $Res Function(_$ModifierGroupDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizationId = freezed,
    Object? name = null,
    Object? nameTh = freezed,
    Object? isRequired = null,
    Object? minSelections = freezed,
    Object? maxSelections = freezed,
    Object? sortOrder = freezed,
    Object? isActive = null,
    Object? options = null,
  }) {
    return _then(_$ModifierGroupDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      organizationId: freezed == organizationId
          ? _value.organizationId
          : organizationId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameTh: freezed == nameTh
          ? _value.nameTh
          : nameTh // ignore: cast_nullable_to_non_nullable
              as String?,
      isRequired: null == isRequired
          ? _value.isRequired
          : isRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      minSelections: freezed == minSelections
          ? _value.minSelections
          : minSelections // ignore: cast_nullable_to_non_nullable
              as int?,
      maxSelections: freezed == maxSelections
          ? _value.maxSelections
          : maxSelections // ignore: cast_nullable_to_non_nullable
              as int?,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<ModifierOptionDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModifierGroupDtoImpl implements _ModifierGroupDto {
  const _$ModifierGroupDtoImpl(
      {required this.id,
      this.organizationId,
      required this.name,
      this.nameTh,
      this.isRequired = false,
      this.minSelections,
      this.maxSelections,
      this.sortOrder,
      this.isActive = true,
      final List<ModifierOptionDto> options = const []})
      : _options = options;

  factory _$ModifierGroupDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModifierGroupDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String? organizationId;
  @override
  final String name;
  @override
  final String? nameTh;
  @override
  @JsonKey()
  final bool isRequired;
  @override
  final int? minSelections;
  @override
  final int? maxSelections;
  @override
  final int? sortOrder;
  @override
  @JsonKey()
  final bool isActive;
  final List<ModifierOptionDto> _options;
  @override
  @JsonKey()
  List<ModifierOptionDto> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'ModifierGroupDto(id: $id, organizationId: $organizationId, name: $name, nameTh: $nameTh, isRequired: $isRequired, minSelections: $minSelections, maxSelections: $maxSelections, sortOrder: $sortOrder, isActive: $isActive, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModifierGroupDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameTh, nameTh) || other.nameTh == nameTh) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired) &&
            (identical(other.minSelections, minSelections) ||
                other.minSelections == minSelections) &&
            (identical(other.maxSelections, maxSelections) ||
                other.maxSelections == maxSelections) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      organizationId,
      name,
      nameTh,
      isRequired,
      minSelections,
      maxSelections,
      sortOrder,
      isActive,
      const DeepCollectionEquality().hash(_options));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModifierGroupDtoImplCopyWith<_$ModifierGroupDtoImpl> get copyWith =>
      __$$ModifierGroupDtoImplCopyWithImpl<_$ModifierGroupDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModifierGroupDtoImplToJson(
      this,
    );
  }
}

abstract class _ModifierGroupDto implements ModifierGroupDto {
  const factory _ModifierGroupDto(
      {required final String id,
      final String? organizationId,
      required final String name,
      final String? nameTh,
      final bool isRequired,
      final int? minSelections,
      final int? maxSelections,
      final int? sortOrder,
      final bool isActive,
      final List<ModifierOptionDto> options}) = _$ModifierGroupDtoImpl;

  factory _ModifierGroupDto.fromJson(Map<String, dynamic> json) =
      _$ModifierGroupDtoImpl.fromJson;

  @override
  String get id;
  @override
  String? get organizationId;
  @override
  String get name;
  @override
  String? get nameTh;
  @override
  bool get isRequired;
  @override
  int? get minSelections;
  @override
  int? get maxSelections;
  @override
  int? get sortOrder;
  @override
  bool get isActive;
  @override
  List<ModifierOptionDto> get options;
  @override
  @JsonKey(ignore: true)
  _$$ModifierGroupDtoImplCopyWith<_$ModifierGroupDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ItemModifierLinkDto _$ItemModifierLinkDtoFromJson(Map<String, dynamic> json) {
  return _ItemModifierLinkDto.fromJson(json);
}

/// @nodoc
mixin _$ItemModifierLinkDto {
  String get id => throw _privateConstructorUsedError;
  String get menuItemId => throw _privateConstructorUsedError;
  String get modifierGroupId => throw _privateConstructorUsedError;
  int? get sortOrder => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ItemModifierLinkDtoCopyWith<ItemModifierLinkDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemModifierLinkDtoCopyWith<$Res> {
  factory $ItemModifierLinkDtoCopyWith(
          ItemModifierLinkDto value, $Res Function(ItemModifierLinkDto) then) =
      _$ItemModifierLinkDtoCopyWithImpl<$Res, ItemModifierLinkDto>;
  @useResult
  $Res call(
      {String id, String menuItemId, String modifierGroupId, int? sortOrder});
}

/// @nodoc
class _$ItemModifierLinkDtoCopyWithImpl<$Res, $Val extends ItemModifierLinkDto>
    implements $ItemModifierLinkDtoCopyWith<$Res> {
  _$ItemModifierLinkDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? modifierGroupId = null,
    Object? sortOrder = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      menuItemId: null == menuItemId
          ? _value.menuItemId
          : menuItemId // ignore: cast_nullable_to_non_nullable
              as String,
      modifierGroupId: null == modifierGroupId
          ? _value.modifierGroupId
          : modifierGroupId // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemModifierLinkDtoImplCopyWith<$Res>
    implements $ItemModifierLinkDtoCopyWith<$Res> {
  factory _$$ItemModifierLinkDtoImplCopyWith(_$ItemModifierLinkDtoImpl value,
          $Res Function(_$ItemModifierLinkDtoImpl) then) =
      __$$ItemModifierLinkDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String menuItemId, String modifierGroupId, int? sortOrder});
}

/// @nodoc
class __$$ItemModifierLinkDtoImplCopyWithImpl<$Res>
    extends _$ItemModifierLinkDtoCopyWithImpl<$Res, _$ItemModifierLinkDtoImpl>
    implements _$$ItemModifierLinkDtoImplCopyWith<$Res> {
  __$$ItemModifierLinkDtoImplCopyWithImpl(_$ItemModifierLinkDtoImpl _value,
      $Res Function(_$ItemModifierLinkDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? modifierGroupId = null,
    Object? sortOrder = freezed,
  }) {
    return _then(_$ItemModifierLinkDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      menuItemId: null == menuItemId
          ? _value.menuItemId
          : menuItemId // ignore: cast_nullable_to_non_nullable
              as String,
      modifierGroupId: null == modifierGroupId
          ? _value.modifierGroupId
          : modifierGroupId // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemModifierLinkDtoImpl implements _ItemModifierLinkDto {
  const _$ItemModifierLinkDtoImpl(
      {required this.id,
      required this.menuItemId,
      required this.modifierGroupId,
      this.sortOrder});

  factory _$ItemModifierLinkDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemModifierLinkDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String menuItemId;
  @override
  final String modifierGroupId;
  @override
  final int? sortOrder;

  @override
  String toString() {
    return 'ItemModifierLinkDto(id: $id, menuItemId: $menuItemId, modifierGroupId: $modifierGroupId, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemModifierLinkDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.modifierGroupId, modifierGroupId) ||
                other.modifierGroupId == modifierGroupId) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, menuItemId, modifierGroupId, sortOrder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemModifierLinkDtoImplCopyWith<_$ItemModifierLinkDtoImpl> get copyWith =>
      __$$ItemModifierLinkDtoImplCopyWithImpl<_$ItemModifierLinkDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemModifierLinkDtoImplToJson(
      this,
    );
  }
}

abstract class _ItemModifierLinkDto implements ItemModifierLinkDto {
  const factory _ItemModifierLinkDto(
      {required final String id,
      required final String menuItemId,
      required final String modifierGroupId,
      final int? sortOrder}) = _$ItemModifierLinkDtoImpl;

  factory _ItemModifierLinkDto.fromJson(Map<String, dynamic> json) =
      _$ItemModifierLinkDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get menuItemId;
  @override
  String get modifierGroupId;
  @override
  int? get sortOrder;
  @override
  @JsonKey(ignore: true)
  _$$ItemModifierLinkDtoImplCopyWith<_$ItemModifierLinkDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MenuWithModifiersDto _$MenuWithModifiersDtoFromJson(Map<String, dynamic> json) {
  return _MenuWithModifiersDto.fromJson(json);
}

/// @nodoc
mixin _$MenuWithModifiersDto {
  List<MenuItemDto> get items => throw _privateConstructorUsedError;
  List<ModifierGroupDto> get modifierGroups =>
      throw _privateConstructorUsedError;
  List<ItemModifierLinkDto> get itemModifierLinks =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MenuWithModifiersDtoCopyWith<MenuWithModifiersDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuWithModifiersDtoCopyWith<$Res> {
  factory $MenuWithModifiersDtoCopyWith(MenuWithModifiersDto value,
          $Res Function(MenuWithModifiersDto) then) =
      _$MenuWithModifiersDtoCopyWithImpl<$Res, MenuWithModifiersDto>;
  @useResult
  $Res call(
      {List<MenuItemDto> items,
      List<ModifierGroupDto> modifierGroups,
      List<ItemModifierLinkDto> itemModifierLinks});
}

/// @nodoc
class _$MenuWithModifiersDtoCopyWithImpl<$Res,
        $Val extends MenuWithModifiersDto>
    implements $MenuWithModifiersDtoCopyWith<$Res> {
  _$MenuWithModifiersDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? modifierGroups = null,
    Object? itemModifierLinks = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MenuItemDto>,
      modifierGroups: null == modifierGroups
          ? _value.modifierGroups
          : modifierGroups // ignore: cast_nullable_to_non_nullable
              as List<ModifierGroupDto>,
      itemModifierLinks: null == itemModifierLinks
          ? _value.itemModifierLinks
          : itemModifierLinks // ignore: cast_nullable_to_non_nullable
              as List<ItemModifierLinkDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MenuWithModifiersDtoImplCopyWith<$Res>
    implements $MenuWithModifiersDtoCopyWith<$Res> {
  factory _$$MenuWithModifiersDtoImplCopyWith(_$MenuWithModifiersDtoImpl value,
          $Res Function(_$MenuWithModifiersDtoImpl) then) =
      __$$MenuWithModifiersDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<MenuItemDto> items,
      List<ModifierGroupDto> modifierGroups,
      List<ItemModifierLinkDto> itemModifierLinks});
}

/// @nodoc
class __$$MenuWithModifiersDtoImplCopyWithImpl<$Res>
    extends _$MenuWithModifiersDtoCopyWithImpl<$Res, _$MenuWithModifiersDtoImpl>
    implements _$$MenuWithModifiersDtoImplCopyWith<$Res> {
  __$$MenuWithModifiersDtoImplCopyWithImpl(_$MenuWithModifiersDtoImpl _value,
      $Res Function(_$MenuWithModifiersDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? modifierGroups = null,
    Object? itemModifierLinks = null,
  }) {
    return _then(_$MenuWithModifiersDtoImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MenuItemDto>,
      modifierGroups: null == modifierGroups
          ? _value._modifierGroups
          : modifierGroups // ignore: cast_nullable_to_non_nullable
              as List<ModifierGroupDto>,
      itemModifierLinks: null == itemModifierLinks
          ? _value._itemModifierLinks
          : itemModifierLinks // ignore: cast_nullable_to_non_nullable
              as List<ItemModifierLinkDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuWithModifiersDtoImpl implements _MenuWithModifiersDto {
  const _$MenuWithModifiersDtoImpl(
      {required final List<MenuItemDto> items,
      required final List<ModifierGroupDto> modifierGroups,
      required final List<ItemModifierLinkDto> itemModifierLinks})
      : _items = items,
        _modifierGroups = modifierGroups,
        _itemModifierLinks = itemModifierLinks;

  factory _$MenuWithModifiersDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuWithModifiersDtoImplFromJson(json);

  final List<MenuItemDto> _items;
  @override
  List<MenuItemDto> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<ModifierGroupDto> _modifierGroups;
  @override
  List<ModifierGroupDto> get modifierGroups {
    if (_modifierGroups is EqualUnmodifiableListView) return _modifierGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modifierGroups);
  }

  final List<ItemModifierLinkDto> _itemModifierLinks;
  @override
  List<ItemModifierLinkDto> get itemModifierLinks {
    if (_itemModifierLinks is EqualUnmodifiableListView)
      return _itemModifierLinks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itemModifierLinks);
  }

  @override
  String toString() {
    return 'MenuWithModifiersDto(items: $items, modifierGroups: $modifierGroups, itemModifierLinks: $itemModifierLinks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuWithModifiersDtoImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality()
                .equals(other._modifierGroups, _modifierGroups) &&
            const DeepCollectionEquality()
                .equals(other._itemModifierLinks, _itemModifierLinks));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_modifierGroups),
      const DeepCollectionEquality().hash(_itemModifierLinks));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuWithModifiersDtoImplCopyWith<_$MenuWithModifiersDtoImpl>
      get copyWith =>
          __$$MenuWithModifiersDtoImplCopyWithImpl<_$MenuWithModifiersDtoImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuWithModifiersDtoImplToJson(
      this,
    );
  }
}

abstract class _MenuWithModifiersDto implements MenuWithModifiersDto {
  const factory _MenuWithModifiersDto(
          {required final List<MenuItemDto> items,
          required final List<ModifierGroupDto> modifierGroups,
          required final List<ItemModifierLinkDto> itemModifierLinks}) =
      _$MenuWithModifiersDtoImpl;

  factory _MenuWithModifiersDto.fromJson(Map<String, dynamic> json) =
      _$MenuWithModifiersDtoImpl.fromJson;

  @override
  List<MenuItemDto> get items;
  @override
  List<ModifierGroupDto> get modifierGroups;
  @override
  List<ItemModifierLinkDto> get itemModifierLinks;
  @override
  @JsonKey(ignore: true)
  _$$MenuWithModifiersDtoImplCopyWith<_$MenuWithModifiersDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

MenuItemDto _$MenuItemDtoFromJson(Map<String, dynamic> json) {
  return _MenuItemDto.fromJson(json);
}

/// @nodoc
mixin _$MenuItemDto {
  String get id => throw _privateConstructorUsedError;
  String? get organizationId => throw _privateConstructorUsedError;
  String? get branchId => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get nameTh => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parsePrice)
  double get price => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'isAvailable')
  bool get isAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'sortOrder')
  int? get sortOrder => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MenuItemDtoCopyWith<MenuItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuItemDtoCopyWith<$Res> {
  factory $MenuItemDtoCopyWith(
          MenuItemDto value, $Res Function(MenuItemDto) then) =
      _$MenuItemDtoCopyWithImpl<$Res, MenuItemDto>;
  @useResult
  $Res call(
      {String id,
      String? organizationId,
      String? branchId,
      String sku,
      String name,
      String? nameTh,
      String? description,
      @JsonKey(fromJson: _parsePrice) double price,
      String? category,
      String? imageUrl,
      @JsonKey(name: 'isAvailable') bool isAvailable,
      @JsonKey(name: 'sortOrder') int? sortOrder});
}

/// @nodoc
class _$MenuItemDtoCopyWithImpl<$Res, $Val extends MenuItemDto>
    implements $MenuItemDtoCopyWith<$Res> {
  _$MenuItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizationId = freezed,
    Object? branchId = freezed,
    Object? sku = null,
    Object? name = null,
    Object? nameTh = freezed,
    Object? description = freezed,
    Object? price = null,
    Object? category = freezed,
    Object? imageUrl = freezed,
    Object? isAvailable = null,
    Object? sortOrder = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      organizationId: freezed == organizationId
          ? _value.organizationId
          : organizationId // ignore: cast_nullable_to_non_nullable
              as String?,
      branchId: freezed == branchId
          ? _value.branchId
          : branchId // ignore: cast_nullable_to_non_nullable
              as String?,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameTh: freezed == nameTh
          ? _value.nameTh
          : nameTh // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MenuItemDtoImplCopyWith<$Res>
    implements $MenuItemDtoCopyWith<$Res> {
  factory _$$MenuItemDtoImplCopyWith(
          _$MenuItemDtoImpl value, $Res Function(_$MenuItemDtoImpl) then) =
      __$$MenuItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? organizationId,
      String? branchId,
      String sku,
      String name,
      String? nameTh,
      String? description,
      @JsonKey(fromJson: _parsePrice) double price,
      String? category,
      String? imageUrl,
      @JsonKey(name: 'isAvailable') bool isAvailable,
      @JsonKey(name: 'sortOrder') int? sortOrder});
}

/// @nodoc
class __$$MenuItemDtoImplCopyWithImpl<$Res>
    extends _$MenuItemDtoCopyWithImpl<$Res, _$MenuItemDtoImpl>
    implements _$$MenuItemDtoImplCopyWith<$Res> {
  __$$MenuItemDtoImplCopyWithImpl(
      _$MenuItemDtoImpl _value, $Res Function(_$MenuItemDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizationId = freezed,
    Object? branchId = freezed,
    Object? sku = null,
    Object? name = null,
    Object? nameTh = freezed,
    Object? description = freezed,
    Object? price = null,
    Object? category = freezed,
    Object? imageUrl = freezed,
    Object? isAvailable = null,
    Object? sortOrder = freezed,
  }) {
    return _then(_$MenuItemDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      organizationId: freezed == organizationId
          ? _value.organizationId
          : organizationId // ignore: cast_nullable_to_non_nullable
              as String?,
      branchId: freezed == branchId
          ? _value.branchId
          : branchId // ignore: cast_nullable_to_non_nullable
              as String?,
      sku: null == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameTh: freezed == nameTh
          ? _value.nameTh
          : nameTh // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: freezed == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuItemDtoImpl implements _MenuItemDto {
  const _$MenuItemDtoImpl(
      {required this.id,
      this.organizationId,
      this.branchId,
      required this.sku,
      required this.name,
      this.nameTh,
      this.description,
      @JsonKey(fromJson: _parsePrice) required this.price,
      this.category,
      this.imageUrl,
      @JsonKey(name: 'isAvailable') required this.isAvailable,
      @JsonKey(name: 'sortOrder') this.sortOrder});

  factory _$MenuItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuItemDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String? organizationId;
  @override
  final String? branchId;
  @override
  final String sku;
  @override
  final String name;
  @override
  final String? nameTh;
  @override
  final String? description;
  @override
  @JsonKey(fromJson: _parsePrice)
  final double price;
  @override
  final String? category;
  @override
  final String? imageUrl;
  @override
  @JsonKey(name: 'isAvailable')
  final bool isAvailable;
  @override
  @JsonKey(name: 'sortOrder')
  final int? sortOrder;

  @override
  String toString() {
    return 'MenuItemDto(id: $id, organizationId: $organizationId, branchId: $branchId, sku: $sku, name: $name, nameTh: $nameTh, description: $description, price: $price, category: $category, imageUrl: $imageUrl, isAvailable: $isAvailable, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuItemDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameTh, nameTh) || other.nameTh == nameTh) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      organizationId,
      branchId,
      sku,
      name,
      nameTh,
      description,
      price,
      category,
      imageUrl,
      isAvailable,
      sortOrder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuItemDtoImplCopyWith<_$MenuItemDtoImpl> get copyWith =>
      __$$MenuItemDtoImplCopyWithImpl<_$MenuItemDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuItemDtoImplToJson(
      this,
    );
  }
}

abstract class _MenuItemDto implements MenuItemDto {
  const factory _MenuItemDto(
      {required final String id,
      final String? organizationId,
      final String? branchId,
      required final String sku,
      required final String name,
      final String? nameTh,
      final String? description,
      @JsonKey(fromJson: _parsePrice) required final double price,
      final String? category,
      final String? imageUrl,
      @JsonKey(name: 'isAvailable') required final bool isAvailable,
      @JsonKey(name: 'sortOrder') final int? sortOrder}) = _$MenuItemDtoImpl;

  factory _MenuItemDto.fromJson(Map<String, dynamic> json) =
      _$MenuItemDtoImpl.fromJson;

  @override
  String get id;
  @override
  String? get organizationId;
  @override
  String? get branchId;
  @override
  String get sku;
  @override
  String get name;
  @override
  String? get nameTh;
  @override
  String? get description;
  @override
  @JsonKey(fromJson: _parsePrice)
  double get price;
  @override
  String? get category;
  @override
  String? get imageUrl;
  @override
  @JsonKey(name: 'isAvailable')
  bool get isAvailable;
  @override
  @JsonKey(name: 'sortOrder')
  int? get sortOrder;
  @override
  @JsonKey(ignore: true)
  _$$MenuItemDtoImplCopyWith<_$MenuItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
