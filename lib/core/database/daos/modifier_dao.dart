import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/modifier_tables.dart';

part 'modifier_dao.g.dart';

@DriftAccessor(tables: [ModifierGroups, ModifierOptions, MenuItemModifierGroups])
class ModifierDao extends DatabaseAccessor<AppDatabase>
    with _$ModifierDaoMixin {
  ModifierDao(super.db);

  // --- Modifier Groups ---

  Future<void> upsertGroups(List<ModifierGroupsCompanion> groups) async {
    await batch((b) {
      b.insertAll(modifierGroups, groups, mode: InsertMode.replace);
    });
  }

  Future<void> clearAllGroups() {
    return delete(modifierGroups).go();
  }

  Future<List<LocalModifierGroup>> getAllGroups() {
    return select(modifierGroups).get();
  }

  // --- Modifier Options ---

  Future<void> upsertOptions(List<ModifierOptionsCompanion> options) async {
    await batch((b) {
      b.insertAll(modifierOptions, options, mode: InsertMode.replace);
    });
  }

  Future<void> clearAllOptions() {
    return delete(modifierOptions).go();
  }

  Future<List<LocalModifierOption>> getOptionsForGroup(String groupId) {
    return (select(modifierOptions)
          ..where((t) => t.modifierGroupId.equals(groupId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  // --- Item↔Group Links ---

  Future<void> upsertLinks(
      List<MenuItemModifierGroupsCompanion> links) async {
    await batch((b) {
      b.insertAll(menuItemModifierGroups, links, mode: InsertMode.replace);
    });
  }

  Future<void> clearAllLinks() {
    return delete(menuItemModifierGroups).go();
  }

  /// Returns all modifier group IDs assigned to a given menu item.
  Future<List<String>> getGroupIdsForItem(String menuItemId) async {
    final rows = await (select(menuItemModifierGroups)
          ..where((t) => t.menuItemId.equals(menuItemId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map((r) => r.modifierGroupId).toList();
  }

  /// Returns full modifier groups (with options) for a given menu item.
  Future<List<ModifierGroupWithOptions>> getGroupsForItem(
      String menuItemId) async {
    final groupIds = await getGroupIdsForItem(menuItemId);
    if (groupIds.isEmpty) return [];

    final groups = await (select(modifierGroups)
          ..where((t) => t.id.isIn(groupIds)))
        .get();

    final result = <ModifierGroupWithOptions>[];
    for (final group in groups) {
      final options = await getOptionsForGroup(group.id);
      result.add(ModifierGroupWithOptions(group: group, options: options));
    }
    return result;
  }

  /// Clears all modifier data (groups, options, links) atomically.
  Future<void> clearAll() async {
    await transaction(() async {
      await clearAllLinks();
      await clearAllOptions();
      await clearAllGroups();
    });
  }
}

/// Value object pairing a modifier group with its options.
class ModifierGroupWithOptions {
  final LocalModifierGroup group;
  final List<LocalModifierOption> options;

  const ModifierGroupWithOptions({
    required this.group,
    required this.options,
  });
}
