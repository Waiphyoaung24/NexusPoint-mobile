import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

/// Default permission matrix matching server-side defaults (F-009).
/// Used as fallback when cached server matrix is unavailable.
const _defaultMatrix = <String, Map<UserRole, bool>>{
  'order.create':     {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: true, UserRole.waiter: true, UserRole.kitchen: false},
  'order.view':       {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: true, UserRole.waiter: true, UserRole.kitchen: true},
  'order.void':       {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: false},
  'order.cancel':     {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: false},
  'discount.apply':   {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: false},
  'refund.issue':     {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: false},
  'payment.process':  {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: true, UserRole.waiter: false, UserRole.kitchen: false},
  'menu.manage':      {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: false},
  'staff.manage':     {UserRole.owner: true, UserRole.manager: false, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: false},
  'report.view':      {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: false},
  'table.manage':     {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: false},
  'floorplan.edit':   {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: false},
  'zreport.generate': {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: false},
  'kds.view':         {UserRole.owner: true, UserRole.manager: true, UserRole.cashier: false, UserRole.waiter: false, UserRole.kitchen: true},
};

/// In-memory cache of server permission matrix, loaded from SharedPreferences.
Map<String, Map<UserRole, bool>>? _cachedServerMatrix;

/// Load the server permission matrix from SharedPreferences into memory.
/// Called on app startup and after branch selection.
Future<void> loadCachedPermissionMatrix() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString('cached_permission_matrix');
  if (json == null) {
    _cachedServerMatrix = null;
    return;
  }
  try {
    final list = jsonDecode(json) as List;
    final matrix = <String, Map<UserRole, bool>>{};
    for (final entry in list) {
      final role = _parseRole(entry['role'] as String?);
      final action = entry['action'] as String?;
      final allowed = entry['allowed'] as bool? ?? false;
      if (role != null && action != null) {
        matrix.putIfAbsent(action, () => {});
        matrix[action]![role] = allowed;
      }
    }
    _cachedServerMatrix = matrix;
  } catch (_) {
    _cachedServerMatrix = null;
  }
}

/// Save server permission matrix to SharedPreferences.
Future<void> savePermissionMatrix(List<Map<String, dynamic>> matrix) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('cached_permission_matrix', jsonEncode(matrix));
  await loadCachedPermissionMatrix();
}

/// Check if an action requires PIN for a given role (from cached matrix).
bool actionRequiresPin(UserRole? role, String action) {
  if (role == null) return false;
  // PIN requirement data is only in server matrix stored in SharedPreferences
  // For now, use hardcoded knowledge: manager + sensitive actions require PIN
  if (role == UserRole.owner) return false;
  if (role == UserRole.manager) {
    return const {
      'order.void', 'order.cancel', 'discount.apply',
      'refund.issue', 'zreport.generate',
    }.contains(action);
  }
  return false;
}

UserRole? _parseRole(String? value) {
  if (value == null) return null;
  for (final role in UserRole.values) {
    if (role.name == value) return role;
  }
  return null;
}

/// Check if a role has permission for an action.
/// Uses cached server matrix if available, falls back to hardcoded defaults.
bool hasPermission(UserRole? role, String action) {
  if (role == null) return false;
  final matrix = _cachedServerMatrix ?? _defaultMatrix;
  return matrix[action]?[role] ?? false;
}

/// Widget that conditionally shows its child based on user role + action.
/// Used for hiding UI elements the user's role can't access.
///
/// ```dart
/// PermissionGate(
///   role: user.staffRole,
///   action: 'order.void',
///   child: VoidButton(),
/// )
/// ```
class PermissionGate extends StatelessWidget {
  final UserRole? role;
  final String action;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.role,
    required this.action,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPermission(role, action)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
