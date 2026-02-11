import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/pos_theme.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/order.dart';
import '../../../core/models/api_models.dart';
import '../../menu/providers/menu_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/repositories/order_repository.dart';

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
      body: Row(
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
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 1200
                      ? 4
                      : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _MenuItemCard(item: items[index]);
                },
              ),
            ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
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
                Icon(
                  Icons.shopping_cart_outlined,
                  color: PosTheme.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Current Order',
                    style: Theme.of(context).textTheme.titleLarge,
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
  final item;
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: PosTheme.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: PosTheme.borderLight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: onDecrease,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: onIncrease,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Price
                Text(
                  '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PosTheme.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ),
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
                _showCheckoutDialog(context, ref, total);
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

  void _showCheckoutDialog(BuildContext context, WidgetRef ref, double total) {
    showDialog(
      context: context,
      builder: (context) => _CheckoutDialog(
        total: total,
        onCheckout: (paymentMethod) async {
          // Get cart items and convert to OrderItemDto
          final cartState = ref.read(cartProvider);
          final orderItems = cartState.items.map((item) {
            return OrderItemDto(
              skuId: item.menuItem.id,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              notes: item.notes,
            );
          }).toList();

          // Create order using repository
          try {
            await ref.read(orderRepositoryProvider).createOrder(
                  source: OrderSource.dinein,
                  items: orderItems,
                  totalAmount: total,
                  paymentMethod: paymentMethod,
                );

            // Clear cart after successful order
            ref.read(cartProvider.notifier).clear();

            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order created successfully!'),
                  backgroundColor: PosTheme.successGreen,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create order: $e'),
                  backgroundColor: PosTheme.dangerRed,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class _CheckoutDialog extends StatefulWidget {
  final double total;
  final Future<void> Function(PaymentMethod) onCheckout;

  const _CheckoutDialog({
    required this.total,
    required this.onCheckout,
  });

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment Method'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<PaymentMethod>(
            title: const Text('Cash'),
            value: PaymentMethod.cash,
            groupValue: _selectedMethod,
            onChanged: (value) {
              setState(() {
                _selectedMethod = value!;
              });
            },
          ),
          RadioListTile<PaymentMethod>(
            title: const Text('PromptPay'),
            value: PaymentMethod.promptpay,
            groupValue: _selectedMethod,
            onChanged: (value) {
              setState(() {
                _selectedMethod = value!;
              });
            },
          ),
          RadioListTile<PaymentMethod>(
            title: const Text('Card'),
            value: PaymentMethod.card,
            groupValue: _selectedMethod,
            onChanged: (value) {
              setState(() {
                _selectedMethod = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Text(
                '\$${widget.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: PosTheme.primaryBlue,
                    ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCheckout(_selectedMethod);
          },
          child: const Text('Confirm Payment'),
        ),
      ],
    );
  }
}
