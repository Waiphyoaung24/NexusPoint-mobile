import 'package:drift/drift.dart';

@DataClassName('LocalModifierGroup')
class ModifierGroups extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get nameTh => text().nullable()();
  BoolColumn get isRequired => boolean().withDefault(const Constant(false))();
  IntColumn get minSelections => integer().nullable()();
  IntColumn get maxSelections => integer().nullable()();
  IntColumn get sortOrder => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalModifierOption')
class ModifierOptions extends Table {
  TextColumn get id => text()();
  TextColumn get modifierGroupId => text()();
  TextColumn get organizationId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get nameTh => text().nullable()();
  RealColumn get priceAdjustment =>
      real().withDefault(const Constant(0.0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalMenuItemModifierGroup')
class MenuItemModifierGroups extends Table {
  TextColumn get id => text()();
  TextColumn get menuItemId => text()();
  TextColumn get modifierGroupId => text()();
  IntColumn get sortOrder => integer().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
