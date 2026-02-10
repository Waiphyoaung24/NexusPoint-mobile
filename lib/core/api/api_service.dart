import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_exception.dart';

class PosApiService {
  final Dio _dio;
  final String baseUrl;

  PosApiService(this._dio, {this.baseUrl = 'https://api.420man.store'}) {
    _dio.options.baseUrl = baseUrl;
  }

  // Authentication
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Orders
  Future<OrderResponse> createOrder(OrderRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/orders',
        data: request.toJson(),
      );
      return OrderResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<OrderResponse>> getOrders({
    required String tenantId,
    required String branchId,
    String? fromDate,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/orders',
        queryParameters: {
          'tenant_id': tenantId,
          'branch_id': branchId,
          if (fromDate != null) 'from_date': fromDate,
        },
      );
      return (response.data as List)
          .map((json) => OrderResponse.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Menu Items
  Future<List<MenuItemDto>> getMenuItems(String tenantId) async {
    try {
      final response = await _dio.get(
        '/api/v1/menu-items',
        queryParameters: {'tenant_id': tenantId},
      );
      return (response.data as List)
          .map((json) => MenuItemDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateMenuItem(String id, Map<String, dynamic> updates) async {
    try {
      await _dio.patch(
        '/api/v1/menu-items/$id',
        data: updates,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException('Connection timeout');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException('Network connection failed');
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return UnauthorizedException();
    }

    if (statusCode == 403) {
      return ForbiddenException();
    }

    if (statusCode != null && statusCode >= 500) {
      return ServerException('Server error: $statusCode');
    }

    return ApiException(
      error.message ?? 'Unknown error',
      statusCode: statusCode,
    );
  }
}
