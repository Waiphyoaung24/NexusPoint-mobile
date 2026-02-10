import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/menu_items.dart';

part 'menu_dao.g.dart';

@DriftAccessor(tables: [MenuItems])
class MenuDao extends DatabaseAccessor<AppDatabase> with _$MenuDaoMixin {
  MenuDao(super.db);

  Future<void> insertItem(MenuItemsCompanion item) {
    return into(menuItems).insert(item, mode: InsertMode.replace);
  }

  Future<void> insertAll(List<MenuItemsCompanion> items) async {
    await batch((batch) {
      batch.insertAll(menuItems, items, mode: InsertMode.replace);
    });
  }

  Future<void> deleteAll() {
    return delete(menuItems).go();
  }

  Future<List<LocalMenuItem>> getAllItems() {
    return select(menuItems).get();
  }

  Future<LocalMenuItem?> getItemById(String id) {
    return (select(menuItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<LocalMenuItem>> watchAllItems() {
    return select(menuItems).watch();
  }

  Future<void> updateAvailability(String id, bool isAvailable) {
    return (update(menuItems)..where((t) => t.id.equals(id))).write(
      MenuItemsCompanion(isAvailable: Value(isAvailable)),
    );
  }
}
