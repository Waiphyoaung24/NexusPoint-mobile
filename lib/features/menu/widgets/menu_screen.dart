import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/menu_provider.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive breakpoints
          final isPhone = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

          // Adaptive columns for grid
          final crossAxisCount = isPhone ? 2 : isTablet ? 3 : 4;

          return SafeArea(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(context, ref, authState, cart, isPhone),

                // Content
                Expanded(
                  child: menuAsync.when(
                    data: (items) => _buildMenuGrid(
                      context,
                      ref,
                      items,
                      crossAxisCount,
                      isPhone,
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
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo & Title
          Container(
            width: isPhone ? 48 : 56,
            height: isPhone ? 48 : 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                authState.whenOrNull(
                  authenticated: (user, _) => Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                  ),
                ) ??
                    const SizedBox.shrink(),
              ],
            ),
          ),

          // Cart Badge
          _buildCartButton(context, ref, cart, isPhone),

          const SizedBox(width: 12),

          // Logout Button
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
              // TODO: Navigate to cart/checkout
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${cart.itemCount} items • ฿${cart.total.toStringAsFixed(2)}',
                  ),
                  action: SnackBarAction(
                    label: 'View Cart',
                    onPressed: () {
                      // TODO: Navigate to cart
                    },
                  ),
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

  Widget _buildMenuGrid(
    BuildContext context,
    WidgetRef ref,
    List items,
    int crossAxisCount,
    bool isPhone,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.black.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No menu items available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
            ),
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
        return _buildMenuItem(context, ref, item, isPhone);
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    WidgetRef ref,
    dynamic item,
    bool isPhone,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          ref.read(cartProvider.notifier).addItem(item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${item.name} to cart'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderIcon(context);
                            },
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
                      // Name
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),

                      // Price & Availability
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '฿${item.price.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (!item.isAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Out',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(BuildContext context) {
    return Icon(
      Icons.restaurant,
      size: 48,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading menu...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.5),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading menu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
