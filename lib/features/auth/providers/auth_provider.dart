import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../../core/models/user.dart';
import '../../../core/models/api_models.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/auth_token_provider.dart';

part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.authenticated({
    required User user,
    @Default(0) int failedPinAttempts,
  }) = Authenticated;
}

class PinLockoutException implements Exception {
  final String message;
  PinLockoutException(this.message);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState.unauthenticated()) {
    _loadCachedAuth();
  }

  Future<void> _loadCachedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');

    if (userJson != null && ref.read(authTokenProvider) != null) {
      final user = User.fromJson(jsonDecode(userJson));
      state = AuthState.authenticated(user: user);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final api = ref.read(posApiServiceProvider);
      final response = await api.login(
        LoginRequest(email: email, password: password),
      );

      // Save token
      await ref.read(authTokenProvider.notifier).setToken(response.token);

      // Save user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(response.user.toJson()));

      state = AuthState.authenticated(user: response.user);
      return true;
    } catch (e) {
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
