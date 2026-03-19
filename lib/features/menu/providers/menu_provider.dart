import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/menu_item.dart';
import '../repositories/menu_repository.dart';
import '../../auth/providers/auth_provider.dart';

final menuProvider = FutureProvider.autoDispose<List<MenuItem>>((ref) async {
  final repo = ref.watch(menuRepositoryProvider);
  final authState = ref.watch(authProvider);

  return authState.maybeWhen(
    authenticated: (user) async {
      // Validate that user has organization/tenant ID
      if (user.tenantId == null || user.tenantId!.isEmpty) {
        print('ERROR: User tenantId is null or empty!');
        print('User details: id=${user.id}, email=${user.email}, tenantId=${user.tenantId}');
        throw Exception('User organization ID is missing. Please contact support.');
      }

      final orgId = user.tenantId!;
      print('Fetching menu items for organization: $orgId');

      try {
        // fetchFromApi already writes items + modifiers to the local DB.
        // Calling cacheLocally here would wipe modifier link data, so we don't.
        final items = await repo.fetchFromApi(orgId);
        return items;
      } catch (e) {
        print('API fetch failed: $e');
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
