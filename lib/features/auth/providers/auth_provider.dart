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

      // If branchId is missing from cache, try fetching it in the background.
      // This covers the case where the user was cached before branch support was added.
      if (user.branchId == null && user.tenantId != null) {
        state = AuthState.authenticated(user: user);
        try {
          final api = ref.read(posApiServiceProvider);
          user = await _fetchAndSetBranch(api, user);
          await prefs.setString('current_user', jsonEncode(user.toJson()));
          state = AuthState.authenticated(user: user);
        } catch (e) {
          print('⚠️  Branch fetch on cached auth failed (will retry on next open): $e');
        }
      } else {
        state = AuthState.authenticated(user: user);
      }
    }
  }

  /// Fetches the first active branch for the user's organization and sets
  /// [User.branchId]. Returns the updated user. If no branches are found
  /// or the call fails, the user is returned unchanged.
  Future<User> _fetchAndSetBranch(PosApiService api, User user) async {
    try {
      final branches = await api.getBranches();
      if (branches.isNotEmpty) {
        final branchId = branches.first.id;
        print('🏪 Auto-selected branch: ${branches.first.name} ($branchId)');
        return user.copyWith(branchId: branchId);
      } else {
        print('⚠️  No active branches found for organization');
      }
    } catch (e) {
      print('⚠️  Failed to fetch branches: $e');
    }
    return user;
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
              userWithOrg = await _fetchAndSetBranch(api, userWithOrg);

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));

              state = AuthState.authenticated(user: userWithOrg);
              return true;
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
            userWithOrg = await _fetchAndSetBranch(api, userWithOrg);

            // Save user with organization
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));

            state = AuthState.authenticated(user: userWithOrg);
            return true;
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
        userWithOrg = await _fetchAndSetBranch(api, userWithOrg);

        // Save user with organization
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));

        state = AuthState.authenticated(user: userWithOrg);
        return true;
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
