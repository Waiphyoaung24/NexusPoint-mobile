import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/models/menu_item.dart';
import '../../../core/models/api_models.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/menu_dao.dart';
import '../../../core/api/api_service.dart';
import '../../../core/providers/dio_provider.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(
    ref.read(posApiServiceProvider),
    ref.read(appDatabaseProvider).menuDao,
  );
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

class MenuRepository {
  final PosApiService _api;
  final MenuDao _localDb;

  MenuRepository(this._api, this._localDb);

  Future<List<MenuItem>> fetchFromApi(String tenantId) async {
    final dtos = await _api.getMenuItems(tenantId);
    return dtos.map(_dtoToModel).toList();
  }

  Future<void> cacheLocally(List<MenuItem> items) async {
    final companions = items.map((item) => MenuItemsCompanion(
          id: drift.Value(item.id),
          tenantId: drift.Value(item.tenantId),
          name: drift.Value(item.name),
          price: drift.Value(item.price),
          category: drift.Value(item.category),
          imageUrl: drift.Value(item.imageUrl),
          isAvailable: drift.Value(item.isAvailable),
          inventoryQty: drift.Value(item.inventoryQty),
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
      tenantId: dto.tenantId,
      name: dto.name,
      price: dto.price,
      category: dto.category,
      imageUrl: dto.imageUrl,
      isAvailable: dto.isAvailable,
      inventoryQty: dto.inventoryQty,
    );
  }

  MenuItem _localToModel(LocalMenuItem local) {
    return MenuItem(
      id: local.id,
      tenantId: local.tenantId,
      name: local.name,
      price: local.price,
      category: local.category,
      imageUrl: local.imageUrl,
      isAvailable: local.isAvailable,
      inventoryQty: local.inventoryQty,
    );
  }
}
