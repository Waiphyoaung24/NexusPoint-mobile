import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pos_theme.dart';
import '../../../core/utils/category_parser.dart';
import '../providers/category_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/modifier_provider.dart';
import '../widgets/modifier_picker_sheet.dart';
import '../../cart/providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuProvider);
    final cart = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: PosTheme.backgroundLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPhone = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          final crossAxisCount = isPhone ? 2 : isTablet ? 3 : 4;

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, ref, authState, cart, isPhone),
                _SearchBar(isPhone: isPhone),
                _CategoryTabs(isPhone: isPhone),
                Expanded(
                  child: menuAsync.when(
                    data: (_) => _FilteredMenuGrid(
                      crossAxisCount: crossAxisCount,
                      isPhone: isPhone,
                    ),
                    loading: () => _buildLoadingState(context),
                    error: (error, stack) => _buildErrorState(context, error),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    CartState cart,
    bool isPhone,
  ) {
    return Container(
      padding: EdgeInsets.all(isPhone ? 16 : 24),
      decoration: BoxDecoration(
        color: PosTheme.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: PosTheme.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isPhone ? 48 : 56,
            height: isPhone ? 48 : 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [PosTheme.primaryBlue, PosTheme.secondaryBlue],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.point_of_sale_rounded,
              color: Colors.white,
              size: isPhone ? 24 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NexusPoint POS',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PosTheme.primaryBlue,
                      ),
                ),
                authState.whenOrNull(
                      authenticated: (user) => Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: PosTheme.textSecondary,
                            ),
                      ),
                    ) ??
                    const SizedBox.shrink(),
              ],
            ),
          ),
          _buildCartButton(context, ref, cart, isPhone),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(isPhone ? 80 : 100, isPhone ? 48 : 56),
              padding: EdgeInsets.symmetric(
                horizontal: isPhone ? 16 : 20,
                vertical: 12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: isPhone ? 18 : 20),
                if (!isPhone) ...[
                  const SizedBox(width: 8),
                  const Text('Logout'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton(
    BuildContext context,
    WidgetRef ref,
    CartState cart,
    bool isPhone,
  ) {
    return FilledButton(
      onPressed: cart.isEmpty
          ? null
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${cart.itemCount} items • ฿${cart.total.toStringAsFixed(2)}',
                  ),
                  action: SnackBarAction(label: 'View Cart', onPressed: () {}),
                ),
              );
            },
      style: FilledButton.styleFrom(
        minimumSize: Size(isPhone ? 56 : 120, isPhone ? 48 : 56),
        padding: EdgeInsets.symmetric(
          horizontal: isPhone ? 12 : 20,
          vertical: 12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Badge(
            label: Text(cart.itemCount.toString()),
            isLabelVisible: cart.itemCount > 0,
            child: const Icon(Icons.shopping_cart),
          ),
          if (!isPhone) ...[
            const SizedBox(width: 12),
            Text('฿${cart.total.toStringAsFixed(0)}'),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: PosTheme.primaryBlue),
          const SizedBox(height: 16),
          Text(
            'Loading menu...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PosTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: PosTheme.dangerRed.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Error loading menu', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PosTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerWidget {
  final bool isPhone;
  const _SearchBar({required this.isPhone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(menuSearchQueryProvider);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 16 : 24,
        vertical: 8,
      ),
      color: PosTheme.surfaceWhite,
      child: TextField(
        onChanged: (value) {
          ref.read(menuSearchQueryProvider.notifier).state = value;
          // Clear category selection while searching
          if (value.isNotEmpty) {
            ref.read(selectedCategoryProvider.notifier).state = null;
            ref.read(selectedSubcategoryProvider.notifier).state = null;
          }
        },
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: TextStyle(color: PosTheme.textSecondary.withValues(alpha: 0.6)),
          prefixIcon: const Icon(Icons.search, color: PosTheme.textSecondary),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    ref.read(menuSearchQueryProvider.notifier).state = '';
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          filled: true,
          fillColor: PosTheme.backgroundLight,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─── Category Tabs (Two-Level) ───────────────────────────────────────────────

class _CategoryTabs extends ConsumerWidget {
  final bool isPhone;
  const _CategoryTabs({required this.isPhone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedParent = ref.watch(selectedCategoryProvider);
    final selectedSub = ref.watch(selectedSubcategoryProvider);
    final searchQuery = ref.watch(menuSearchQueryProvider);

    // Hide tabs when searching
    if (searchQuery.isNotEmpty) return const SizedBox.shrink();
    if (categories.isEmpty) return const SizedBox.shrink();

    // Find current parent's subcategories
    final currentParent = categories.where((c) => c.name == selectedParent).firstOrNull;

    return Container(
      color: PosTheme.surfaceWhite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Parent category tabs
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isPhone ? 12 : 20),
              children: [
                _CategoryTab(
                  label: 'All',
                  isSelected: selectedParent == null,
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                    ref.read(selectedSubcategoryProvider.notifier).state = null;
                  },
                ),
                ...categories.map((cat) => _CategoryTab(
                      label: cat.name,
                      isSelected: selectedParent == cat.name,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state = cat.name;
                        ref.read(selectedSubcategoryProvider.notifier).state = null;
                      },
                    )),
              ],
            ),
          ),

          // Subcategory tabs (only when parent has subcategories)
          if (currentParent != null && currentParent.hasSubcategories)
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: PosTheme.backgroundLight,
                border: Border(
                  top: BorderSide(color: PosTheme.borderLight, width: 0.5),
                ),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isPhone ? 12 : 20),
                children: [
                  _SubcategoryTab(
                    label: 'All',
                    isSelected: selectedSub == null,
                    onTap: () {
                      ref.read(selectedSubcategoryProvider.notifier).state = null;
                    },
                  ),
                  ...currentParent.subcategories.map((sub) => _SubcategoryTab(
                        label: sub,
                        isSelected: selectedSub == sub,
                        onTap: () {
                          ref.read(selectedSubcategoryProvider.notifier).state = sub;
                        },
                      )),
                ],
              ),
            ),

          const Divider(height: 1, color: PosTheme.borderLight),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Material(
        color: isSelected ? PosTheme.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? null
                  : Border.all(color: PosTheme.borderLight),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : PosTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubcategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubcategoryTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? PosTheme.secondaryBlue.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? PosTheme.primaryBlue : PosTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Filtered Menu Grid ──────────────────────────────────────────────────────

class _FilteredMenuGrid extends ConsumerWidget {
  final int crossAxisCount;
  final bool isPhone;

  const _FilteredMenuGrid({
    required this.crossAxisCount,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredMenuProvider);
    final searchQuery = ref.watch(menuSearchQueryProvider);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isNotEmpty ? Icons.search_off : Icons.restaurant_menu,
              size: 64,
              color: PosTheme.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty ? 'No items match "$searchQuery"' : 'No menu items available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PosTheme.textSecondary,
                  ),
            ),
            if (searchQuery.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ref.read(menuSearchQueryProvider.notifier).state = '';
                  ref.read(selectedCategoryProvider.notifier).state = null;
                },
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(isPhone ? 16 : 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: isPhone ? 12 : 20,
        mainAxisSpacing: isPhone ? 12 : 20,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _MenuItemCard(item: item, isPhone: isPhone);
      },
    );
  }
}

