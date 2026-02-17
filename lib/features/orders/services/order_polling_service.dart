import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../repositories/order_repository.dart';

/// How often to poll the server for new orders from other devices.
const _pollInterval = Duration(seconds: 10);

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class OrderPollingState {
  final bool isPolling;
  final DateTime? lastPolledAt;
  final String? lastError;

  const OrderPollingState({
    this.isPolling = false,
    this.lastPolledAt,
    this.lastError,
  });

  OrderPollingState copyWith({
    bool? isPolling,
    DateTime? lastPolledAt,
    String? lastError,
    bool clearError = false,
  }) {
    return OrderPollingState(
      isPolling: isPolling ?? this.isPolling,
      lastPolledAt: lastPolledAt ?? this.lastPolledAt,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final orderPollingServiceProvider =
    StateNotifierProvider<OrderPollingNotifier, OrderPollingState>((ref) {
  return OrderPollingNotifier(ref);
});

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class OrderPollingNotifier extends StateNotifier<OrderPollingState> {
  final Ref _ref;

  Timer? _timer;
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  bool _isBusy = false;

  OrderPollingNotifier(this._ref) : super(const OrderPollingState()) {
    _init();
  }

  // --------------------------------------------------------------------------
  // Init
  // --------------------------------------------------------------------------

  Future<void> _init() async {
    // Periodic background poll
    _timer = Timer.periodic(_pollInterval, (_) => _poll());

    // Extra poll whenever we come back online (catches orders missed offline)
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        await _poll();
      }
    });

    // Immediate poll so the UI is current on app start
    await _poll();
  }

  // --------------------------------------------------------------------------
  // Public API
  // --------------------------------------------------------------------------

  /// Immediately poll for new orders — call this after placing an order or
  /// when the user manually refreshes.
  Future<void> pollNow() => _poll();

  // --------------------------------------------------------------------------
  // Internal
  // --------------------------------------------------------------------------

  Future<void> _poll() async {
    if (_isBusy) return;

    final authState = _ref.read(authProvider);
    if (authState is! Authenticated) return;

    final user = authState.user;
    if (user.tenantId == null) return;

    _isBusy = true;
    if (mounted) state = state.copyWith(isPolling: true, clearError: true);

    try {
      await _ref.read(orderRepositoryProvider).fetchAndMergeFromCloud(
            tenantId: user.tenantId!,
            branchId: user.branchId ?? user.tenantId!,
          );

      if (mounted) {
        state = state.copyWith(
          isPolling: false,
          lastPolledAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('⚠️ Order poll failed: $e');
      if (mounted) {
        state = state.copyWith(isPolling: false, lastError: e.toString());
      }
    } finally {
      _isBusy = false;
    }
  }

  // --------------------------------------------------------------------------
  // Dispose
  // --------------------------------------------------------------------------

  @override
  void dispose() {
    _timer?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
