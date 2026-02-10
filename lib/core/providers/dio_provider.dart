import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../api/api_service.dart';
import 'auth_token_provider.dart';

final cookieJarProvider = Provider<CookieJar>((ref) {
  throw UnimplementedError('cookieJarProvider must be overridden in main.dart');
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://420man.store/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'origin': 'https://420man.store',
    },
  ));

  // Cookie Manager
  final cookieJar = ref.watch(cookieJarProvider);
  dio.interceptors.add(CookieManager(cookieJar));

  // JWT Interceptor (Optional if using cookies, but kept for compatibility)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authTokenProvider);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired - clear and reject
          await ref.read(authTokenProvider.notifier).clearToken();
        }
        return handler.next(error);
      },
    ),
  );

  // Logging in debug mode
  if (kDebugMode) {
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
    ));
  }

  return dio;
});

final posApiServiceProvider = Provider<PosApiService>((ref) {
  return PosApiService(ref.watch(dioProvider));
});
