import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/api_models.dart';
import '../models/user.dart';
import 'api_exception.dart';

class PosApiService {
  final Dio _dio;

  PosApiService(this._dio);

    // tRPC Helpers

    Future<dynamic> _trpcQuery(String procedure, {Map<String, dynamic>? input}) async {

      // Try multiple formats for queries

      final formats = [

        // Format 1: Batched with JSON wrapper (tRPC 10+ with transformer)

        {'batch': '1', 'input': jsonEncode({"0": {"json": input}})},

        // Format 2: Batched without JSON wrapper (tRPC 10+ without transformer)

        {'batch': '1', 'input': jsonEncode({"0": input})},

        // Format 3: Non-batched with JSON wrapper

        {'input': jsonEncode({"json": input})},

        // Format 4: Non-batched without JSON wrapper

        {'input': jsonEncode(input)},

      ];

  

      DioException? lastError;

  

      for (final format in formats) {

        try {

          final response = await _dio.get(

            'trpc/$procedure',

            queryParameters: format,

          );

  

          final data = response.data;

          return _parseTrpcResponse(data, isBatch: format.containsKey('batch'));

        } on DioException catch (e) {

          lastError = e;

          debugPrint('⚠️  tRPC Query format attempt failed ($procedure): ${e.response?.statusCode} ${e.message}');

          if (e.response?.data != null) {

            debugPrint('📦 Error data: ${e.response?.data}');

          }

          

          // If it's a 404, the procedure might not exist, so don't keep trying formats

          if (e.response?.statusCode == 404) {

            debugPrint('❌ Procedure $procedure not found (404)');

            break;

          }

          continue;

        }

      }

  

      throw _handleError(lastError!);

    }

  

    Future<dynamic> _trpcMutation(String procedure, {Map<String, dynamic>? input}) async {

      // Try multiple formats for mutations

      final formats = [

        // Format 1: Batched with JSON wrapper (tRPC 10+ with transformer)

        {

          'params': {'batch': '1'},

          'data': {"0": {"json": input ?? {}}}

        },

        // Format 2: Non-batched with JSON wrapper (Most common for single mutations)

        {

          'params': <String, dynamic>{},

          'data': {"json": input ?? {}}

        },

        // Format 3: Non-batched without JSON wrapper

        {

          'params': <String, dynamic>{},

          'data': input ?? {}

        },

      ];

  

      DioException? lastError;

  

      for (final format in formats) {

        try {

          final response = await _dio.post(

            'trpc/$procedure',

            queryParameters: format['params'] as Map<String, dynamic>,

            data: format['data'],

          );

  

          final data = response.data;

          return _parseTrpcResponse(data, isBatch: (format['params'] as Map).containsKey('batch'));

        } on DioException catch (e) {

          lastError = e;

          debugPrint('⚠️  tRPC Mutation format attempt failed ($procedure): ${e.response?.statusCode} ${e.message}');

          if (e.response?.data != null) {

            debugPrint('📦 Error data: ${e.response?.data}');

          }

  

          // If it's a 404, the procedure might not exist

          if (e.response?.statusCode == 404) {

            debugPrint('❌ Procedure $procedure not found (404)');

            break;

          }

          // If it's a 400, it's likely a format error, so try the next one

          continue;

        }

      }

  

      throw _handleError(lastError!);

    }

  

