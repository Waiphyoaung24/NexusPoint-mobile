import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/orders.dart';
import 'tables/menu_items.dart';
import 'tables/sync_queue.dart';
import 'tables/modifier_tables.dart';
import 'tables/floor_plan_tables.dart';
import 'daos/order_dao.dart';
import 'daos/menu_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/modifier_dao.dart';
import 'daos/floor_plan_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Orders, MenuItems, SyncQueue, ModifierGroups, ModifierOptions, MenuItemModifierGroups, FloorPlanTables],
  daos: [OrderDao, MenuDao, SyncQueueDao, ModifierDao, FloorPlanDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.deleteTable(menuItems.actualTableName);
          await m.createTable(menuItems);
        }
        if (from < 3) {
          await m.createTable(modifierGroups);
          await m.createTable(modifierOptions);
          await m.createTable(menuItemModifierGroups);
        }
        if (from < 4) {
          await m.createTable(floorPlanTables);
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          // Initialize data if needed
        }
      },
    );
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'nexuspoint_pos.db'));
      return NativeDatabase(file);
    });
  }
}
