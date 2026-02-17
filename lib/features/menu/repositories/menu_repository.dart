import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/models/menu_item.dart';
import '../../../core/models/api_models.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/menu_dao.dart';
import '../../../core/api/api_service.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/database_provider.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(
    ref.read(posApiServiceProvider),
    ref.read(appDatabaseProvider).menuDao,
  );
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
