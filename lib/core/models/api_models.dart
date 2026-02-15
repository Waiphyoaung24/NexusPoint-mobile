import 'package:freezed_annotation/freezed_annotation.dart';
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

@freezed
class OrderRequest with _$OrderRequest {
  const factory OrderRequest({
    required String tenantId,
    required String branchId,
    required String source,
    required List<OrderItemDto> items,
    @JsonKey(fromJson: _parsePrice) required double totalAmount,
    required String paymentMethod,
    String? tableNumber,
  }) = _OrderRequest;

  factory OrderRequest.fromJson(Map<String, dynamic> json) =>
      _$OrderRequestFromJson(json);
}

@freezed
class OrderResponse with _$OrderResponse {
  const factory OrderResponse({
    required String orderId,
    @JsonKey(name: 'order_number', defaultValue: '') String? orderNumber,
    required String status,
    @JsonKey(fromJson: _parsePrice, defaultValue: 0.0) double totalAmount,
    required DateTime createdAt,
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
  };
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
