import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../../core/models/branch_dto.dart';
import '../../../core/models/user.dart';
import '../../../core/models/api_models.dart';
import '../../../core/api/api_service.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/auth_token_provider.dart';
import '../../../core/utils/permission_gate.dart';

part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.branchPending({
    required User user,
    required List<BranchDto> branches,
  }) = BranchPending;
  const factory AuthState.authenticated({
    required User user,
  }) = Authenticated;
}

class PinLockoutException implements Exception {
  final String message;
  PinLockoutException(this.message);
}

class MultipleOrganizationsException implements Exception {
  final String message;
  final List<Organization> organizations;

  MultipleOrganizationsException(this.message, {required this.organizations});

  @override
  String toString() => message;
}

/// Internal signal — not a real error. Used to pass branch list up the call chain.
class _MultipleBranchesResult implements Exception {
  final List<BranchDto> branches;
  _MultipleBranchesResult(this.branches);
}

class _BranchFetchResult {
  final User user;
  final List<BranchDto> branches;
  _BranchFetchResult(this.user, this.branches);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  /// Completes once the initial session-restore check has finished.
  /// Useful in tests to `await container.read(authProvider.notifier).initialized`.
  late final Future<void> initialized;

  AuthNotifier(this.ref) : super(const AuthState.unauthenticated()) {
    initialized = _loadCachedAuth();
  }

  Future<void> _loadCachedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    // Read token directly from prefs — authTokenProvider may not have
    // finished its own async load yet, so we can't rely on its state here.
    final token = prefs.getString('auth_token');

    // Load cached permission matrix and manager list into memory (F-009)
    await loadCachedPermissionMatrix();
    await loadCachedManagers();

    if (userJson != null && token != null) {
      var user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);

