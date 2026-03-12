import 'package:drift/drift.dart';

/// Local cache for restaurant tables (floor plan).
/// positionX = grid column (0–23), positionY = grid row (0–15).
@DataClassName('LocalTable')
class FloorPlanTables extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  IntColumn get number => integer()();
  TextColumn get label => text().nullable()();
  IntColumn get seats => integer().withDefault(const Constant(4))();
  // 'rectangle' | 'round' | 'bar_stool'
  TextColumn get shape => text().withDefault(const Constant('rectangle'))();
  IntColumn get positionX => integer().withDefault(const Constant(0))();
  IntColumn get positionY => integer().withDefault(const Constant(0))();
  // 'available' | 'occupied' | 'reserved' | 'cleaning'
  TextColumn get status => text().withDefault(const Constant('available'))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
