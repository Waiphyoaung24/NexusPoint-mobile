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
      const response = AuthResponse(token: 'test-token', user: user);

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
      const response = AuthResponse(token: 'test-token-123', user: user);

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
      const response = AuthResponse(token: 'test-token', user: user);

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

  group('AuthProvider - Manager PIN', () {
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

      // Login first to enable PIN verification
      const user = User(
        id: 'user-1',
        tenantId: 'tenant-1',
        email: 'manager@example.com',
        role: UserRole.manager,
        // SHA-256 hash of "1234"
        managerPinHash:
            '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',
      );
      const response = AuthResponse(token: 'test-token', user: user);

      when(mockApi.verifyOtp(any, any)).thenAnswer((_) async => response);
      await container
          .read(authProvider.notifier)
          .verifyOtp('manager@example.com', '123456');
    });

    tearDown(() {
      container.dispose();
    });

    test('verifyManagerPin with correct PIN returns true', () async {
      // Act
      final success =
          await container.read(authProvider.notifier).verifyManagerPin('1234');

      // Assert
      expect(success, isTrue);

      final authState = container.read(authProvider);
      authState.whenOrNull(
        authenticated: (user, failedAttempts) {
          expect(failedAttempts, 0);
        },
      );
    });

    test('verifyManagerPin with incorrect PIN returns false', () async {
      // Act
      final success =
          await container.read(authProvider.notifier).verifyManagerPin('0000');

      // Assert
      expect(success, isFalse);

      final authState = container.read(authProvider);
      authState.whenOrNull(
        authenticated: (user, failedAttempts) {
          expect(failedAttempts, 1);
        },
      );
    });

    test('verifyManagerPin locks out after 3 failed attempts', () async {
      // Act - 3 failed attempts
      await container.read(authProvider.notifier).verifyManagerPin('0000');
      await container.read(authProvider.notifier).verifyManagerPin('0000');

      // Assert - 3rd attempt throws exception
      expect(
        () =>
            container.read(authProvider.notifier).verifyManagerPin('0000'),
        throwsA(isA<PinLockoutException>()),
      );
    });

    test('resetPinAttempts resets failed attempts counter', () async {
      // Arrange - Fail once
      await container.read(authProvider.notifier).verifyManagerPin('0000');

      var authState = container.read(authProvider);
      authState.whenOrNull(
        authenticated: (user, failedAttempts) {
          expect(failedAttempts, 1);
        },
      );

      // Act - Reset
      container.read(authProvider.notifier).resetPinAttempts();

      // Assert
      authState = container.read(authProvider);
      authState.whenOrNull(
        authenticated: (user, failedAttempts) {
          expect(failedAttempts, 0);
        },
      );
    });

    test('successful PIN verification resets failed attempts', () async {
      // Arrange - Fail once
      await container.read(authProvider.notifier).verifyManagerPin('0000');

      var authState = container.read(authProvider);
      authState.whenOrNull(
        authenticated: (user, failedAttempts) {
          expect(failedAttempts, 1);
        },
      );

      // Act - Succeed
      final success =
          await container.read(authProvider.notifier).verifyManagerPin('1234');

      // Assert
      expect(success, isTrue);

      authState = container.read(authProvider);
      authState.whenOrNull(
        authenticated: (user, failedAttempts) {
          expect(failedAttempts, 0);
        },
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
      const response = AuthResponse(token: 'test-token-persist', user: user);

      when(mockApi.verifyOtp(email, otp)).thenAnswer((_) async => response);

      // Act - Login
      await container1.read(authProvider.notifier).verifyOtp(email, otp);

      // Verify persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), 'test-token-persist');
      expect(prefs.getString('current_user'), contains('user-1'));

      container1.dispose();
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
      const response = AuthResponse(token: 'test-token', user: user);

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
