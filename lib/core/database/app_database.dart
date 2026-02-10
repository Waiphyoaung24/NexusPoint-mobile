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
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'nexuspoint_pos.db'));
      return NativeDatabase(file);
    });
  }
}
