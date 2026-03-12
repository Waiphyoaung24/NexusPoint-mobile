import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/daos/modifier_dao.dart';
import '../../../core/providers/database_provider.dart';

final menuItemModifiersProvider =
    FutureProvider.autoDispose.family<List<ModifierGroupWithOptions>, String>(
  (ref, menuItemId) async {
    final db = ref.read(appDatabaseProvider);
    return db.modifierDao.getGroupsForItem(menuItemId);
  },
);
