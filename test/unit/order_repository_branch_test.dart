import 'package:flutter_test/flutter_test.dart';
import 'package:nexuspoint_pos/core/models/user.dart';

void main() {
  group('User branchId', () {
    test('User has branchId field', () {
      const user = User(
        id: 'user-1',
        email: 'test@example.com',
        tenantId: 'org-1',
        branchId: 'branch-main',
      );
      expect(user.branchId, 'branch-main');
    });

    test('branchId defaults to null', () {
      const user = User(
        id: 'user-1',
        email: 'test@example.com',
      );
      expect(user.branchId, isNull);
    });

    test('User serializes branchId to JSON', () {
      const user = User(
        id: 'user-1',
        email: 'test@example.com',
        branchId: 'branch-main',
      );
      final json = user.toJson();
      expect(json['branchId'], 'branch-main');
    });

    test('User deserializes branchId from JSON', () {
      final user = User.fromJson({
        'id': 'user-1',
        'email': 'test@example.com',
        'branchId': 'branch-main',
      });
      expect(user.branchId, 'branch-main');
    });
  });
}
