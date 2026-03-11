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
    @Default(0) int failedPinAttempts,
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
          print('⚠️  Branch fetch on cached auth failed: $e');
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
        print('⚠️  No active branches found for organization');
        return _BranchFetchResult(user, []);
      }
      if (branches.length == 1) {
        final branchId = branches.first.id;
        print('🏪 Auto-selected branch: ${branches.first.name} ($branchId)');
        return _BranchFetchResult(user.copyWith(branchId: branchId), branches);
      }
      // Multiple branches — caller must handle branchPending state
      print('🏪 ${branches.length} branches found — user must select');
      throw _MultipleBranchesResult(branches);
    } catch (e) {
      if (e is _MultipleBranchesResult) rethrow;
      print('⚠️  Failed to fetch branches: $e');
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

    print('🏪 Branch selected: $branchId');
    state = AuthState.authenticated(user: user);
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
        print('⚠️  No branches found for switch');
        return;
      }
      if (branches.length == 1) {
        // Only one branch, just re-select it directly
        final user = current.user.copyWith(branchId: branches.first.id);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', jsonEncode(user.toJson()));
        state = AuthState.authenticated(user: user);
        return;
      }
      // Multiple branches — show picker
      final user = current.user.copyWith(branchId: null);
      state = AuthState.branchPending(user: user, branches: branches);
    } catch (e) {
      print('❌ Branch switch failed: $e');
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

      print('📧 Email: ${response.user.email}');
      print('🏢 Active Organization ID: ${response.activeOrganizationId}');

      // Check if user has active organization
      if (response.activeOrganizationId == null ||
          response.activeOrganizationId!.isEmpty) {
        print('⚠️  No active organization - checking initial response, session and organizations...');

        // 1. Check if organizations were already in the auth response
        List<Organization> organizations = response.organizations ?? [];
        
        if (organizations.isEmpty) {
          // 2. Try to get session data
          try {
            final sessionData = await api.getSession();
            print('📦 Session data: $sessionData');

            final session = sessionData['session'] as Map<String, dynamic>?;
            final activeOrgId = session?['activeOrganizationId'] as String?;

            if (activeOrgId != null && activeOrgId.isNotEmpty) {
              print('✅ Found activeOrganizationId in session: $activeOrgId');
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
            print('⚠️  Session check failed: $e');
          }

          // 3. Fetch user's organizations from multiple possible endpoints
          try {
            organizations = await api.getUserOrganizations();
          } catch (e) {
            print('❌ Failed to fetch organizations: $e');
          }
        }

        print('🏢 Found ${organizations.length} organizations');

        if (organizations.isEmpty) {
          // ❌ User has no organizations
          print('❌ User has no organizations');
          print('');
          print('═══════════════════════════════════════════════════════════════');
          print('  🏢 NO ORGANIZATIONS FOUND');
          print('═══════════════════════════════════════════════════════════════');
          print('');
          print('This user account is not associated with any organization.');
          print('');
          print('To fix this:');
          print('1. Create an organization in your backend database');
          print('2. Assign this user (${response.user.id}) to the organization');
          print('3. Set the organization as active for the user');
          print('');
          print('See: scripts/seed_organization.sql for SQL commands');
          print('Or:  scripts/create_test_organization.sh for API method');
          print('');
          print('User ID: ${response.user.id}');
          print('Email:   ${response.user.email}');
          print('═══════════════════════════════════════════════════════════════');
          throw Exception(
            'No organizations found.\n\n'
            'Your account needs to be added to an organization.\n'
            'Please contact your system administrator or see the console for setup instructions.'
          );
        } else if (organizations.length == 1) {
          // ✅ Auto-select single organization
          print('✅ Auto-selecting single organization: ${organizations.first.name}');
          await api.setActiveOrganization(organizations.first.id);

          // Refresh session to get updated activeOrganizationId
          final sessionData = await api.getSession();
          final session = sessionData['session'] as Map<String, dynamic>;
          final activeOrgId = session['activeOrganizationId'] as String?;

          if (activeOrgId != null && activeOrgId.isNotEmpty) {
            print('✅ Active Organization ID set: $activeOrgId');
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
          print('🎯 Multiple organizations found: ${organizations.length}');
          // TODO: Show organization picker UI
          throw MultipleOrganizationsException(
            'Please select an organization',
            organizations: organizations,
          );
        }
      } else {
        // ✅ User already has active organization
        print('✅ Active Organization ID: ${response.activeOrganizationId}');
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
      print('❌ Verify OTP Exception: $e');
      print('Stack trace: $stack');
      return false;
    }
  }

  Future<bool> verifyManagerPin(String pin) async {
    return state.maybeWhen(
      authenticated: (user, failedAttempts) async {
        final hashedPin = _hashPin(pin);

        if (user.managerPinHash == hashedPin) {
          // Success - reset attempts
          state = AuthState.authenticated(user: user, failedPinAttempts: 0);
          return true;
        } else {
          // Failure - increment attempts
          final newAttempts = failedAttempts + 1;
          state = AuthState.authenticated(user: user, failedPinAttempts: newAttempts);

          // Lock after 3 attempts
          if (newAttempts >= 3) {
            throw PinLockoutException('Too many failed attempts');
          }

          return false;
        }
      },
      orElse: () async => false,
    );
  }

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  void resetPinAttempts() {
    state.whenOrNull(
      authenticated: (user, _) {
        state = AuthState.authenticated(user: user, failedPinAttempts: 0);
      },
    );
  }

  Future<void> logout() async {
    await ref.read(authTokenProvider.notifier).clearToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');

    state = const AuthState.unauthenticated();
  }
}
