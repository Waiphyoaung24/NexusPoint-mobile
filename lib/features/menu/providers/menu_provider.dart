import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/menu_item.dart';
import '../repositories/menu_repository.dart';
import '../../auth/providers/auth_provider.dart';

final menuProvider = FutureProvider.autoDispose<List<MenuItem>>((ref) async {
  final repo = ref.watch(menuRepositoryProvider);
  final authState = ref.watch(authProvider);

  return authState.maybeWhen(
    authenticated: (user, _) async {
      final orgId = user.tenantId ?? 'default-org'; // Using tenantId from User model as orgId
      
      try {
        // Try API first
        final items = await repo.fetchFromApi(orgId);
        await repo.cacheLocally(items);
        return items;
      } catch (e) {
        // Fallback to cache
        final cached = await repo.getFromCache();
        if (cached.isEmpty) {
          throw Exception('No menu items available offline');
        }
        return cached;
      }
    },
    orElse: () async => [],
  );
});
