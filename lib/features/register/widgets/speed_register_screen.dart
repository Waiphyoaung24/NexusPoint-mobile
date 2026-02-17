import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/pos_theme.dart';
import '../../../core/models/menu_item.dart';
import '../../menu/providers/menu_provider.dart';
import '../../../core/models/cart_item.dart';
import '../../cart/providers/cart_provider.dart';
import '../../checkout/widgets/checkout_modal.dart';
import '../../../shared/widgets/loading_skeleton.dart';

class SpeedRegisterScreen extends ConsumerWidget {
  const SpeedRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Register'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(menuProvider);
            },
            tooltip: 'Refresh Menu',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 900;
          
          if (isNarrow) {
            return Column(
              children: [
                // Top: Menu Grid (flexible height)
                Expanded(
                  flex: 3,
                  child: _MenuGrid(),
                ),
                // Divider
                const Divider(height: 1, thickness: 1, color: PosTheme.borderLight),
                // Bottom: Cart Panel (fixed-ish height)
                Expanded(
                  flex: 2,
                  child: _CartPanel(),
                ),
              ],
            );
          }

          return Row(
            children: [
              // Left: Menu Grid (2/3)
              Expanded(
                flex: 2,
                child: _MenuGrid(),
              ),

              // Vertical Divider
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: PosTheme.borderLight,
              ),

              // Right: Cart Panel (1/3)
              Expanded(
                flex: 1,
                child: _CartPanel(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuProvider);

    return menuAsync.when(
      data: (items) => items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu_outlined,
                    size: 64,
                    color: PosTheme.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No menu items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: PosTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 1200
                          ? 5
                          : constraints.maxWidth > 900
                              ? 4
                              : constraints.maxWidth > 600
                                  ? 3
                                  : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _MenuItemCard(item: items[index]);
                    },
                  ),
                );
              },
            ),
      loading: () => const MenuGridSkeleton(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: PosTheme.dangerRed.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load menu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PosTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemCard extends ConsumerWidget {
  final MenuItem item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(cartProvider.notifier).addItem(item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${item.name} to cart'),
              duration: const Duration(milliseconds: 800),
              behavior: SnackBarBehavior.floating,
              width: 300,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image Placeholder
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: PosTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 48,
                      color: PosTheme.primaryBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Item Name
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Item Price
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: PosTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Container(
      color: PosTheme.backgroundLight,
      child: Column(
        children: [
          // Cart Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: PosTheme.surfaceWhite,
              border: Border(
                bottom: BorderSide(color: PosTheme.borderLight),
              ),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: PosTheme.primaryBlue,
                      size: 24,
                    ),
                    if (cart.items.isNotEmpty)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: PosTheme.dangerRed,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '${cart.items.fold(0, (sum, item) => sum + item.quantity)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Current Order',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
                if (cart.items.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _showClearCartDialog(context, ref);
                    },
                    tooltip: 'Clear Cart',
                    color: PosTheme.dangerRed,
                  ),
              ],
            ),
          ),

          // Cart Items List
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: PosTheme.textSecondary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cart is empty',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: PosTheme.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add items from menu',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: PosTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _CartItemCard(
                        item: item,
                        onRemove: () {
                          ref.read(cartProvider.notifier).removeItem(index);
                        },
                        onIncrease: () {
                          ref.read(cartProvider.notifier).addItem(item.menuItem);
                        },
                        onDecrease: () {
                          if (item.quantity > 1) {
                            ref
                                .read(cartProvider.notifier)
                                .updateQuantity(index, item.quantity - 1);
                          } else {
                            ref.read(cartProvider.notifier).removeItem(index);
                          }
                        },
                      );
                    },
                  ),
          ),

          // Cart Summary & Checkout
          if (cart.items.isNotEmpty) _CartSummary(cart: cart),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clear();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PosTheme.dangerRed,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: PosTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.menuItem.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: PosTheme.textSecondary.withValues(alpha: 0.5),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 10),

            LayoutBuilder(
              builder: (context, constraints) {
                final useVertical = constraints.maxWidth < 160;
                
                final controls = Container(
                  decoration: BoxDecoration(
                    color: PosTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CompactQtyButton(
                        icon: Icons.remove,
                        onPressed: onDecrease,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        constraints: const BoxConstraints(minWidth: 24),
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: PosTheme.primaryBlue,
                                ),
                          ),
                        ),
                      ),
                      _CompactQtyButton(
                        icon: Icons.add,
                        onPressed: onIncrease,
                      ),
                    ],
                  ),
                );

                final price = Text(
                  '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: PosTheme.primaryBlue,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                  textAlign: TextAlign.right,
                );

                if (useVertical) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      controls,
                      const SizedBox(height: 8),
                      price,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: controls),
                    const SizedBox(width: 8),
                    Flexible(child: price),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactQtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CompactQtyButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: PosTheme.textSecondary),
      ),
    );
  }
}

class _CartSummary extends ConsumerWidget {
  final CartState cart;

  const _CartSummary({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = cart.total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: PosTheme.surfaceWhite,
        border: Border(
          top: BorderSide(color: PosTheme.borderLight),
        ),
      ),
      child: Column(
        children: [
          // Subtotal
          Row(
            children: [
              Text(
                'Subtotal',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Total
          Row(
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: PosTheme.primaryBlue,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                showCheckoutModal(context, total);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment),
                  const SizedBox(width: 8),
                  Text(
                    'Checkout',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
