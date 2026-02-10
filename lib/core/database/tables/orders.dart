import 'package:drift/drift.dart';

@DataClassName('LocalOrder')
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text().nullable()();
  TextColumn get orderNumber => text()();
  TextColumn get source => text()();
  TextColumn get status => text()();
  RealColumn get totalAmount => real()();
  TextColumn get paymentMethod => text()();
  TextColumn get itemsJson => text()();
  TextColumn get tableNumber => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
