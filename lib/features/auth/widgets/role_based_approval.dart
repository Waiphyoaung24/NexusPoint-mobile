import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/approval_result.dart';
import '../../../core/models/user.dart';
import '../../../core/utils/permission_gate.dart';
import '../providers/auth_provider.dart';
import 'manager_approval_dialog.dart';
import 'pin_dialog.dart';

/// Role-based approval flow for sensitive actions (F-009).
///
/// - **Owner:** bypasses PIN entirely, returns self as approver.
/// - **Manager:** shows PIN-only dialog for self-verification.
/// - **Cashier/Waiter:** shows manager dropdown + PIN dialog.
/// - **Kitchen / not allowed:** returns null (action should be gated by PermissionGate).
///
/// Returns [ApprovalResult] if approved, null if cancelled or denied.
Future<ApprovalResult?> showRoleBasedApproval(
  BuildContext context, {
  required WidgetRef ref,
  required String action,
}) async {
  final authState = ref.read(authProvider);
  final user = authState.whenOrNull(
    authenticated: (user) => user,
  );
  if (user == null) return null;

  final role = user.staffRole ?? user.role;

  // Check if role is allowed for this action
  if (!hasPermission(role, action)) return null;

  // Owner: bypass PIN entirely
  if (role == UserRole.owner) {
    return ApprovalResult(approverId: user.id, pinVerified: false);
  }

  // Manager: enter own PIN
  if (role == UserRole.manager) {
    if (!context.mounted) return null;
    final verified = await showPinDialog(context);
    if (!verified) return null;
    return ApprovalResult(approverId: user.id);
  }

  // Cashier / Waiter: show manager selection + PIN
  final branchId = user.branchId ?? '';
  final managers = AuthNotifier.cachedManagers
      .map((m) => ManagerInfo(
            id: m['id'] as String? ?? m['userId'] as String? ?? '',
            name: _extractName(m),
            role: m['staffRole'] as String? ?? 'manager',
          ))
      .where((m) => m.id.isNotEmpty)
      .toList();

  if (managers.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No managers available for approval'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    return null;
  }

  if (!context.mounted) return null;

  final approvedManagerId = await showManagerApprovalDialog(
    context,
    branchId: branchId,
    managers: managers,
  );

  if (approvedManagerId == null) return null;
  return ApprovalResult(approverId: approvedManagerId);
}

String _extractName(Map<String, dynamic> manager) {
  final userObj = manager['user'];
  if (userObj is Map<String, dynamic>) {
    return userObj['name'] as String? ??
        userObj['email'] as String? ??
        'Manager';
  }
  return manager['name'] as String? ?? 'Manager';
}
