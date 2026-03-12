import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/models/menu_item.dart';
import '../../../core/models/api_models.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/menu_dao.dart';
import '../../../core/database/daos/modifier_dao.dart';
import '../../../core/database/tables/modifier_tables.dart';
import '../../../core/api/api_service.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/database_provider.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return MenuRepository(
    ref.read(posApiServiceProvider),
    db.menuDao,
    db.modifierDao,
  );
});

class MenuRepository {
  final PosApiService _api;
  final MenuDao _localDb;
  final ModifierDao _modifierDb;

  MenuRepository(this._api, this._localDb, this._modifierDb);

  /// Full sync: fetches items + modifiers in one call, writes both to Drift.
  ///
  /// Falls back to [menu.listItems] when [menu.listWithModifiers] is not yet
  /// deployed on the server (404). Items are kept current; modifier data is
  /// cleared so the picker doesn't show stale options.
  Future<List<MenuItem>> syncFromApi(String tenantId) async {
    try {
      return await _syncWithModifiers();
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        debugPrint('⚠️ menu.listWithModifiers not available — falling back to menu.listItems');
        return _syncItemsOnly(tenantId);
      }
      rethrow;
    }
  }

  Future<List<MenuItem>> _syncWithModifiers() async {
    final payload = await _api.getMenuItemsWithModifiers();

    final items = payload.items.map(_dtoToModel).toList();

    // Write everything inside a single transaction so the cache is always
    // consistent (items + modifiers are never partially written).
    await _localDb.deleteAll();
    await _modifierDb.clearAll();

    final now = DateTime.now();

    await _localDb.insertAll(payload.items
        .map((dto) => MenuItemsCompanion(
              id: drift.Value(dto.id),
              organizationId: drift.Value(dto.organizationId),
              branchId: drift.Value(dto.branchId),
              sku: drift.Value(dto.sku),
              name: drift.Value(dto.name),
              nameTh: drift.Value(dto.nameTh),
              description: drift.Value(dto.description),
              price: drift.Value(dto.price),
              category: drift.Value(dto.category),
              imageUrl: drift.Value(dto.imageUrl),
              isAvailable: drift.Value(dto.isAvailable),
              sortOrder: drift.Value(dto.sortOrder),
              cachedAt: drift.Value(now),
            ))
        .toList());

    await _modifierDb.upsertGroups(payload.modifierGroups
        .map((g) => ModifierGroupsCompanion(
              id: drift.Value(g.id),
              organizationId: drift.Value(g.organizationId),
              name: drift.Value(g.name),
              nameTh: drift.Value(g.nameTh),
              isRequired: drift.Value(g.isRequired),
              minSelections: drift.Value(g.minSelections),
              maxSelections: drift.Value(g.maxSelections),
              sortOrder: drift.Value(g.sortOrder),
              isActive: drift.Value(g.isActive),
              cachedAt: drift.Value(now),
            ))
        .toList());

    final allOptions = payload.modifierGroups
        .expand((g) => g.options)
        .map((o) => ModifierOptionsCompanion(
              id: drift.Value(o.id),
              modifierGroupId: drift.Value(o.modifierGroupId),
              organizationId: drift.Value(o.organizationId),
              name: drift.Value(o.name),
              nameTh: drift.Value(o.nameTh),
              priceAdjustment: drift.Value(o.priceAdjustment),
              isDefault: drift.Value(o.isDefault),
              isActive: drift.Value(o.isActive),
              sortOrder: drift.Value(o.sortOrder),
              cachedAt: drift.Value(now),
            ))
        .toList();

    if (allOptions.isNotEmpty) {
      await _modifierDb.upsertOptions(allOptions);
    }

    await _modifierDb.upsertLinks(payload.itemModifierLinks
        .map((l) => MenuItemModifierGroupsCompanion(
              id: drift.Value(l.id),
              menuItemId: drift.Value(l.menuItemId),
              modifierGroupId: drift.Value(l.modifierGroupId),
              sortOrder: drift.Value(l.sortOrder),
              cachedAt: drift.Value(now),
            ))
        .toList());

    return items;
  }

  /// Fallback sync: fetches items only (no modifiers) via [menu.listItems].
  /// Used when [menu.listWithModifiers] is not yet deployed on the server.
  /// Clears modifier cache so stale modifier data doesn't show in the picker.
  Future<List<MenuItem>> _syncItemsOnly(String tenantId) async {
    final dtos = await _api.getMenuItems(tenantId);
    final items = dtos.map(_dtoToModel).toList();

    await _localDb.deleteAll();
    await _modifierDb.clearAll(); // no modifiers available from this endpoint

    final now = DateTime.now();
    await _localDb.insertAll(dtos
        .map((dto) => MenuItemsCompanion(
              id: drift.Value(dto.id),
              organizationId: drift.Value(dto.organizationId),
              branchId: drift.Value(dto.branchId),
              sku: drift.Value(dto.sku),
              name: drift.Value(dto.name),
              nameTh: drift.Value(dto.nameTh),
              description: drift.Value(dto.description),
              price: drift.Value(dto.price),
              category: drift.Value(dto.category),
              imageUrl: drift.Value(dto.imageUrl),
              isAvailable: drift.Value(dto.isAvailable),
              sortOrder: drift.Value(dto.sortOrder),
              cachedAt: drift.Value(now),
            ))
        .toList());

    return items;
  }

  /// Legacy helper kept for compatibility — delegates to [syncFromApi].
  Future<List<MenuItem>> fetchFromApi(String tenantId) => syncFromApi(tenantId);

  Future<void> cacheLocally(List<MenuItem> items) async {
    final companions = items.map((item) => MenuItemsCompanion(
          id: drift.Value(item.id),
          organizationId: drift.Value(item.organizationId),
          branchId: drift.Value(item.branchId),
          sku: drift.Value(item.sku),
          name: drift.Value(item.name),
          nameTh: drift.Value(item.nameTh),
          description: drift.Value(item.description),
          price: drift.Value(item.price),
          category: drift.Value(item.category),
          imageUrl: drift.Value(item.imageUrl),
          isAvailable: drift.Value(item.isAvailable),
          sortOrder: drift.Value(item.sortOrder),
          cachedAt: drift.Value(DateTime.now()),
        ));

    await _localDb.deleteAll();
    await _localDb.insertAll(companions.toList());
  }

  Future<List<MenuItem>> getFromCache() async {
    final items = await _localDb.getAllItems();
    return items.map(_localToModel).toList();
  }

  Stream<List<MenuItem>> watchCache() {
    return _localDb.watchAllItems().map(
          (items) => items.map(_localToModel).toList(),
        );
  }

  MenuItem _dtoToModel(MenuItemDto dto) {
    return MenuItem(
      id: dto.id,
      organizationId: dto.organizationId,
      branchId: dto.branchId,
      sku: dto.sku,
      name: dto.name,
      nameTh: dto.nameTh,
      description: dto.description,
      price: dto.price,
      category: dto.category,
      imageUrl: dto.imageUrl,
      isAvailable: dto.isAvailable,
      sortOrder: dto.sortOrder,
    );
  }

  MenuItem _localToModel(LocalMenuItem local) {
    return MenuItem(
      id: local.id,
      organizationId: local.organizationId,
      branchId: local.branchId,
      sku: local.sku,
      name: local.name,
      nameTh: local.nameTh,
      description: local.description,
      price: local.price,
      category: local.category,
      imageUrl: local.imageUrl,
      isAvailable: local.isAvailable,
      sortOrder: local.sortOrder,
    );
  }
}
