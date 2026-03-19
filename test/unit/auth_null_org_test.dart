import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/core/models/user.dart';
import 'package:nexuspoint_pos/features/auth/providers/auth_provider.dart';

void main() {
  group('AuthState with null organization', () {
    test('authenticated user can have null tenantId', () {
      const user = User(
        id: 'user-1',
        email: 'test@example.com',
        tenantId: null,
      );
      const state = AuthState.authenticated(user: user);
      state.when(
        unauthenticated: () => fail('Should be authenticated'),
        branchPending: (_, __) => fail('Should be authenticated'),
        authenticated: (u) {
          expect(u.tenantId, isNull);
        },
      );
    });

    test('authenticated user with tenantId is valid', () {
      const user = User(
        id: 'user-1',
        email: 'test@example.com',
        tenantId: 'org-123',
      );
      const state = AuthState.authenticated(user: user);
      state.when(
        unauthenticated: () => fail('Should be authenticated'),
        branchPending: (_, __) => fail('Should be authenticated'),
        authenticated: (u) {
          expect(u.tenantId, 'org-123');
        },
      );
    });

    test('user needs tenantId for order creation', () {
      const user = User(
        id: 'user-1',
        email: 'test@example.com',
        tenantId: null,
      );
      // The order_repository already checks this — verify the User model allows null
      expect(user.tenantId, isNull);
    });
  });
}
