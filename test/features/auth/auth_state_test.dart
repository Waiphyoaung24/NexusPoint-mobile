import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/features/auth/providers/auth_provider.dart';
import 'package:nexuspoint_pos/core/models/user.dart';
import 'package:nexuspoint_pos/core/models/branch_dto.dart';

void main() {
  final testUser = User(id: 'u1', email: 'test@test.com', tenantId: 'org1');
  final branches = [
    BranchDto(id: 'b1', organizationId: 'org1', name: 'Main', isActive: true),
    BranchDto(id: 'b2', organizationId: 'org1', name: 'Branch 2', isActive: true),
  ];

  group('AuthState', () {
    test('branchPending holds user and branches', () {
      final state = AuthState.branchPending(user: testUser, branches: branches);
      state.when(
        unauthenticated: () => fail('wrong state'),
        branchPending: (user, b) {
          expect(user.id, 'u1');
          expect(b.length, 2);
        },
        authenticated: (_, __) => fail('wrong state'),
      );
    });

    test('authenticated holds user with branchId', () {
      final userWithBranch = testUser.copyWith(branchId: 'b1');
      final state = AuthState.authenticated(user: userWithBranch);
      state.when(
        unauthenticated: () => fail('wrong state'),
        branchPending: (_, __) => fail('wrong state'),
        authenticated: (user, attempts) {
          expect(user.branchId, 'b1');
          expect(attempts, 0);
        },
      );
    });
  });
}
