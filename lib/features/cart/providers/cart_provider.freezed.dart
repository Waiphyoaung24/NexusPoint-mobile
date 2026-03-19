// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CartState {
  List<CartItem> get items => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get discountPercent => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  double get tax => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  double get vatRate => throw _privateConstructorUsedError;
  String? get discountApproverId => throw _privateConstructorUsedError;
  String? get discountReason => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CartStateCopyWith<CartState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartStateCopyWith<$Res> {
  factory $CartStateCopyWith(CartState value, $Res Function(CartState) then) =
      _$CartStateCopyWithImpl<$Res, CartState>;
  @useResult
  $Res call(
      {List<CartItem> items,
      double subtotal,
      double discountPercent,
      double discountAmount,
      double tax,
      double total,
      double vatRate,
      String? discountApproverId,
      String? discountReason});
}

/// @nodoc
class _$CartStateCopyWithImpl<$Res, $Val extends CartState>
    implements $CartStateCopyWith<$Res> {
  _$CartStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? subtotal = null,
    Object? discountPercent = null,
    Object? discountAmount = null,
    Object? tax = null,
    Object? total = null,
    Object? vatRate = null,
    Object? discountApproverId = freezed,
    Object? discountReason = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItem>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      discountPercent: null == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as double,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      tax: null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      vatRate: null == vatRate
          ? _value.vatRate
          : vatRate // ignore: cast_nullable_to_non_nullable
              as double,
      discountApproverId: freezed == discountApproverId
          ? _value.discountApproverId
          : discountApproverId // ignore: cast_nullable_to_non_nullable
              as String?,
      discountReason: freezed == discountReason
          ? _value.discountReason
          : discountReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartStateImplCopyWith<$Res>
    implements $CartStateCopyWith<$Res> {
  factory _$$CartStateImplCopyWith(
          _$CartStateImpl value, $Res Function(_$CartStateImpl) then) =
      __$$CartStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<CartItem> items,
      double subtotal,
      double discountPercent,
      double discountAmount,
      double tax,
      double total,
      double vatRate,
      String? discountApproverId,
      String? discountReason});
}

/// @nodoc
class __$$CartStateImplCopyWithImpl<$Res>
    extends _$CartStateCopyWithImpl<$Res, _$CartStateImpl>
    implements _$$CartStateImplCopyWith<$Res> {
  __$$CartStateImplCopyWithImpl(
      _$CartStateImpl _value, $Res Function(_$CartStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? subtotal = null,
    Object? discountPercent = null,
    Object? discountAmount = null,
    Object? tax = null,
    Object? total = null,
    Object? vatRate = null,
    Object? discountApproverId = freezed,
    Object? discountReason = freezed,
  }) {
    return _then(_$CartStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItem>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      discountPercent: null == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as double,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      tax: null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      vatRate: null == vatRate
          ? _value.vatRate
          : vatRate // ignore: cast_nullable_to_non_nullable
              as double,
      discountApproverId: freezed == discountApproverId
          ? _value.discountApproverId
          : discountApproverId // ignore: cast_nullable_to_non_nullable
              as String?,
      discountReason: freezed == discountReason
          ? _value.discountReason
          : discountReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CartStateImpl extends _CartState {
  const _$CartStateImpl(
      {final List<CartItem> items = const [],
      this.subtotal = 0.0,
      this.discountPercent = 0.0,
      this.discountAmount = 0.0,
      this.tax = 0.0,
      this.total = 0.0,
      this.vatRate = 0.07,
      this.discountApproverId,
      this.discountReason})
      : _items = items,
        super._();

  final List<CartItem> _items;
  @override
  @JsonKey()
  List<CartItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final double subtotal;
  @override
  @JsonKey()
  final double discountPercent;
  @override
  @JsonKey()
  final double discountAmount;
  @override
  @JsonKey()
  final double tax;
  @override
  @JsonKey()
  final double total;
  @override
  @JsonKey()
  final double vatRate;
  @override
  final String? discountApproverId;
  @override
  final String? discountReason;

  @override
  String toString() {
    return 'CartState(items: $items, subtotal: $subtotal, discountPercent: $discountPercent, discountAmount: $discountAmount, tax: $tax, total: $total, vatRate: $vatRate, discountApproverId: $discountApproverId, discountReason: $discountReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.vatRate, vatRate) || other.vatRate == vatRate) &&
            (identical(other.discountApproverId, discountApproverId) ||
                other.discountApproverId == discountApproverId) &&
            (identical(other.discountReason, discountReason) ||
                other.discountReason == discountReason));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      subtotal,
      discountPercent,
      discountAmount,
      tax,
      total,
      vatRate,
      discountApproverId,
      discountReason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CartStateImplCopyWith<_$CartStateImpl> get copyWith =>
      __$$CartStateImplCopyWithImpl<_$CartStateImpl>(this, _$identity);
}

abstract class _CartState extends CartState {
  const factory _CartState(
      {final List<CartItem> items,
      final double subtotal,
      final double discountPercent,
      final double discountAmount,
      final double tax,
      final double total,
      final double vatRate,
      final String? discountApproverId,
      final String? discountReason}) = _$CartStateImpl;
  const _CartState._() : super._();

  @override
  List<CartItem> get items;
  @override
  double get subtotal;
  @override
  double get discountPercent;
  @override
  double get discountAmount;
  @override
  double get tax;
  @override
  double get total;
  @override
  double get vatRate;
  @override
  String? get discountApproverId;
  @override
  String? get discountReason;
  @override
  @JsonKey(ignore: true)
  _$$CartStateImplCopyWith<_$CartStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
