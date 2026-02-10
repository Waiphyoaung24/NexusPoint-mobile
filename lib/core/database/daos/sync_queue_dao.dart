import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_queue.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<void> enqueue({
    required String entityType,
    required int entityId,
    required String action,
    required String payloadJson,
    int priority = 0,
  }) {
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        action: action,
        payloadJson: payloadJson,
        priority: Value(priority),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<SyncQueueItem>> getPendingItems() {
    return (select(syncQueue)
          ..where((t) => t.isCompleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> markCompleted(int id) {
    return (update(syncQueue)..where((t) => t.id.equals(id))).write(
      const SyncQueueCompanion(isCompleted: Value(true)),
    );
  }

  Future<void> incrementRetry(int id) async {
    final item = await (select(syncQueue)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (item != null) {
      await (update(syncQueue)..where((t) => t.id.equals(id))).write(
        SyncQueueCompanion(
          retryCount: Value(item.retryCount + 1),
          lastAttemptAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> markFailed(int id) {
    // Move to failed state (could be separate table in production)
    return (update(syncQueue)..where((t) => t.id.equals(id))).write(
      const SyncQueueCompanion(
        isCompleted: Value(true),
        retryCount: Value(999), // Flag as failed
      ),
    );
  }

  Future<int> getPendingCount() async {
    final count = countAll();
    final query = selectOnly(syncQueue)
      ..addColumns([count])
      ..where(syncQueue.isCompleted.equals(false));

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Stream<int> watchPendingCount() {
    final count = countAll();
    return (selectOnly(syncQueue)
          ..addColumns([count])
          ..where(syncQueue.isCompleted.equals(false)))
        .map((row) => row.read(count) ?? 0)
        .watchSingle();
  }
}