// ─── Menu Item Card (with out-of-stock overlay) ──────────────────────────────

class _MenuItemCard extends ConsumerWidget {
  final dynamic item;
  final bool isPhone;

  const _MenuItemCard({required this.item, required this.isPhone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = item.isAvailable;

    return Material(
      color: PosTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Card content
          InkWell(
            onTap: isAvailable
                ? () async {
                    final modifiers =
                        await ref.read(menuItemModifiersProvider(item.id).future);
                    if (modifiers.isEmpty) {
                      ref.read(cartProvider.notifier).addItem(item);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${item.name} to cart'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => ModifierPickerSheet(
                            menuItem: item,
                            modifierGroups: modifiers,
                          ),
                        );
                      }
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PosTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: PosTheme.primaryBlue.withValues(alpha: 0.06),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: item.imageUrl != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(context),
                              ),
                            )
                          : _buildPlaceholderIcon(context),
                    ),
                  ),

                  // Details
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(isPhone ? 12 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            '฿${item.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: PosTheme.primaryBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Out-of-stock overlay (F-013)
          if (!isAvailable)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Out of Stock',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PosTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon(BuildContext context) {
    return Icon(
      Icons.restaurant,
      size: 48,
      color: PosTheme.primaryBlue.withValues(alpha: 0.25),
    );
  }
}
