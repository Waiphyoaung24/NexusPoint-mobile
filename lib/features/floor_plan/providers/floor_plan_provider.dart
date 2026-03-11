import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../repositories/floor_plan_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Initial full sync of floor plan tables from API.
/// Falls back to Drift cache if offline.
final floorPlanProvider =
    FutureProvider.autoDispose<List<LocalTable>>((ref) async {
  final repo = ref.watch(floorPlanRepositoryProvider);
  final authState = ref.watch(authProvider);

  return authState.maybeWhen(
    authenticated: (user, _) async {
      final orgId = user.tenantId ?? '';
      if (orgId.isEmpty) throw Exception('Organization ID missing');
      final branchId = user.branchId;
      if (branchId == null || branchId.isEmpty) {
        throw Exception('Branch not selected — please select a branch');
      }
      return repo.syncFromApi(orgId, branchId);
    },
    orElse: () async => [],
  );
});

/// Reactive stream of tables from Drift — updates on every poll write.
final floorPlanStreamProvider =
    StreamProvider.autoDispose<List<LocalTable>>((ref) {
  final repo = ref.watch(floorPlanRepositoryProvider);
  return repo.watchTables();
});

/// Controls the 2-second polling loop.
/// Cancel by disposing (autoDispose handles this when screen closes).
final floorPlanPollingProvider = Provider.autoDispose<void>((ref) {
  final repo = ref.read(floorPlanRepositoryProvider);
  final authState = ref.read(authProvider);

  final orgId = authState.maybeWhen(
    authenticated: (user, _) => user.tenantId ?? '',
    orElse: () => '',
  );

  final branchId = authState.maybeWhen(
    authenticated: (user, _) => user.branchId ?? '',
    orElse: () => '',
  );

  if (orgId.isEmpty) return;
  if (branchId.isEmpty) return;

  // Poll every 2 seconds
  final timer = Timer.periodic(const Duration(seconds: 2), (_) {
    repo.pollStatuses(orgId, branchId);
  });

  ref.onDispose(timer.cancel);
});

/// Selected table id for action sheet
final selectedTableIdProvider = StateProvider.autoDispose<String?>((ref) => null);

/// Connectivity indicator — set true when last poll succeeded
final floorPlanOnlineProvider = StateProvider.autoDispose<bool>((ref) => true);
