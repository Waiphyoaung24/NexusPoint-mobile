import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/branch_dto.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Provides the name of the currently selected branch.
/// Reads from cached branches list using the user's branchId.
final currentBranchNameProvider = FutureProvider.autoDispose<String?>((ref) async {
  final authState = ref.watch(authProvider);

  return authState.maybeWhen(
    authenticated: (user) async {
      if (user.branchId == null) return null;

      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_branches');
      if (cached == null) return null;

      final branches = (jsonDecode(cached) as List)
          .map((b) => BranchDto.fromJson(b as Map<String, dynamic>))
          .toList();

      final match = branches.where((b) => b.id == user.branchId);
      return match.isNotEmpty ? match.first.name : null;
    },
    orElse: () async => null,
  );
});
