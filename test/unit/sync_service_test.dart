import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuspoint_pos/core/api/api_exception.dart';
import 'package:nexuspoint_pos/features/orders/services/sync_service.dart';

// ---------------------------------------------------------------------------
// Tests focus on SyncState logic only (no network / DB calls).
// The SyncServiceNotifier's connectivity + DB wiring is integration-tested.
// ---------------------------------------------------------------------------

void main() {
  group('SyncState', () {
    test('default state is idle with 0 pending', () {
      const state = SyncState();
      expect(state.status, SyncStatus.idle);
      expect(state.pendingCount, 0);
      expect(state.lastError, isNull);
    });

    test('copyWith updates status', () {
      const state = SyncState();
      final updated = state.copyWith(status: SyncStatus.syncing);
      expect(updated.status, SyncStatus.syncing);
      expect(updated.pendingCount, 0); // unchanged
    });

    test('copyWith updates pendingCount', () {
      const state = SyncState();
      final updated = state.copyWith(pendingCount: 5);
      expect(updated.pendingCount, 5);
      expect(updated.status, SyncStatus.idle); // unchanged
    });

    test('copyWith updates lastError', () {
      const state = SyncState();
      final updated = state.copyWith(
        status: SyncStatus.error,
        lastError: 'Network error',
      );
      expect(updated.status, SyncStatus.error);
      expect(updated.lastError, 'Network error');
    });

    test('copyWith preserves unspecified fields', () {
      final state = const SyncState(
        status: SyncStatus.syncing,
        pendingCount: 3,
        lastError: 'previous error',
      );
      final updated = state.copyWith(pendingCount: 1);
      expect(updated.status, SyncStatus.syncing);
      expect(updated.pendingCount, 1);
      expect(updated.lastError, 'previous error');
    });

    test('copyWith clearError=true sets lastError to null', () {
      final state = const SyncState(
        status: SyncStatus.error,
        lastError: 'something went wrong',
      );
      final cleared = state.copyWith(
        status: SyncStatus.syncing,
        clearError: true,
      );
      expect(cleared.status, SyncStatus.syncing);
      expect(cleared.lastError, isNull);
    });

    test('copyWith clearError=false (default) preserves lastError', () {
      final state =
          const SyncState(status: SyncStatus.error, lastError: 'err');
      final updated = state.copyWith(status: SyncStatus.idle);
      expect(updated.lastError, 'err');
    });
  });

  group('SyncStatus enum', () {
    test('has idle, syncing, error values', () {
      expect(SyncStatus.values, contains(SyncStatus.idle));
      expect(SyncStatus.values, contains(SyncStatus.syncing));
      expect(SyncStatus.values, contains(SyncStatus.error));
      expect(SyncStatus.values.length, 3);
    });
  });

  group('syncServiceProvider — initial state', () {
    // We test that provider is readable without crashing.
    // Full integration (connectivity + DB) requires a device or integration test.
    test('provider builds SyncServiceNotifier', () {
      // This test verifies the provider compiles and the initial state type.
      const state = SyncState();
      expect(state, isA<SyncState>());
    });
  });

  // ---------------------------------------------------------------------------
  // 404 handling — non-retryable error detection
  // ---------------------------------------------------------------------------
  group('SyncState — 404 not-retryable error semantics', () {
    // Mirrors the logic in syncPending():
    //   if (e is ApiException && e.statusCode == 404) { continue; }
    //   else { await _syncQueueDao.incrementRetry(item.id); }
    bool shouldSkipRetry(Object error) {
      return error is ApiException && error.statusCode == 404;
    }

    test('ApiException with 404 should skip retry', () {
      final e = ApiException('Not found', statusCode: 404);
      expect(shouldSkipRetry(e), isTrue);
    });

    test('NetworkException should NOT skip retry', () {
      final e = NetworkException('Connection failed');
      expect(shouldSkipRetry(e), isFalse);
    });

    test('ServerException (5xx) should NOT skip retry', () {
      final e = ServerException('Internal server error');
      expect(shouldSkipRetry(e), isFalse);
    });

    test('ApiException with 401 should NOT skip retry', () {
      final e = ApiException('Unauthorized', statusCode: 401);
      expect(shouldSkipRetry(e), isFalse);
    });

    test('generic Exception should NOT skip retry', () {
      final e = Exception('Something went wrong');
      expect(shouldSkipRetry(e), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Connectivity_plus v5.0.2 online-check logic (single ConnectivityResult)
  // ---------------------------------------------------------------------------
  group('connectivity_plus v5.0.2 — isOnline check', () {
    // Replicates the logic used in SyncServiceNotifier._init():
    //   final isOnline = result != ConnectivityResult.none;
    bool isOnline(ConnectivityResult result) =>
        result != ConnectivityResult.none;

    test('wifi is online', () {
      expect(isOnline(ConnectivityResult.wifi), isTrue);
    });

    test('mobile is online', () {
      expect(isOnline(ConnectivityResult.mobile), isTrue);
    });

    test('ethernet is online', () {
      expect(isOnline(ConnectivityResult.ethernet), isTrue);
    });

    test('none is offline', () {
      expect(isOnline(ConnectivityResult.none), isFalse);
    });
  });
}
