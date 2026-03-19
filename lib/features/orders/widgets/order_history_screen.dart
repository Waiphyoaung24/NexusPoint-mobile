import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/order.dart';
import '../../../core/models/user.dart';
import '../../../core/theme/pos_theme.dart';
import '../../../core/utils/permission_gate.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/role_based_approval.dart';
import '../providers/order_provider.dart';
import '../repositories/order_repository.dart';
import 'void_reason_dialog.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          ordersAsync.whenOrNull(
                data: (orders) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      '${orders.length} orders',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PosTheme.textSecondary,
                          ),
                    ),
                  ),
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? _EmptyState()
            : _OrderList(orders: orders),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorState(error: error),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: PosTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PosTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here once created',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PosTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: PosTheme.dangerRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load orders',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PosTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    // Group orders by date
    final groupedOrders = <String, List<Order>>{};
    final dateFmt = DateFormat('MMMM d, yyyy');
    for (final order in orders) {
      final key = dateFmt.format(order.createdAt);
      groupedOrders.putIfAbsent(key, () => []).add(order);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedOrders.length,
      itemBuilder: (context, groupIndex) {
        final date = groupedOrders.keys.elementAt(groupIndex);
        final groupOrders = groupedOrders[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (groupIndex > 0) const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                date,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: PosTheme.textSecondary,
                    ),
              ),
            ),
            ...groupOrders.map((order) => _OrderCard(order: order)),
          ],
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return PosTheme.primaryBlue;
      case OrderStatus.delivered:
        return PosTheme.successGreen;
      case OrderStatus.cancelled:
        return PosTheme.dangerRed;
      case OrderStatus.completed:
        return PosTheme.successGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => OrderDetailSheet(order: order),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.items.length} items  ·  ${timeFmt.format(order.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: PosTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),

              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  _StatusBadge(status: order.status, color: _statusColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SyncIndicator extends StatelessWidget {
  final bool isSynced;
  const _SyncIndicator({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSynced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
          size: 14,
          color: isSynced ? PosTheme.successGreen : PosTheme.textSecondary,
        ),
        const SizedBox(width: 3),
        Text(
          isSynced ? 'Synced' : 'Local',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    isSynced ? PosTheme.successGreen : PosTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}

class OrderDetailSheet extends ConsumerWidget {
  final Order order;
  const OrderDetailSheet({super.key, required this.order});

  bool get _canVoid =>
      order.status != OrderStatus.cancelled &&
      order.status != OrderStatus.delivered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFmt = DateFormat('MMM d, yyyy — h:mm a');

    // Get user role for permission gating
    final authState = ref.watch(authProvider);
    final userRole = authState.whenOrNull(
      authenticated: (user) => user.staffRole ?? user.role,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PosTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  _SyncIndicator(isSynced: order.isSynced),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                timeFmt.format(order.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PosTheme.textSecondary,
                    ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Items
              Text(
                'Items',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...order.items.asMap().entries.map((entry) {
                final item = entry.value;
                final isVoided = _isItemVoided(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}×',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: PosTheme.textSecondary,
                              decoration: isVoided ? TextDecoration.lineThrough : null,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.menuItem.name,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      decoration: isVoided ? TextDecoration.lineThrough : null,
                                      color: isVoided ? PosTheme.textSecondary : null,
                                    ),
                              ),
                            ),
                            if (isVoided) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: PosTheme.dangerRed.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'VOIDED',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: PosTheme.dangerRed,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              decoration: isVoided ? TextDecoration.lineThrough : null,
                              color: isVoided ? PosTheme.textSecondary : null,
                            ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: PosTheme.primaryBlue,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Payment method
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PosTheme.textSecondary,
                        ),
                  ),
                  Text(
                    order.paymentMethod.name.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),

              if (order.tableNumber != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Table',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PosTheme.textSecondary,
                          ),
                    ),
                    Text(
                      order.tableNumber!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],

              // Void / Cancel action buttons (permission-gated)
              if (_canVoid) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                PermissionGate(
                  role: userRole,
                  action: 'order.void',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_hasNonVoidedItems)
                        OutlinedButton.icon(
                          onPressed: () => _handleVoidItem(context, ref),
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('Void Item'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PosTheme.dangerRed,
                            side: const BorderSide(color: PosTheme.dangerRed),
                          ),
                        ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () => _handleCancelOrder(context, ref),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel Order'),
                        style: FilledButton.styleFrom(
                          backgroundColor: PosTheme.dangerRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  /// Check if an item at the given index is voided (from local JSON data).
  bool _isItemVoided(int index) {
    // Items in the order model don't carry voided status directly.
    // We check via the cart item — voided items would have been marked
    // in the local JSON. For display, we rely on the order total being
    // recalculated. A proper solution would propagate voided status
    // through the Order model, but for now we check if total is 0.
    return false; // Will be enhanced when Order model carries item-level void status
  }

  /// Check if there are non-voided items to void.
  bool get _hasNonVoidedItems => order.items.isNotEmpty;

  Future<void> _handleVoidItem(BuildContext context, WidgetRef ref) async {
    if (order.items.isEmpty) return;

    // If multiple items, let cashier pick which one
    int itemIndex = 0;
    if (order.items.length > 1) {
      final selected = await showDialog<int>(
        context: context,
        builder: (_) => SimpleDialog(
          title: const Text('Select item to void'),
          children: order.items.asMap().entries.map((entry) {
            return SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(entry.key),
              child: Text('${entry.value.quantity}× ${entry.value.menuItem.name}'),
            );
          }).toList(),
        ),
      );
      if (selected == null) return;
      itemIndex = selected;
    }

    // Ask for reason
    if (!context.mounted) return;
    final reason = await showVoidReasonDialog(context, title: 'Void Item');
    if (reason == null || !context.mounted) return;

    // Role-based approval (F-009)
    final approval = await showRoleBasedApproval(
      context,
      ref: ref,
      action: 'order.void',
    );
    if (approval == null || !context.mounted) return;

    // Get current user ID as requester
    final user = ref.read(authProvider).whenOrNull(
      authenticated: (user) => user,
    );
    if (user == null) return;

    // Execute void
    try {
      final repo = ref.read(orderRepositoryProvider);
      await repo.voidItem(
        localOrderId: order.localId!,
        itemIndex: itemIndex,
        reason: reason,
        requesterId: user.id,
        approverId: approval.approverId,
      );
      if (context.mounted) {
        Navigator.of(context).pop(); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item voided'),
            backgroundColor: PosTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to void item: $e'),
            backgroundColor: PosTheme.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _handleCancelOrder(BuildContext context, WidgetRef ref) async {
    // Ask for reason
    final reason = await showVoidReasonDialog(context, title: 'Cancel Order');
    if (reason == null || !context.mounted) return;

    // Role-based approval (F-009)
    final approval = await showRoleBasedApproval(
      context,
      ref: ref,
      action: 'order.cancel',
    );
    if (approval == null || !context.mounted) return;

    // Get current user ID as requester
    final user = ref.read(authProvider).whenOrNull(
      authenticated: (user) => user,
    );
    if (user == null) return;

    // Execute cancel
    try {
      final repo = ref.read(orderRepositoryProvider);
      await repo.voidOrder(
        localOrderId: order.localId!,
        reason: reason,
        requesterId: user.id,
        approverId: approval.approverId,
      );
      if (context.mounted) {
        Navigator.of(context).pop(); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled'),
            backgroundColor: PosTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: $e'),
            backgroundColor: PosTheme.dangerRed,
          ),
        );
      }
    }
  }
}
