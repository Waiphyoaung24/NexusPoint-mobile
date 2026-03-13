import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';
import 'user.dart';

part 'api_models.freezed.dart';
part 'api_models.g.dart';

double _parsePrice(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

// Auth
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String token,
    required User user,
    String? activeOrganizationId,
    List<Organization>? organizations,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class SessionResponse with _$SessionResponse {
  const factory SessionResponse({
    required Map<String, dynamic> session,
    required User user,
  }) = _SessionResponse;

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseFromJson(json);
}

@freezed
class Organization with _$Organization {
  const factory Organization({
    required String id,
    required String name,
    String? role,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
}

// Orders

/// Local DTO — used for SQLite storage and cart display.
/// Field names are Flutter-centric (skuId, unitPrice as double).
@freezed
class OrderItemDto with _$OrderItemDto {
  const factory OrderItemDto({
    required String skuId,
    String? name,
    required int quantity,
    @JsonKey(fromJson: _parsePrice) required double unitPrice,
    String? notes,
  }) = _OrderItemDto;

  factory OrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderItemDtoFromJson(json);
}

/// Backend DTO — matches the Zod schema expected by order.create.
/// Uses menuItemId, price as string ("50.00").
/// Also handles old-format queue items via [_normalizeBackendOrderItem].
@freezed
class BackendOrderItemDto with _$BackendOrderItemDto {
  const factory BackendOrderItemDto({
    required String menuItemId,
    required String name,
    required int quantity,
    required String price, // decimal string e.g. "50.00"
    String? notes,
  }) = _BackendOrderItemDto;

  factory BackendOrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$BackendOrderItemDtoFromJson(_normalizeBackendOrderItem(json));

  /// Convert a local [OrderItemDto] to the backend shape.
  static BackendOrderItemDto fromOrderItemDto(OrderItemDto dto) =>
      BackendOrderItemDto(
        menuItemId: dto.skuId,
        name: dto.name ?? dto.skuId,
        quantity: dto.quantity,
        price: dto.unitPrice.toStringAsFixed(2),
        notes: dto.notes,
      );

  /// Build a raw JSON map that includes structured modifier data.
  /// Used by [OrderRepository] when the caller provides selected modifiers.
  static Map<String, dynamic> toJsonWithModifiers(
    OrderItemDto dto,
    List<SelectedModifierOption> modifiers,
  ) {
    return {
      'menuItemId': dto.skuId,
      'name': dto.name ?? dto.skuId,
      'quantity': dto.quantity,
      'price': dto.unitPrice.toStringAsFixed(2),
      if (dto.notes != null) 'notes': dto.notes,
      if (modifiers.isNotEmpty)
        'modifiers': modifiers
            .map((m) => {
                  'modifierOptionId': m.optionId,
                  'name': m.name,
                  'priceAdjustment': m.priceAdjustment.toStringAsFixed(2),
                })
            .toList(),
    };
  }
}

/// Normalizes old-format items stored in the sync queue (skuId/unitPrice)
/// so they can be deserialized into [BackendOrderItemDto].
Map<String, dynamic> _normalizeBackendOrderItem(Map<String, dynamic> json) {
  return {
    'menuItemId': json['menuItemId'] ?? json['skuId'] ?? '',
    'name': json['name'] ?? json['menuItemId'] ?? json['skuId'] ?? '',
    'quantity': json['quantity'] ?? 1,
    'price': json['price'] ??
        (json['unitPrice'] != null
            ? (json['unitPrice'] as num).toStringAsFixed(2)
            : '0.00'),
    if (json['notes'] != null) 'notes': json['notes'],
  };
}

/// Backend request DTO — matches the Zod schema for order.create exactly.
/// Fields not in the backend schema (tenantId, paymentMethod) are omitted.
@freezed
class OrderRequest with _$OrderRequest {
  @JsonSerializable(explicitToJson: true)
  const factory OrderRequest({
    String? branchId,
    required String source,
    String? orderType,
    String? tableId,
    String? createdBy,
    String? vatAmount,
    String? vatRate,
    required List<BackendOrderItemDto> items,
    required String subtotal, // decimal string e.g. "100.00"
    required String total, // decimal string e.g. "100.00"
    String? discount,
    String? notes,
  }) = _OrderRequest;

  /// Handles both new-format payloads (subtotal/total) and old-format payloads
  /// from the sync queue (totalAmount as double).
  factory OrderRequest.fromJson(Map<String, dynamic> json) =>
      _$OrderRequestFromJson(_normalizeOrderRequest(json));
}

/// Normalizes old-format sync queue payloads (totalAmount as double) into the
/// current backend shape (subtotal/total as strings).
Map<String, dynamic> _normalizeOrderRequest(Map<String, dynamic> json) {
  final fallbackAmount = json['totalAmount'] != null
      ? (json['totalAmount'] as num).toStringAsFixed(2)
      : '0.00';
  return {
    ...json,
    'subtotal': json['subtotal'] ?? fallbackAmount,
    'total': json['total'] ?? fallbackAmount,
  };
}

@freezed
class OrderResponse with _$OrderResponse {
  const factory OrderResponse({
    required String orderId,
    @JsonKey(name: 'order_number', defaultValue: '') String? orderNumber,
    required String status,
    @JsonKey(fromJson: _parsePrice) @Default(0.0) double totalAmount,
    required DateTime createdAt,
    @Default('pos') String source,
    @Default([]) List<BackendOrderItemDto> items,
  }) = _OrderResponse;

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(_normalizeOrderResponse(json));
}

/// Normalizes API/DB response field names to Flutter model field names.
/// Handles snake_case DB fields and camelCase tRPC fields.
Map<String, dynamic> _normalizeOrderResponse(Map<String, dynamic> json) {
  return {
    // id or orderId
    'orderId': json['orderId'] ?? json['id'] ?? '',
    // order_number or orderNumber (null when absent — field is nullable)
    'order_number': json['order_number'] ?? json['orderNumber'],
    'status': json['status'] ?? 'pending',
    // total, subtotal, or totalAmount
    'totalAmount':
        json['totalAmount'] ?? json['total'] ?? json['subtotal'] ?? 0.0,
    // created_at or createdAt
    'createdAt': json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
    // source (pos, grab, etc.)
    'source': json['source'] ?? 'pos',
    // items from backend response
    if (json['items'] != null) 'items': json['items'],
  };
}

// Modifiers
@freezed
class ModifierOptionDto with _$ModifierOptionDto {
  const factory ModifierOptionDto({
    required String id,
    required String modifierGroupId,
    String? organizationId,
    required String name,
    String? nameTh,
    @JsonKey(fromJson: _parsePrice) @Default(0.0) double priceAdjustment,
    @Default(false) bool isDefault,
    @Default(true) bool isActive,
    int? sortOrder,
  }) = _ModifierOptionDto;

  factory ModifierOptionDto.fromJson(Map<String, dynamic> json) =>
      _$ModifierOptionDtoFromJson(json);
}

@freezed
class ModifierGroupDto with _$ModifierGroupDto {
  const factory ModifierGroupDto({
    required String id,
    String? organizationId,
    required String name,
    String? nameTh,
    @Default(false) bool isRequired,
    int? minSelections,
    int? maxSelections,
    int? sortOrder,
    @Default(true) bool isActive,
    @Default([]) List<ModifierOptionDto> options,
  }) = _ModifierGroupDto;

  factory ModifierGroupDto.fromJson(Map<String, dynamic> json) =>
      _$ModifierGroupDtoFromJson(json);
}

@freezed
class ItemModifierLinkDto with _$ItemModifierLinkDto {
  const factory ItemModifierLinkDto({
    required String id,
    required String menuItemId,
    required String modifierGroupId,
    int? sortOrder,
  }) = _ItemModifierLinkDto;

  factory ItemModifierLinkDto.fromJson(Map<String, dynamic> json) =>
      _$ItemModifierLinkDtoFromJson(json);
}

@freezed
class MenuWithModifiersDto with _$MenuWithModifiersDto {
  const factory MenuWithModifiersDto({
    required List<MenuItemDto> items,
    required List<ModifierGroupDto> modifierGroups,
    required List<ItemModifierLinkDto> itemModifierLinks,
  }) = _MenuWithModifiersDto;

  factory MenuWithModifiersDto.fromJson(Map<String, dynamic> json) =>
      _$MenuWithModifiersDtoFromJson(json);
}

// Menu
@freezed
class MenuItemDto with _$MenuItemDto {
  const factory MenuItemDto({
    required String id,
    String? organizationId,
    String? branchId,
    required String sku,
    required String name,
    String? nameTh,
    String? description,
    @JsonKey(fromJson: _parsePrice) required double price,
    String? category,
    String? imageUrl,
    @JsonKey(name: 'isAvailable') required bool isAvailable,
    @JsonKey(name: 'sortOrder') int? sortOrder,
  }) = _MenuItemDto;

  factory MenuItemDto.fromJson(Map<String, dynamic> json) =>
      _$MenuItemDtoFromJson(json);
}
