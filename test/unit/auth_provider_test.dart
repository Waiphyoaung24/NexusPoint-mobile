import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexuspoint_pos/core/api/api_service.dart';
import 'package:nexuspoint_pos/core/models/api_models.dart';
import 'package:nexuspoint_pos/core/models/user.dart';
import 'package:nexuspoint_pos/features/auth/providers/auth_provider.dart';
import 'package:nexuspoint_pos/core/providers/dio_provider.dart';
import 'package:nexuspoint_pos/core/providers/auth_token_provider.dart';

@GenerateMocks([PosApiService])
import 'auth_provider_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider - OTP Flow', () {
    late MockPosApiService mockApi;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockApi = MockPosApiService();

      container = ProviderContainer(
        overrides: [
          posApiServiceProvider.overrideWithValue(mockApi),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is unauthenticated', () {
      final authState = container.read(authProvider);
      expect(authState, isA<Unauthenticated>());
    });

    test('requestOtp calls API successfully', () async {
      // Arrange
      const email = 'test@example.com';
      when(mockApi.requestOtp(email)).thenAnswer((_) async => {});

      // Act
      await container.read(authProvider.notifier).requestOtp(email);

      // Assert
      verify(mockApi.requestOtp(email)).called(1);
    });

    test('requestOtp throws exception on API error', () async {
      // Arrange
      const email = 'test@example.com';
      when(mockApi.requestOtp(email))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => container.read(authProvider.notifier).requestOtp(email),
        throwsException,
      );
    });

    test('verifyOtp with valid OTP sets authenticated state', () async {
      // Arrange
      const email = 'test@example.com';
      const otp = '123456';
      const user = User(
        id: 'user-1',
        tenantId: 'tenant-1',
        email: email,
        role: UserRole.cashier,
      );
      const response = AuthResponse(token: 'test-token', user: user, activeOrganizationId: 'org-1');

      when(mockApi.verifyOtp(email, otp)).thenAnswer((_) async => response);

      // Act
      final success =
          await container.read(authProvider.notifier).verifyOtp(email, otp);

      // Assert
      expect(success, isTrue);
      verify(mockApi.verifyOtp(email, otp)).called(1);

      final authState = container.read(authProvider);
      expect(authState, isA<Authenticated>());
      authState.whenOrNull(
        authenticated: (u, _) {
          expect(u.id, 'user-1');
          expect(u.email, email);
          expect(u.role, UserRole.cashier);
        },
      );
    });

    test('verifyOtp with invalid OTP returns false', () async {
      // Arrange
      const email = 'test@example.com';
      const otp = '000000';

      when(mockApi.verifyOtp(email, otp))
          .thenThrow(Exception('Invalid OTP'));

      // Act
      final success =
          await container.read(authProvider.notifier).verifyOtp(email, otp);

      // Assert
      expect(success, isFalse);

      final authState = container.read(authProvider);
      expect(authState, isA<Unauthenticated>());
    });

    test('verifyOtp saves token to SharedPreferences', () async {
      // Arrange
      const email = 'test@example.com';
      const otp = '123456';
      const user = User(
        id: 'user-1',
        tenantId: 'tenant-1',
        email: email,
        role: UserRole.cashier,
      );
      const response = AuthResponse(token: 'test-token-123', user: user, activeOrganizationId: 'org-1');

      when(mockApi.verifyOtp(email, otp)).thenAnswer((_) async => response);

      // Act
      await container.read(authProvider.notifier).verifyOtp(email, otp);

      // Assert
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedUser = prefs.getString('current_user');

      expect(savedToken, 'test-token-123');
      expect(savedUser, isNotNull);
      expect(savedUser, contains('user-1'));
    });

    test('logout clears token and user', () async {
      // Arrange - First login
      const email = 'test@example.com';
      const otp = '123456';
      const user = User(
        id: 'user-1',
        tenantId: 'tenant-1',
        email: email,
        role: UserRole.cashier,
      );
      const response = AuthResponse(token: 'test-token', user: user, activeOrganizationId: 'org-1');

      when(mockApi.verifyOtp(email, otp)).thenAnswer((_) async => response);
      await container.read(authProvider.notifier).verifyOtp(email, otp);

      // Verify logged in
      var authState = container.read(authProvider);
      expect(authState, isA<Authenticated>());

      // Act - Logout
      await container.read(authProvider.notifier).logout();

      // Assert
      authState = container.read(authProvider);
      expect(authState, isA<Unauthenticated>());

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('current_user'), isNull);
    });
  });

  group('AuthProvider - Manager PIN (server-side)', () {
    late MockPosApiService mockApi;
    late ProviderContainer container;
    late Dio mockDio;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockApi = MockPosApiService();

      // Create a Dio instance with a mock interceptor for PIN verification
      mockDio = Dio(BaseOptions(baseUrl: 'http://localhost:5173'));

      container = ProviderContainer(
        overrides: [
          posApiServiceProvider.overrideWithValue(mockApi),
          cookieJarProvider.overrideWithValue(CookieJar()),
          dioProvider.overrideWithValue(mockDio),
        ],
      );

      // Login first to enable PIN verification
      const user = User(
        id: 'user-1',
        tenantId: 'tenant-1',
        email: 'manager@example.com',
        role: UserRole.manager,
        managerPinHash:
            '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',
      );
      const response = AuthResponse(token: 'test-token', user: user, activeOrganizationId: 'org-1');

      when(mockApi.verifyOtp(any, any)).thenAnswer((_) async => response);
      await container
          .read(authProvider.notifier)
          .verifyOtp('manager@example.com', '123456');
    });

    tearDown(() {
      container.dispose();
    });

    test('verifyManagerPin with correct PIN returns true', () async {
      // Mock successful response
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'result': {'data': {'json': {'verified': true}}}},
          ));
        },
      ));

      final success = await container
          .read(authProvider.notifier)
          .verifyManagerPin('user-1', '1234', '');

      expect(success, isTrue);
    });

    test('verifyManagerPin with incorrect PIN returns false (401)', () async {
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'error': {'message': 'Invalid PIN'}},
            ),
            type: DioExceptionType.badResponse,
          ));
        },
      ));

      final success = await container
          .read(authProvider.notifier)
          .verifyManagerPin('user-1', '0000', '');

      expect(success, isFalse);
    });

    test('verifyManagerPin throws PinLockoutException on 429', () async {
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 429,
              data: {'error': {'message': 'PIN locked. Try again in 5 minutes.'}},
            ),
            type: DioExceptionType.badResponse,
          ));
        },
      ));

      expect(
        () => container
            .read(authProvider.notifier)
            .verifyManagerPin('user-1', '0000', ''),
        throwsA(isA<PinLockoutException>()),
      );
    });
  });

  group('AuthProvider - Cached Authentication', () {
    late MockPosApiService mockApi;

    setUp(() async {
      mockApi = MockPosApiService();
    });

    test('verifyOtp persists auth for next session', () async {
      // Arrange - Fresh login
      SharedPreferences.setMockInitialValues({});

      final container1 = ProviderContainer(
        overrides: [
          posApiServiceProvider.overrideWithValue(mockApi),
        ],
      );

      const email = 'test@example.com';
      const otp = '123456';
      const user = User(
        id: 'user-1',
        tenantId: 'tenant-1',
        email: email,
        role: UserRole.cashier,
      );
      const response = AuthResponse(token: 'test-token-persist', user: user, activeOrganizationId: 'org-1');

      when(mockApi.verifyOtp(email, otp)).thenAnswer((_) async => response);

      // Act - Login
      await container1.read(authProvider.notifier).verifyOtp(email, otp);

      // Verify persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), 'test-token-persist');
      expect(prefs.getString('current_user'), contains('user-1'));

      container1.dispose();
    });

    test('restores authenticated state from SharedPreferences on init', () async {
      // Arrange — simulate a device that was previously logged in
      SharedPreferences.setMockInitialValues({
        'auth_token': 'persisted-token',
        'current_user': '{"id":"user-42","email":"returning@example.com",'
            '"tenantId":"org-1","role":"cashier","isActive":true}',
      });

      final container = ProviderContainer(
        overrides: [
          posApiServiceProvider.overrideWithValue(mockApi),
        ],
      );

      // Wait for _loadCachedAuth() to complete
      await container.read(authProvider.notifier).initialized;

      // Assert — should be authenticated without any network call
      final authState = container.read(authProvider);
      expect(authState, isA<Authenticated>());
      authState.whenOrNull(
        authenticated: (user, _) {
          expect(user.id, 'user-42');
          expect(user.email, 'returning@example.com');
        },
      );
      verifyNever(mockApi.verifyOtp(any, any));

      container.dispose();
    });

    test('stays unauthenticated when only user json is cached (no token)', () async {
      // Token missing — should NOT restore session
      SharedPreferences.setMockInitialValues({
        'current_user': '{"id":"user-1","email":"test@example.com",'
            '"tenantId":"org-1","role":"cashier","isActive":true}',
      });

      final container = ProviderContainer(
        overrides: [
          posApiServiceProvider.overrideWithValue(mockApi),
        ],
      );

      await container.read(authProvider.notifier).initialized;

      expect(container.read(authProvider), isA<Unauthenticated>());

      container.dispose();
    });

    test('logout clears persisted auth', () async {
      // Arrange - Set up cached data
      SharedPreferences.setMockInitialValues({
        'auth_token': 'cached-token-123',
        'current_user': '{"id":"user-1","email":"cached@example.com",'
            '"tenantId":"tenant-1","role":"cashier","isActive":true}'
      });

      final container = ProviderContainer(
        overrides: [
          posApiServiceProvider.overrideWithValue(mockApi),
        ],
      );

      // Setup authenticated state manually
      const user = User(
        id: 'user-1',
        tenantId: 'tenant-1',
        email: 'test@example.com',
        role: UserRole.cashier,
      );
      const response = AuthResponse(token: 'test-token', user: user, activeOrganizationId: 'org-1');

      when(mockApi.verifyOtp(any, any)).thenAnswer((_) async => response);
      await container.read(authProvider.notifier).verifyOtp('test@example.com', '123456');

      // Act - Logout
      await container.read(authProvider.notifier).logout();

      // Assert - Verify cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('current_user'), isNull);

      container.dispose();
    });
  });
}
