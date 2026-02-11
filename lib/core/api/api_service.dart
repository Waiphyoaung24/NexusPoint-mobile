import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/api_models.dart';
import '../models/user.dart';
import 'api_exception.dart';

class PosApiService {
  final Dio _dio;

  PosApiService(this._dio);

  // tRPC Helpers
  Future<dynamic> _trpcGet(String procedure, {Map<String, dynamic>? input}) async {
    final inputJson = jsonEncode({
      "0": {"json": input}
    });

    try {
      final response = await _dio.get(
        'trpc/$procedure',
        queryParameters: {
          'batch': 1,
          'input': inputJson,
        },
      );

      final data = response.data;
      if (data is List && data.isNotEmpty) {
        final result = data[0]['result'];
        if (result != null && result['data'] != null) {
          return result['data']['json'];
        }
        if (result != null && result['error'] != null) {
          throw ApiException(result['error']['message'] ?? 'tRPC Error');
        }
      }
      throw ApiException('Invalid tRPC response format');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Authentication
  Future<void> requestOtp(String email) async {
    try {
      await _dio.post(
        'auth/email-otp/send-verification-otp',
        data: {
          'email': email,
          'type': 'sign-in',
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        'auth/sign-in/email-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );
      
      final data = response.data;
      print('Raw Auth Response: $data');
      
      return AuthResponse(
        token: data['token'] ?? '',
        user: User.fromJson(data['user']),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Orders
  Future<OrderResponse> createOrder(OrderRequest request) async {
    try {
      final response = await _dio.post(
        'v1/orders',
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
        'v1/orders',
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
        'v1/menu-items',
        queryParameters: {
          'tenant_id': tenantId,
        },
      );
      
      final data = response.data;
      if (data is List) {
        return data.map((json) => MenuItemDto.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateMenuItem(String id, Map<String, dynamic> updates) async {
    try {
      await _dio.patch(
        'v1/menu-items/$id',
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
