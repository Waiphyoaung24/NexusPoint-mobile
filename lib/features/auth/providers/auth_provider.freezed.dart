// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unauthenticated,
    required TResult Function(User user, List<BranchDto> branches)
        branchPending,
    required TResult Function(User user) authenticated,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unauthenticated,
    TResult? Function(User user, List<BranchDto> branches)? branchPending,
    TResult? Function(User user)? authenticated,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unauthenticated,
    TResult Function(User user, List<BranchDto> branches)? branchPending,
    TResult Function(User user)? authenticated,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(BranchPending value) branchPending,
    required TResult Function(Authenticated value) authenticated,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(BranchPending value)? branchPending,
    TResult? Function(Authenticated value)? authenticated,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(BranchPending value)? branchPending,
    TResult Function(Authenticated value)? authenticated,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$UnauthenticatedImplCopyWith<$Res> {
  factory _$$UnauthenticatedImplCopyWith(_$UnauthenticatedImpl value,
          $Res Function(_$UnauthenticatedImpl) then) =
      __$$UnauthenticatedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UnauthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$UnauthenticatedImpl>
    implements _$$UnauthenticatedImplCopyWith<$Res> {
  __$$UnauthenticatedImplCopyWithImpl(
      _$UnauthenticatedImpl _value, $Res Function(_$UnauthenticatedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$UnauthenticatedImpl
    with DiagnosticableTreeMixin
    implements Unauthenticated {
  const _$UnauthenticatedImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AuthState.unauthenticated()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'AuthState.unauthenticated'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UnauthenticatedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unauthenticated,
    required TResult Function(User user, List<BranchDto> branches)
        branchPending,
    required TResult Function(User user) authenticated,
  }) {
    return unauthenticated();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unauthenticated,
    TResult? Function(User user, List<BranchDto> branches)? branchPending,
    TResult? Function(User user)? authenticated,
  }) {
    return unauthenticated?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unauthenticated,
    TResult Function(User user, List<BranchDto> branches)? branchPending,
    TResult Function(User user)? authenticated,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(BranchPending value) branchPending,
    required TResult Function(Authenticated value) authenticated,
  }) {
    return unauthenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(BranchPending value)? branchPending,
    TResult? Function(Authenticated value)? authenticated,
  }) {
    return unauthenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(BranchPending value)? branchPending,
    TResult Function(Authenticated value)? authenticated,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(this);
    }
    return orElse();
  }
}

abstract class Unauthenticated implements AuthState {
  const factory Unauthenticated() = _$UnauthenticatedImpl;
}

/// @nodoc
abstract class _$$BranchPendingImplCopyWith<$Res> {
  factory _$$BranchPendingImplCopyWith(
          _$BranchPendingImpl value, $Res Function(_$BranchPendingImpl) then) =
      __$$BranchPendingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({User user, List<BranchDto> branches});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$BranchPendingImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$BranchPendingImpl>
    implements _$$BranchPendingImplCopyWith<$Res> {
  __$$BranchPendingImplCopyWithImpl(
      _$BranchPendingImpl _value, $Res Function(_$BranchPendingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? branches = null,
  }) {
    return _then(_$BranchPendingImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      branches: null == branches
          ? _value._branches
          : branches // ignore: cast_nullable_to_non_nullable
              as List<BranchDto>,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value));
    });
  }
}

/// @nodoc

class _$BranchPendingImpl
    with DiagnosticableTreeMixin
    implements BranchPending {
  const _$BranchPendingImpl(
      {required this.user, required final List<BranchDto> branches})
      : _branches = branches;

  @override
  final User user;
  final List<BranchDto> _branches;
  @override
  List<BranchDto> get branches {
    if (_branches is EqualUnmodifiableListView) return _branches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_branches);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AuthState.branchPending(user: $user, branches: $branches)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AuthState.branchPending'))
      ..add(DiagnosticsProperty('user', user))
      ..add(DiagnosticsProperty('branches', branches));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BranchPendingImpl &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._branches, _branches));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, user, const DeepCollectionEquality().hash(_branches));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BranchPendingImplCopyWith<_$BranchPendingImpl> get copyWith =>
      __$$BranchPendingImplCopyWithImpl<_$BranchPendingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unauthenticated,
    required TResult Function(User user, List<BranchDto> branches)
        branchPending,
    required TResult Function(User user) authenticated,
  }) {
    return branchPending(user, branches);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unauthenticated,
    TResult? Function(User user, List<BranchDto> branches)? branchPending,
    TResult? Function(User user)? authenticated,
  }) {
    return branchPending?.call(user, branches);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unauthenticated,
    TResult Function(User user, List<BranchDto> branches)? branchPending,
    TResult Function(User user)? authenticated,
    required TResult orElse(),
  }) {
    if (branchPending != null) {
      return branchPending(user, branches);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(BranchPending value) branchPending,
    required TResult Function(Authenticated value) authenticated,
  }) {
    return branchPending(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(BranchPending value)? branchPending,
    TResult? Function(Authenticated value)? authenticated,
  }) {
    return branchPending?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(BranchPending value)? branchPending,
    TResult Function(Authenticated value)? authenticated,
    required TResult orElse(),
  }) {
    if (branchPending != null) {
      return branchPending(this);
    }
    return orElse();
  }
}

abstract class BranchPending implements AuthState {
  const factory BranchPending(
      {required final User user,
      required final List<BranchDto> branches}) = _$BranchPendingImpl;

  User get user;
  List<BranchDto> get branches;
  @JsonKey(ignore: true)
  _$$BranchPendingImplCopyWith<_$BranchPendingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthenticatedImplCopyWith<$Res> {
  factory _$$AuthenticatedImplCopyWith(
          _$AuthenticatedImpl value, $Res Function(_$AuthenticatedImpl) then) =
      __$$AuthenticatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({User user});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthenticatedImpl>
    implements _$$AuthenticatedImplCopyWith<$Res> {
  __$$AuthenticatedImplCopyWithImpl(
      _$AuthenticatedImpl _value, $Res Function(_$AuthenticatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
  }) {
    return _then(_$AuthenticatedImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value));
    });
  }
}

/// @nodoc

class _$AuthenticatedImpl
    with DiagnosticableTreeMixin
    implements Authenticated {
  const _$AuthenticatedImpl({required this.user});

  @override
  final User user;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AuthState.authenticated(user: $user)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AuthState.authenticated'))
      ..add(DiagnosticsProperty('user', user));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticatedImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
      __$$AuthenticatedImplCopyWithImpl<_$AuthenticatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unauthenticated,
    required TResult Function(User user, List<BranchDto> branches)
        branchPending,
    required TResult Function(User user) authenticated,
  }) {
    return authenticated(user);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unauthenticated,
    TResult? Function(User user, List<BranchDto> branches)? branchPending,
    TResult? Function(User user)? authenticated,
  }) {
    return authenticated?.call(user);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unauthenticated,
    TResult Function(User user, List<BranchDto> branches)? branchPending,
    TResult Function(User user)? authenticated,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(BranchPending value) branchPending,
    required TResult Function(Authenticated value) authenticated,
  }) {
    return authenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(BranchPending value)? branchPending,
    TResult? Function(Authenticated value)? authenticated,
  }) {
    return authenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(BranchPending value)? branchPending,
    TResult Function(Authenticated value)? authenticated,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(this);
    }
    return orElse();
  }
}

abstract class Authenticated implements AuthState {
  const factory Authenticated({required final User user}) = _$AuthenticatedImpl;

  User get user;
  @JsonKey(ignore: true)
  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
