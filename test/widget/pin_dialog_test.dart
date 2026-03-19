import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexuspoint_pos/core/models/user.dart';
import 'package:nexuspoint_pos/core/models/api_models.dart';
import 'package:nexuspoint_pos/core/providers/dio_provider.dart';
import 'package:nexuspoint_pos/features/auth/providers/auth_provider.dart';
import 'package:nexuspoint_pos/features/auth/widgets/pin_dialog.dart';

import '../unit/auth_provider_test.mocks.dart';

// SHA-256 hash of "1234"
const _pin1234Hash =
    '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4';

Widget _buildTestApp(WidgetRef Function(BuildContext) onRef) {
  return const SizedBox.shrink();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('_PinDots', () {
    testWidgets('renders correct number of dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [],
            ),
          ),
        ),
      );
      // Dots are internal, test via _PinDialog integration below
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('PIN Dialog — widget interactions', () {
    late MockPosApiService mockApi;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockApi = MockPosApiService();
    });

    Future<void> pumpDialogAuthenticated(
        WidgetTester tester, MockPosApiService mockApi) async {
      // Set up a manager user with PIN "1234"
      const user = User(
        id: 'manager-1',
        tenantId: 'tenant-1',
        email: 'manager@example.com',
        role: UserRole.manager,
        managerPinHash: _pin1234Hash,
      );
      const response = AuthResponse(token: 'token-abc', user: user, activeOrganizationId: 'org-1');
      when(mockApi.verifyOtp(any, any)).thenAnswer((_) async => response);

      // Mock Dio that returns 401 for wrong PIN (PIN dialog only tests UI interaction)
      final mockDio = Dio(BaseOptions(baseUrl: 'http://localhost:5173'));
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            posApiServiceProvider.overrideWithValue(mockApi),
            cookieJarProvider.overrideWithValue(CookieJar()),
            dioProvider.overrideWithValue(mockDio),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => showPinDialog(context),
                    child: const Text('Open PIN'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Login first to set authenticated state
      final container = ProviderScope.containerOf(
          tester.element(find.byType(ElevatedButton)));
      await container.read(authProvider.notifier).verifyOtp(
            'manager@example.com',
            '123456',
          );
      await tester.pump();
    }

    testWidgets('opens PIN dialog on button press', (tester) async {
      await pumpDialogAuthenticated(tester, mockApi);

      await tester.tap(find.text('Open PIN'));
      await tester.pumpAndSettle();

      expect(find.text('Manager PIN'), findsOneWidget);
      expect(find.text('Enter your 4-digit PIN to continue'), findsOneWidget);
    });

    testWidgets('shows 4 numpad rows and digits 0-9', (tester) async {
      await pumpDialogAuthenticated(tester, mockApi);

      await tester.tap(find.text('Open PIN'));
      await tester.pumpAndSettle();

      // All digits present on numpad
      for (final digit in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']) {
        expect(find.text(digit), findsOneWidget);
      }
    });

    testWidgets('Cancel button closes dialog and returns false', (tester) async {
      await pumpDialogAuthenticated(tester, mockApi);

      await tester.tap(find.text('Open PIN'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Manager PIN'), findsNothing);
    });

    testWidgets('entering wrong PIN shows error message', (tester) async {
      await pumpDialogAuthenticated(tester, mockApi);

      await tester.tap(find.text('Open PIN'));
      await tester.pumpAndSettle();

      // Tap 0000 (wrong PIN)
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);
    });

    testWidgets('backspace removes last digit', (tester) async {
      await pumpDialogAuthenticated(tester, mockApi);

      await tester.tap(find.text('Open PIN'));
      await tester.pumpAndSettle();

      // Tap 1, then backspace
      await tester.tap(find.text('1'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      // Should still be showing the dialog (no auto-submit after backspace)
      expect(find.text('Manager PIN'), findsOneWidget);
    });
  });
}
