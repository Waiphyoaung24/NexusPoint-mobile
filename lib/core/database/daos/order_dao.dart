import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/orders.dart';

part 'order_dao.g.dart';

@DriftAccessor(tables: [Orders])
class OrderDao extends DatabaseAccessor<AppDatabase> with _$OrderDaoMixin {
  OrderDao(super.db);

  Future<LocalOrder> insertOrder(OrdersCompanion order) {
    return into(orders).insertReturning(order);
  }

  Future<void> updateOrder(int id, OrdersCompanion update) {
    return (this.update(orders)..where((t) => t.id.equals(id))).write(update);
  }

  Future<void> markSynced(int localId, String serverId) {
    return (update(orders)..where((t) => t.id.equals(localId))).write(
      OrdersCompanion(
        orderId: Value(serverId),
        syncedAt: Value(DateTime.now()),
        isSynced: const Value(true),
      ),
    );
  }

  Future<List<LocalOrder>> getUnsyncedOrders() {
    return (select(orders)..where((t) => t.isSynced.equals(false))).get();
  }

  Future<List<LocalOrder>> getAllOrders() {
    return (select(orders)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<LocalOrder?> getOrderById(int id) {
    return (select(orders)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> getTodayOrderCount() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final count = countAll();
    final query = selectOnly(orders)
      ..addColumns([count])
      ..where(orders.createdAt.isBiggerOrEqualValue(startOfDay));

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Stream<List<LocalOrder>> watchAllOrders() {
    return (select(orders)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }
}
