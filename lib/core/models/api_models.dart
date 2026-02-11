import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'api_models.freezed.dart';
part 'api_models.g.dart';

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
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

// Orders
@freezed
class OrderItemDto with _$OrderItemDto {
  const factory OrderItemDto({
    required String skuId,
    required int quantity,
    required double unitPrice,
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
    required double totalAmount,
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
    required String orderNumber,
    required String status,
    required DateTime createdAt,
  }) = _OrderResponse;

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);
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
    required double price,
    String? category,
    String? imageUrl,
    @JsonKey(name: 'is_available') required bool isAvailable,
    @JsonKey(name: 'sort_order') int? sortOrder,
  }) = _MenuItemDto;

  factory MenuItemDto.fromJson(Map<String, dynamic> json) =>
      _$MenuItemDtoFromJson(json);
}
