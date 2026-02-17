import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/api_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/order_dao.dart';
import '../../../core/database/daos/sync_queue_dao.dart';
import '../../../core/models/api_models.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/database_provider.dart';

/// Maximum retry attempts before an item is marked as permanently failed.
const _maxRetries = 3;

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum SyncStatus { idle, syncing, error }

class SyncState {
  final SyncStatus status;
  final int pendingCount;
  final String? lastError;

  const SyncState({
    this.status = SyncStatus.idle,
    this.pendingCount = 0,
    this.lastError,
  });

  /// Use [clearError] to explicitly set lastError to null.
  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    String? lastError,
    bool clearError = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final syncServiceProvider =
    StateNotifierProvider<SyncServiceNotifier, SyncState>((ref) {
  return SyncServiceNotifier(
    ref.read(posApiServiceProvider),
    ref.read(appDatabaseProvider).orderDao,
    ref.read(appDatabaseProvider).syncQueueDao,
  );
});

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SyncServiceNotifier extends StateNotifier<SyncState> {
  final PosApiService _api;
  final OrderDao _orderDao;
  final SyncQueueDao _syncQueueDao;

  StreamSubscription<ConnectivityResult>? _connectivitySub;
  bool _isSyncing = false;

  SyncServiceNotifier(this._api, this._orderDao, this._syncQueueDao)
      : super(const SyncState()) {
    _init();
  }

  // --------------------------------------------------------------------------
  // Init
  // --------------------------------------------------------------------------

  Future<void> _init() async {
    // Watch pending count — trigger sync when new items arrive
    _syncQueueDao.watchPendingCount().listen((count) {
      if (mounted) {
        state = state.copyWith(pendingCount: count);
        if (count > 0) {
          syncPending();
        }
      }
    });

    // Listen to connectivity changes and trigger sync when online.
    // connectivity_plus v5.0.2 emits a single ConnectivityResult per event.
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((result) async {
      final isOnline = result != ConnectivityResult.none;
      if (isOnline) {
        await syncPending();
      }
    });

    // Attempt an initial sync in case we're already online.
    final initial = await Connectivity().checkConnectivity();
    if (initial != ConnectivityResult.none) {
      await syncPending();
    }
  }

  // --------------------------------------------------------------------------
  // Public API
  // --------------------------------------------------------------------------

  /// Manually trigger a sync attempt.
  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;

    final pending = await _syncQueueDao.getPendingItems();
    if (pending.isEmpty) {
      _isSyncing = false;
      return;
    }

    if (!mounted) {
      _isSyncing = false;
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing, clearError: true);

    int successCount = 0;
    String? lastError;

    for (final item in pending) {
      if (item.retryCount >= _maxRetries) {
        await _syncQueueDao.markFailed(item.id);
        continue;
      }

      try {
        await _processItem(item);
        await _syncQueueDao.markCompleted(item.id);
        successCount++;
      } catch (e) {
        // 404 = backend procedure not implemented yet.
        // Don't consume retry slots — leave the item in the queue
        // so it will be retried when the backend is ready.
        if (e is ApiException && e.statusCode == 404) {
          debugPrint(
            '⚠️  Backend procedure not found (404) for item ${item.id}. '
            'Keeping in queue for when backend is ready.',
          );
          continue;
        }
        await _syncQueueDao.incrementRetry(item.id);
        lastError = e.toString();
        debugPrint('Sync failed for item ${item.id}: $e');
      }
    }

    if (!mounted) {
      _isSyncing = false;
      return;
    }

    state = state.copyWith(
      status: lastError != null ? SyncStatus.error : SyncStatus.idle,
      lastError: lastError,
    );

    if (successCount > 0) {
      debugPrint('Synced $successCount item(s) successfully');
    }

    _isSyncing = false;
  }

  // --------------------------------------------------------------------------
  // Internal
  // --------------------------------------------------------------------------

  Future<void> _processItem(SyncQueueItem item) async {
    if (item.entityType == 'order' && item.action == 'create') {
      await _syncOrder(item);
    }
    // Future: handle 'menu_update', 'order_update' etc.
  }

  Future<void> _syncOrder(SyncQueueItem item) async {
    final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
    final request = OrderRequest.fromJson(payload);

    try {
      final response = await _api.createOrder(request);

      // Mark the local order as synced with server ID
      await _orderDao.markSynced(item.entityId, response.orderId);
    } on NetworkException {
      rethrow; // Let the caller handle retryable errors
    } catch (e) {
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // Dispose
  // --------------------------------------------------------------------------

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
