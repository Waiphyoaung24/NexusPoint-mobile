import 'package:drift/drift.dart';

@DataClassName('LocalMenuItem')
class MenuItems extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().nullable()();
  TextColumn get branchId => text().nullable()();
  TextColumn get sku => text()();
  TextColumn get name => text()();
  TextColumn get nameTh => text().nullable()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real()();
  TextColumn get category => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
