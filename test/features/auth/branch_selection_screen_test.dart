import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuspoint_pos/features/auth/widgets/branch_selection_screen.dart';
import 'package:nexuspoint_pos/core/models/user.dart';
import 'package:nexuspoint_pos/core/models/branch_dto.dart';

void main() {
  final testUser = User(id: 'u1', email: 'test@test.com', tenantId: 'org1');
  final branches = [
    BranchDto(id: 'b1', organizationId: 'org1', name: 'Main Branch', address: '123 Main St', isActive: true),
    BranchDto(id: 'b2', organizationId: 'org1', name: 'Second Branch', address: '456 Oak Ave', isActive: true),
  ];

  testWidgets('renders branch cards for each branch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: BranchSelectionScreen(user: testUser, branches: branches),
        ),
      ),
    );

    // Allow staggered animations to complete
    await tester.pumpAndSettle();

    expect(find.text('Main Branch'), findsOneWidget);
    expect(find.text('Second Branch'), findsOneWidget);
    expect(find.text('123 Main St'), findsOneWidget);
    expect(find.text('Select your branch'), findsOneWidget);
  });

  testWidgets('shows logged in email', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: BranchSelectionScreen(user: testUser, branches: branches),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Logged in as test@test.com'), findsOneWidget);
  });
}
