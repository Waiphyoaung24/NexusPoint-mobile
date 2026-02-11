import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/orders.dart';
import 'tables/menu_items.dart';
import 'tables/sync_queue.dart';
import 'daos/order_dao.dart';
import 'daos/menu_dao.dart';
import 'daos/sync_queue_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Orders, MenuItems, SyncQueue],
  daos: [OrderDao, MenuDao, SyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // In development/MVP, we can drop and recreate the menu table 
          // as it's primarily a cache. For orders, we'd want to be more careful.
          await m.deleteTable(menuItems.actualTableName);
          await m.createTable(menuItems);
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
