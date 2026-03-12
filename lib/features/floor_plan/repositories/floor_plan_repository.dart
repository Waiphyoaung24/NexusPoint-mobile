import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/floor_plan_dao.dart';
import '../../../core/database/tables/floor_plan_tables.dart';
import '../../../core/api/api_service.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/dio_provider.dart';

final floorPlanRepositoryProvider = Provider<FloorPlanRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return FloorPlanRepository(
    ref.read(posApiServiceProvider),
    db.floorPlanDao,
  );
});

class FloorPlanRepository {
  final PosApiService _api;
  final FloorPlanDao _localDb;

  FloorPlanRepository(this._api, this._localDb);

  /// Full sync: fetches all tables from API and writes to Drift.
  /// Called once on floor plan screen open.
  Future<List<LocalTable>> syncFromApi(String orgId, String branchId) async {
    try {
      final response = await _api.getFloorPlanTables(orgId, branchId);
      final now = DateTime.now();

      final rows = response.map((t) => FloorPlanTablesCompanion(
        id: drift.Value(t.id),
        organizationId: drift.Value(t.organizationId),
        branchId: drift.Value(t.branchId),
        number: drift.Value(t.number),
        label: drift.Value(t.label),
        seats: drift.Value(t.seats),
        shape: drift.Value(t.shape),
        positionX: drift.Value(t.positionX),
        positionY: drift.Value(t.positionY),
        status: drift.Value(t.status),
        updatedAt: drift.Value(t.updatedAt),
        cachedAt: drift.Value(now),
      )).toList();

      await _localDb.upsertTables(rows);
      return await _localDb.getAllTables();
    } catch (e) {
      debugPrint('Floor plan API sync failed: $e');
      // Offline fallback: return cached tables
      final cached = await _localDb.getAllTables();
      if (cached.isEmpty) rethrow;
      return cached;
    }
  }

  /// Lightweight poll: fetch only status fields, update Drift.
  /// Called every 2 seconds while floor plan screen is visible.
  Future<void> pollStatuses(String orgId, String branchId) async {
    try {
      final statuses = await _api.getTableStatuses(orgId, branchId);
      await _localDb.batchUpdateStatuses(
        statuses.map((s) => (id: s.id, status: s.status)).toList(),
      );
    } catch (e) {
      // Silently fail on poll — offline mode, UI shows cached state
      debugPrint('Floor plan poll failed (offline?): $e');
    }
  }

  /// Update a single table status (optimistic — called on order open/close).
  Future<void> updateStatusLocally(String tableId, String status) =>
      _localDb.updateStatus(tableId, status);

  /// Watch table stream for reactive UI rebuilds.
  Stream<List<LocalTable>> watchTables() => _localDb.watchAllTables();

  Future<List<LocalTable>> getCachedTables() => _localDb.getAllTables();
}