      // If branchId is missing from cache, try fetching it.
      // This covers the case where the user was cached before branch support was added.
      if (user.branchId == null && user.tenantId != null) {
        try {
          final api = ref.read(posApiServiceProvider);
          final result = await _fetchAndSetBranch(api, user);
          user = result.user;
          await _cacheBranches(prefs, result.branches);
          await prefs.setString('current_user', jsonEncode(user.toJson()));
          state = AuthState.authenticated(user: user);
        } on _MultipleBranchesResult catch (result) {
          state = AuthState.branchPending(user: user, branches: result.branches);
        } catch (e) {
          debugPrint('⚠️  Branch fetch on cached auth failed: $e');
          // Still authenticate with null branchId — floor plan will show error
          state = AuthState.authenticated(user: user);
        }
      } else {
        state = AuthState.authenticated(user: user);
      }
    }
  }

  /// Fetches branches. If single, auto-selects. If multiple, throws _MultipleBranchesResult.
  Future<_BranchFetchResult> _fetchAndSetBranch(PosApiService api, User user) async {
    try {
      final branches = await api.getBranches();
      if (branches.isEmpty) {
        debugPrint('⚠️  No active branches found for organization');
        return _BranchFetchResult(user, []);
      }
      if (branches.length == 1) {
        final branchId = branches.first.id;
        debugPrint('🏪 Auto-selected branch: ${branches.first.name} ($branchId)');
        return _BranchFetchResult(user.copyWith(branchId: branchId), branches);
      }
      // Multiple branches — caller must handle branchPending state
      debugPrint('🏪 ${branches.length} branches found — user must select');
      throw _MultipleBranchesResult(branches);
    } catch (e) {
      if (e is _MultipleBranchesResult) rethrow;
      debugPrint('⚠️  Failed to fetch branches: $e');
      return _BranchFetchResult(user, []);
    }
  }

  /// Persists branch list to SharedPreferences for branch name display.
  Future<void> _cacheBranches(SharedPreferences prefs, List<BranchDto> branches) async {
    if (branches.isNotEmpty) {
      final branchListJson = branches.map((b) => {
        'id': b.id,
        'organizationId': b.organizationId,
        'name': b.name,
        'address': b.address,
        'isActive': b.isActive,
      }).toList();
      await prefs.setString('cached_branches', jsonEncode(branchListJson));
    }
  }

  /// Called from BranchSelectionScreen when user taps a branch card.
  /// Transitions from branchPending → authenticated.
  Future<void> selectBranch(String branchId) async {
    final current = state;
    if (current is! BranchPending) return;

    final user = current.user.copyWith(branchId: branchId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toJson()));

    // Also persist the branch list for potential re-use on switch
    await _cacheBranches(prefs, current.branches);

    // Fetch and cache permission matrix + manager list for this branch (F-009)
    await _fetchPermissionsAndManagers(branchId);

    debugPrint('🏪 Branch selected: $branchId');
    state = AuthState.authenticated(user: user);
  }

  /// Fetches permission matrix and manager list from server, caches locally.
  /// Called after branch selection and on app resume. Failures are non-fatal.
  Future<void> _fetchPermissionsAndManagers(String branchId) async {
    final api = ref.read(posApiServiceProvider);
    final prefs = await SharedPreferences.getInstance();

    // Fetch permission matrix
    try {
      final matrix = await api.getPermissionMatrix();
      await savePermissionMatrix(matrix);
      debugPrint('🔐 Permission matrix cached (${matrix.length} rows)');
    } catch (e) {
      debugPrint('⚠️ Permission matrix fetch failed (using defaults): $e');
      // Non-fatal — fall back to hardcoded defaults
    }

    // Fetch manager list for PIN approval dropdown
    try {
      final managers = await api.listManagers(branchId);
      await prefs.setString('cached_branch_managers', jsonEncode(managers));
      await loadCachedManagers();
      debugPrint('👥 Manager list cached (${managers.length} managers)');
    } catch (e) {
      debugPrint('⚠️ Manager list fetch failed: $e');
      // Non-fatal — manager approval dialog will show empty list
    }
  }

  /// Called from settings to switch branches.
  /// Transitions authenticated → branchPending.
  Future<void> switchBranch() async {
    final current = state;
    if (current is! Authenticated) return;

    final api = ref.read(posApiServiceProvider);
    try {
      final branches = await api.getBranches();
      if (branches.isEmpty) {
        debugPrint('⚠️  No branches found for switch');
        return;
      }
      // Cache fresh branch list
      final prefs = await SharedPreferences.getInstance();
      await _cacheBranches(prefs, branches);

      if (branches.length == 1) {
        // Only one branch, just re-select it directly
        final user = current.user.copyWith(branchId: branches.first.id);
        await prefs.setString('current_user', jsonEncode(user.toJson()));
        state = AuthState.authenticated(user: user);
        return;
      }
      // Multiple branches — show picker
      final user = current.user.copyWith(branchId: null);
      state = AuthState.branchPending(user: user, branches: branches);
    } catch (e) {
      debugPrint('❌ Branch switch failed: $e');
    }
  }

  Future<void> requestOtp(String email) async {
    final api = ref.read(posApiServiceProvider);
    await api.requestOtp(email);
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final api = ref.read(posApiServiceProvider);
      final response = await api.verifyOtp(email, otp);

      // Save token first
      await ref.read(authTokenProvider.notifier).setToken(response.token);

      debugPrint('📧 Email: ${response.user.email}');
      debugPrint('🏢 Active Organization ID: ${response.activeOrganizationId}');

      // Check if user has active organization
      if (response.activeOrganizationId == null ||
          response.activeOrganizationId!.isEmpty) {
        debugPrint('⚠️  No active organization - checking initial response, session and organizations...');

        // 1. Check if organizations were already in the auth response
        List<Organization> organizations = response.organizations ?? [];
        
        if (organizations.isEmpty) {
          // 2. Try to get session data
          try {
            final sessionData = await api.getSession();
            debugPrint('📦 Session data: $sessionData');

            final session = sessionData['session'] as Map<String, dynamic>?;
            final activeOrgId = session?['activeOrganizationId'] as String?;

            if (activeOrgId != null && activeOrgId.isNotEmpty) {
              debugPrint('✅ Found activeOrganizationId in session: $activeOrgId');
              var userWithOrg = response.user.copyWith(tenantId: activeOrgId);
              try {
                final result = await _fetchAndSetBranch(api, userWithOrg);
                userWithOrg = result.user;
                final prefs = await SharedPreferences.getInstance();
                await _cacheBranches(prefs, result.branches);
                await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));
                state = AuthState.authenticated(user: userWithOrg);
                return true;
              } on _MultipleBranchesResult catch (result) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));
                state = AuthState.branchPending(user: userWithOrg, branches: result.branches);
                return true;
              }
            }
          } catch (e) {
            debugPrint('⚠️  Session check failed: $e');
          }

          // 3. Fetch user's organizations from multiple possible endpoints
          try {
            organizations = await api.getUserOrganizations();
          } catch (e) {
            debugPrint('❌ Failed to fetch organizations: $e');
          }
        }

        debugPrint('🏢 Found ${organizations.length} organizations');

        if (organizations.isEmpty) {
          // ❌ User has no organizations
          debugPrint('❌ User has no organizations');
          debugPrint('');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('  🏢 NO ORGANIZATIONS FOUND');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('');
          debugPrint('This user account is not associated with any organization.');
          debugPrint('');
          debugPrint('To fix this:');
          debugPrint('1. Create an organization in your backend database');
          debugPrint('2. Assign this user (${response.user.id}) to the organization');
          debugPrint('3. Set the organization as active for the user');
          debugPrint('');
          debugPrint('See: scripts/seed_organization.sql for SQL commands');
          debugPrint('Or:  scripts/create_test_organization.sh for API method');
          debugPrint('');
          debugPrint('User ID: ${response.user.id}');
          debugPrint('Email:   ${response.user.email}');
          debugPrint('═══════════════════════════════════════════════════════════════');
          throw Exception(
            'No organizations found.\n\n'
            'Your account needs to be added to an organization.\n'
            'Please contact your system administrator or see the console for setup instructions.'
          );
        } else if (organizations.length == 1) {
          // ✅ Auto-select single organization
          debugPrint('✅ Auto-selecting single organization: ${organizations.first.name}');
          await api.setActiveOrganization(organizations.first.id);

          // Refresh session to get updated activeOrganizationId
          final sessionData = await api.getSession();
          final session = sessionData['session'] as Map<String, dynamic>;
          final activeOrgId = session['activeOrganizationId'] as String?;

          if (activeOrgId != null && activeOrgId.isNotEmpty) {
            debugPrint('✅ Active Organization ID set: $activeOrgId');
            var userWithOrg = response.user.copyWith(tenantId: activeOrgId);
            try {
              final result = await _fetchAndSetBranch(api, userWithOrg);
              userWithOrg = result.user;
              final prefs = await SharedPreferences.getInstance();
              await _cacheBranches(prefs, result.branches);
              await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));
              state = AuthState.authenticated(user: userWithOrg);
              return true;
            } on _MultipleBranchesResult catch (result) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));
              state = AuthState.branchPending(user: userWithOrg, branches: result.branches);
              return true;
            }
          } else {
            throw Exception('Failed to set active organization');
          }
        } else {
          // 🎯 Multiple organizations - need user to choose
          debugPrint('🎯 Multiple organizations found: ${organizations.length}');
          // TODO: Show organization picker UI
          throw MultipleOrganizationsException(
            'Please select an organization',
            organizations: organizations,
          );
        }
      } else {
        // ✅ User already has active organization
        debugPrint('✅ Active Organization ID: ${response.activeOrganizationId}');
        var userWithOrg = response.user.copyWith(
          tenantId: response.activeOrganizationId,
        );
        try {
          final result = await _fetchAndSetBranch(api, userWithOrg);
          userWithOrg = result.user;
          final prefs = await SharedPreferences.getInstance();
          await _cacheBranches(prefs, result.branches);
          await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));
          state = AuthState.authenticated(user: userWithOrg);
          return true;
        } on _MultipleBranchesResult catch (result) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));
          state = AuthState.branchPending(user: userWithOrg, branches: result.branches);
          return true;
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Verify OTP Exception: $e');
      debugPrint('Stack trace: $stack');
      return false;
    }
  }

  /// Verify Manager PIN — online via server, offline via cached hash (F-009).
  /// Returns true if PIN is correct, throws on lockout or error.
  Future<bool> verifyManagerPin(
    String managerId,
    String pin,
    String branchId,
  ) async {
    // Try server-side verification first
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/api/trpc/staff.verifyManagerPin',
        data: {
          'json': {
            'managerId': managerId,
            'pin': pin,
            'branchId': branchId,
          },
        },
      );

      final result = response.data?['result']?['data']?['json'];
      return result?['verified'] == true;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;

      if (statusCode == 429) {
        final message =
            errorData?['error']?['message'] ?? 'PIN locked. Try again later.';
        throw PinLockoutException(message);
      } else if (statusCode == 401) {
        return false;
      }

      // Network error — fall through to offline verification
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint('📴 Offline — verifying PIN against cached hash');
        return _verifyPinOffline(managerId, pin);
      }

      debugPrint('❌ Manager PIN verification error: $e');
      rethrow;
    }
  }

  /// Offline PIN verification using cached manager PIN hash (F-009).
  /// SHA-256 hashes the input PIN and compares to cached managerPinHash.
  bool _verifyPinOffline(String managerId, String pin) {
    final prefs = _getCachedManagers();
    if (prefs == null) return false;

    for (final manager in prefs) {
      if (manager['id'] == managerId || manager['userId'] == managerId) {
        final storedHash = manager['managerPinHash'] as String?;
        if (storedHash == null || storedHash.isEmpty) return false;
        final inputHash = sha256.convert(utf8.encode(pin)).toString();
        return inputHash == storedHash;
      }
    }
    return false;
  }

  /// Get cached managers list from SharedPreferences (synchronous from memory).
  List<Map<String, dynamic>>? _getCachedManagers() {
    // This is called from sync context — use cached value
    // The actual loading happens in _fetchPermissionsAndManagers
    return _cachedManagersList;
  }

  /// In-memory cache of managers list, loaded from SharedPreferences.
  static List<Map<String, dynamic>>? _cachedManagersList;

  /// Load cached managers from SharedPreferences into memory.
  static Future<void> loadCachedManagers() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('cached_branch_managers');
    if (json == null) {
      _cachedManagersList = null;
      return;
    }
    try {
      _cachedManagersList = (jsonDecode(json) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      _cachedManagersList = null;
    }
  }

  /// Get the cached managers list (for use in approval dialogs).
  static List<Map<String, dynamic>> get cachedManagers =>
      _cachedManagersList ?? [];

  Future<void> logout() async {
    await ref.read(authTokenProvider.notifier).clearToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.remove('cached_branches');
    await prefs.remove('cached_permission_matrix');
    await prefs.remove('cached_branch_managers');

    state = const AuthState.unauthenticated();
  }
}
