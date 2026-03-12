import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/floor_plan_tables.dart';

part 'floor_plan_dao.g.dart';

@DriftAccessor(tables: [FloorPlanTables])
class FloorPlanDao extends DatabaseAccessor<AppDatabase>
    with _$FloorPlanDaoMixin {
  FloorPlanDao(super.db);

  /// All active tables sorted by number.
  Future<List<LocalTable>> getAllTables() =>
      (select(floorPlanTables)
            ..orderBy([(t) => OrderingTerm.asc(t.number)]))
          .get();

  /// Watch all tables for real-time UI updates.
  Stream<List<LocalTable>> watchAllTables() =>
      (select(floorPlanTables)
            ..orderBy([(t) => OrderingTerm.asc(t.number)]))
          .watch();

  /// Upsert a list of tables from API response.
  Future<void> upsertTables(List<FloorPlanTablesCompanion> tables) async {
    await batch((b) {
      b.insertAll(floorPlanTables, tables, mode: InsertMode.replace);
    });
  }

  /// Update only the status field (called after 2-second poll).
  Future<void> updateStatus(String id, String status) =>
      (update(floorPlanTables)..where((t) => t.id.equals(id)))
          .write(FloorPlanTablesCompanion(status: Value(status)));

  /// Batch update statuses from poll response.
  Future<void> batchUpdateStatuses(
    List<({String id, String status})> updates,
  ) async {
    await batch((b) {
      for (final u in updates) {
        b.update(
          floorPlanTables,
          FloorPlanTablesCompanion(status: Value(u.status)),
          where: (t) => t.id.equals(u.id),
        );
      }
    });
  }

  Future<void> deleteAll() => delete(floorPlanTables).go();
}
