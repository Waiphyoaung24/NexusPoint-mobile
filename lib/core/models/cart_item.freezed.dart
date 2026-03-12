// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CartItem _$CartItemFromJson(Map<String, dynamic> json) {
  return _CartItem.fromJson(json);
}

/// @nodoc
mixin _$CartItem {
  MenuItem get menuItem => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parsePrice)
  double get unitPrice => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseModifiers, toJson: _modifiersToJson)
  List<SelectedModifierOption> get selectedModifiers =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CartItemCopyWith<CartItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemCopyWith<$Res> {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) then) =
      _$CartItemCopyWithImpl<$Res, CartItem>;
  @useResult
  $Res call(
      {MenuItem menuItem,
      int quantity,
      @JsonKey(fromJson: _parsePrice) double unitPrice,
      String? notes,
      @JsonKey(fromJson: _parseModifiers, toJson: _modifiersToJson)
      List<SelectedModifierOption> selectedModifiers});

  $MenuItemCopyWith<$Res> get menuItem;
}

/// @nodoc
class _$CartItemCopyWithImpl<$Res, $Val extends CartItem>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItem = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? notes = freezed,
    Object? selectedModifiers = null,
  }) {
    return _then(_value.copyWith(
      menuItem: null == menuItem
          ? _value.menuItem
          : menuItem // ignore: cast_nullable_to_non_nullable
              as MenuItem,
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
      selectedModifiers: null == selectedModifiers
          ? _value.selectedModifiers
          : selectedModifiers // ignore: cast_nullable_to_non_nullable
              as List<SelectedModifierOption>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MenuItemCopyWith<$Res> get menuItem {
    return $MenuItemCopyWith<$Res>(_value.menuItem, (value) {
      return _then(_value.copyWith(menuItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartItemImplCopyWith<$Res>
    implements $CartItemCopyWith<$Res> {
  factory _$$CartItemImplCopyWith(
          _$CartItemImpl value, $Res Function(_$CartItemImpl) then) =
      __$$CartItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MenuItem menuItem,
      int quantity,
      @JsonKey(fromJson: _parsePrice) double unitPrice,
      String? notes,
      @JsonKey(fromJson: _parseModifiers, toJson: _modifiersToJson)
      List<SelectedModifierOption> selectedModifiers});

  @override
  $MenuItemCopyWith<$Res> get menuItem;
}

/// @nodoc
class __$$CartItemImplCopyWithImpl<$Res>
    extends _$CartItemCopyWithImpl<$Res, _$CartItemImpl>
    implements _$$CartItemImplCopyWith<$Res> {
  __$$CartItemImplCopyWithImpl(
      _$CartItemImpl _value, $Res Function(_$CartItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItem = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? notes = freezed,
    Object? selectedModifiers = null,
  }) {
    return _then(_$CartItemImpl(
      menuItem: null == menuItem
          ? _value.menuItem
          : menuItem // ignore: cast_nullable_to_non_nullable
              as MenuItem,
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
      selectedModifiers: null == selectedModifiers
          ? _value._selectedModifiers
          : selectedModifiers // ignore: cast_nullable_to_non_nullable
              as List<SelectedModifierOption>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartItemImpl extends _CartItem {
  const _$CartItemImpl(
      {required this.menuItem,
      required this.quantity,
      @JsonKey(fromJson: _parsePrice) required this.unitPrice,
      this.notes,
      @JsonKey(fromJson: _parseModifiers, toJson: _modifiersToJson)
      final List<SelectedModifierOption> selectedModifiers = const []})
      : _selectedModifiers = selectedModifiers,
        super._();

  factory _$CartItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartItemImplFromJson(json);

  @override
  final MenuItem menuItem;
  @override
  final int quantity;
  @override
  @JsonKey(fromJson: _parsePrice)
  final double unitPrice;
  @override
  final String? notes;
  final List<SelectedModifierOption> _selectedModifiers;
  @override
  @JsonKey(fromJson: _parseModifiers, toJson: _modifiersToJson)
  List<SelectedModifierOption> get selectedModifiers {
    if (_selectedModifiers is EqualUnmodifiableListView)
      return _selectedModifiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedModifiers);
  }

  @override
  String toString() {
    return 'CartItem(menuItem: $menuItem, quantity: $quantity, unitPrice: $unitPrice, notes: $notes, selectedModifiers: $selectedModifiers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemImpl &&
            (identical(other.menuItem, menuItem) ||
                other.menuItem == menuItem) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality()
                .equals(other._selectedModifiers, _selectedModifiers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, menuItem, quantity, unitPrice,
      notes, const DeepCollectionEquality().hash(_selectedModifiers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      __$$CartItemImplCopyWithImpl<_$CartItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartItemImplToJson(
      this,
    );
  }
}

abstract class _CartItem extends CartItem {
  const factory _CartItem(
      {required final MenuItem menuItem,
      required final int quantity,
      @JsonKey(fromJson: _parsePrice) required final double unitPrice,
      final String? notes,
      @JsonKey(fromJson: _parseModifiers, toJson: _modifiersToJson)
      final List<SelectedModifierOption> selectedModifiers}) = _$CartItemImpl;
  const _CartItem._() : super._();

  factory _CartItem.fromJson(Map<String, dynamic> json) =
      _$CartItemImpl.fromJson;

  @override
  MenuItem get menuItem;
  @override
  int get quantity;
  @override
  @JsonKey(fromJson: _parsePrice)
  double get unitPrice;
  @override
  String? get notes;
  @override
  @JsonKey(fromJson: _parseModifiers, toJson: _modifiersToJson)
  List<SelectedModifierOption> get selectedModifiers;
  @override
  @JsonKey(ignore: true)
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