    dynamic _parseTrpcResponse(dynamic data, {required bool isBatch}) {

      try {

        final dynamic resultObject = isBatch ? (data is List ? data[0] : data) : data;

        final result = resultObject['result'];

        

        if (result != null && result['data'] != null) {

          final resultData = result['data'];

          if (resultData is Map && resultData.containsKey('json')) {

            return resultData['json'];

          }

          return resultData;

        }

        

        if (result != null && result['error'] != null) {

          throw ApiException(result['error']['message'] ?? 'tRPC Error');

        }

      } catch (e) {

        if (e is ApiException) rethrow;

        debugPrint('⚠️  Error parsing tRPC response: $e');

      }

      return data;

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

        debugPrint('📦 Raw Auth Response: $data');

  

        // Extract session and user

        final session = data['session'] as Map<String, dynamic>?;

        final userData = data['user'] as Map<String, dynamic>;

  

        debugPrint('👤 User Data: $userData');

  

        // Extract activeOrganizationId from session

        final activeOrgId = session?['activeOrganizationId'] as String?;

        final token = session?['token'] as String? ?? data['token'] as String?;

  

        debugPrint('🏢 Active Organization ID: $activeOrgId');

  

        // Check for organizations in the response

        List<Organization>? organizations;

        final orgData = data['organizations'] ?? data['user']?['organizations'];

        if (orgData is List) {

          organizations = orgData.map((json) => Organization.fromJson(json)).toList();

          debugPrint('🏢 Found ${organizations.length} organizations in response');

        }

  

        // Set tenantId from activeOrganizationId

        if (activeOrgId != null && activeOrgId.isNotEmpty) {

          userData['tenantId'] = activeOrgId;

        }

  

        return AuthResponse(

          token: token ?? '',

          user: User.fromJson(userData),

          activeOrganizationId: activeOrgId,

          organizations: organizations,

        );

      } on DioException catch (e) {

        throw _handleError(e);

      }

    }

  

    // Orders

    Future<OrderResponse> createOrder(OrderRequest request) async {

      try {

        debugPrint('🛒 Creating order via tRPC: order.create');

        final data = await _trpcMutation('order.create', input: request.toJson());

        return OrderResponse.fromJson(data);

      } catch (e) {

        debugPrint('❌ order.create failed: $e');

        rethrow;

      }

    }

  

    /// Updates the status of an existing order on the server.
    /// Only call this when the order has already been synced (has a server orderId).
    Future<void> updateOrderStatus({
      required String orderId,
      required String status,
    }) async {
      try {
        debugPrint('🔄 Updating order status via tRPC: order.updateStatus');
        await _trpcMutation('order.updateStatus', input: {
          'orderId': orderId,
          'status': status,
        });
        debugPrint('✅ Order $orderId status updated to $status');
      } catch (e) {
        debugPrint('❌ order.updateStatus failed: $e');
        rethrow;
      }
    }

    Future<List<OrderResponse>> getOrders({

      required String tenantId,

      required String branchId,

      String? fromDate,

    }) async {

      try {

        debugPrint('📋 Fetching orders via tRPC: order.list');

        final data = await _trpcQuery('order.list', input: {

          'tenantId': tenantId,

          'branchId': branchId,

          if (fromDate != null) 'fromDate': fromDate,

        });

  

        if (data is List) {

          return data.map((json) => OrderResponse.fromJson(json)).toList();

        }

        return [];

      } catch (e) {

        debugPrint('❌ order.list failed: $e');

        rethrow;

      }

    }

  

    // User Organizations

    Future<Map<String, dynamic>> getSession() async {

      try {

        final response = await _dio.get('auth/get-session');

        debugPrint('📦 Session Response: ${response.data}');

        return response.data;

      } on DioException catch (e) {

        throw _handleError(e);

      }

    }

  

    Future<List<Organization>> getUserOrganizations() async {

      final procedures = [

        'organization.list',

        'organization.getUserOrganizations',

        'user.getOrganizations',

      ];

  

      for (final procedure in procedures) {

        try {

          debugPrint('🔍 Calling tRPC: $procedure');

          final data = await _trpcQuery(procedure);

          if (data is List) {

            debugPrint('✅ Got ${data.length} organizations from $procedure');

            return data.map((json) => Organization.fromJson(json)).toList();

          }

        } catch (e) {

          debugPrint('⚠️  tRPC $procedure failed: $e');

        }

      }

  

      // Fallback to REST endpoints

      final restEndpoints = [

        'organization/list',

        'v1/organizations',

        'auth/user-organizations',

      ];

  

      for (final endpoint in restEndpoints) {

        try {

          debugPrint('🔍 Calling REST: $endpoint');

          final response = await _dio.get(endpoint);

          final dynamic responseData = response.data;

  

          List<dynamic>? listData;

          if (responseData is List) {

            listData = responseData;

          } else if (responseData is Map) {

            listData = responseData['organizations'] ??

                responseData['data'] ??

                responseData['list'];

          }

  

          if (listData != null && listData is List) {

            debugPrint('✅ REST $endpoint worked!');

            return listData.map((json) => Organization.fromJson(json)).toList();

          }

        } catch (e) {

          debugPrint('⚠️  REST $endpoint failed: $e');

        }

      }

  

      debugPrint('❌ All organization list endpoints failed');

      return [];

    }

  

    Future<void> setActiveOrganization(String organizationId) async {

      debugPrint('🔄 Setting active organization: $organizationId');

  

      final procedures = [

        'organization.setActive',

        'user.setActiveOrganization',

      ];

  

      for (final procedure in procedures) {

        try {

          debugPrint('🔍 Calling tRPC: $procedure');

          await _trpcMutation(procedure, input: {

            'organizationId': organizationId,

          });

          debugPrint('✅ Active organization set successfully via $procedure');

          return;

        } catch (e) {

          debugPrint('⚠️  tRPC $procedure failed: $e');

        }

      }

  

      // Fallback to REST endpoints

      final restEndpoints = [

        'organization/setActive',

        'v1/organizations/setActive',

      ];

  

      for (final endpoint in restEndpoints) {

        try {

          debugPrint('🔍 Calling REST: $endpoint');

          await _dio.post(

            endpoint,

            data: {'organizationId': organizationId},

          );

          debugPrint('✅ REST $endpoint worked!');

          return;

        } catch (e) {

          debugPrint('⚠️  REST $endpoint failed: $e');

        }

      }

  

      throw ApiException('Failed to set active organization after trying all endpoints.');

    }

  

    Future<Organization> createOrganization({

      required String name,

      required String slug,

      String? description,

    }) async {

      try {

        debugPrint('🏢 Creating organization: $name ($slug)');

  

        // Use the correct tRPC mutation from backend: organization.create

        final data = await _trpcMutation('organization.create', input: {

          'name': name,

          'slug': slug,

          if (description != null) 'description': description,

        });

  

        debugPrint('✅ Organization created: ${data['id']}');

        return Organization.fromJson(data);

      } catch (e) {

        debugPrint('❌ Failed to create organization: $e');

        rethrow;

      }

    }

  

    // Menu Items

    Future<List<MenuItemDto>> getMenuItems(String tenantId) async {

      try {

        debugPrint('🍽️ Fetching menu items via tRPC: menu.listItems');

        final data = await _trpcQuery('menu.listItems');

        

        if (data is List) {

          return data.map((json) => MenuItemDto.fromJson(json)).toList();

        }

        return [];

      } catch (e) {

        debugPrint('❌ menu.listItems failed: $e');

        rethrow;

      }

    }

  

    Future<void> updateMenuItem(String id, Map<String, dynamic> updates) async {

      try {

        debugPrint('📝 Updating menu item via tRPC: menu.updateItem');

        await _trpcMutation('menu.updateItem', input: {

          'id': id,

          ...updates,

        });

      } catch (e) {

        debugPrint('❌ menu.updateItem failed: $e');

        rethrow;

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
