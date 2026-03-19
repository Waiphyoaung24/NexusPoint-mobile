/// Parses a category string into parent and optional subcategory.
/// Delimiter: " > " (space-arrow-space).
///
/// Examples:
///   "Drinks > Soft Drinks" → (parent: "Drinks", sub: "Soft Drinks")
///   "Salad"                → (parent: "Salad", sub: null)
///   null / ""              → (parent: "Uncategorized", sub: null)
({String parent, String? sub}) parseCategory(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return (parent: 'Uncategorized', sub: null);
  }

  final parts = raw.split(' > ');
  if (parts.length >= 2) {
    return (parent: parts[0].trim(), sub: parts.sublist(1).join(' > ').trim());
  }
  return (parent: raw.trim(), sub: null);
}

/// Represents a parent category with its subcategories.
class MenuCategory {
  final String name;
  final List<String> subcategories;

  const MenuCategory({required this.name, this.subcategories = const []});

  bool get hasSubcategories => subcategories.isNotEmpty;
}

/// Extract unique categories from a list of category strings.
/// Returns sorted parent categories with their subcategories.
List<MenuCategory> extractCategories(List<String?> rawCategories) {
  final parentMap = <String, Set<String>>{};

  for (final raw in rawCategories) {
    final parsed = parseCategory(raw);
    parentMap.putIfAbsent(parsed.parent, () => {});
    if (parsed.sub != null) {
      parentMap[parsed.parent]!.add(parsed.sub!);
    }
  }

  // Sort parents alphabetically, but keep "Uncategorized" last
  final sorted = parentMap.entries.toList()
    ..sort((a, b) {
      if (a.key == 'Uncategorized') return 1;
      if (b.key == 'Uncategorized') return -1;
      return a.key.compareTo(b.key);
    });

  return sorted
      .map((e) => MenuCategory(
            name: e.key,
            subcategories: e.value.toList()..sort(),
          ))
      .toList();
}
