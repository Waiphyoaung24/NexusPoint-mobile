import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/menu_item.dart';
import '../../../core/utils/category_parser.dart';
import 'menu_provider.dart';

/// Extracted categories from the current menu items.
final categoriesProvider = Provider<List<MenuCategory>>((ref) {
  final menuAsync = ref.watch(menuProvider);
  return menuAsync.whenOrNull(
        data: (items) => extractCategories(items.map((i) => i.category).toList()),
      ) ??
      [];
});

/// Currently selected parent category (null = "All").
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Currently selected subcategory (null = "All" within parent).
final selectedSubcategoryProvider = StateProvider<String?>((ref) => null);

/// Current search query.
final menuSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered menu items based on category selection and search query.
final filteredMenuProvider = Provider<List<MenuItem>>((ref) {
  final menuAsync = ref.watch(menuProvider);
  final selectedParent = ref.watch(selectedCategoryProvider);
  final selectedSub = ref.watch(selectedSubcategoryProvider);
  final searchQuery = ref.watch(menuSearchQueryProvider).toLowerCase().trim();

  final items = menuAsync.whenOrNull(data: (items) => items) ?? [];

  // If searching, ignore category filters and search across all items
  if (searchQuery.isNotEmpty) {
    return items.where((item) {
      final name = item.name.toLowerCase();
      final nameTh = (item.nameTh ?? '').toLowerCase();
      final sku = item.sku.toLowerCase();
      return name.contains(searchQuery) ||
          nameTh.contains(searchQuery) ||
          sku.contains(searchQuery);
    }).toList();
  }

  // No search — filter by category
  if (selectedParent == null) return items;

  return items.where((item) {
    final parsed = parseCategory(item.category);
    if (parsed.parent != selectedParent) return false;
    if (selectedSub != null && parsed.sub != selectedSub) return false;
    return true;
  }).toList();
});
