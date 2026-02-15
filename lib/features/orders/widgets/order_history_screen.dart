import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/order.dart';
import '../../../core/theme/pos_theme.dart';
import '../providers/order_provider.dart';

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
            size: 80,
            color: PosTheme.textSecondary.withValues(alpha: 0.3),
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
            'Orders created from the Register will appear here',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: PosTheme.dangerRed),
          const SizedBox(height: 16),
          Text(
            'Failed to load orders',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    // Group orders by day
    final grouped = <String, List<Order>>{};
    final dayFmt = DateFormat('EEEE, MMM d, yyyy');

    for (final order in orders) {
      final key = dayFmt.format(order.createdAt);
      grouped.putIfAbsent(key, () => []).add(order);
    }

    final days = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: days.length,
      itemBuilder: (context, dayIndex) {
        final day = days[dayIndex];
        final dayOrders = grouped[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                day,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: PosTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
              ),
            ),
            ...dayOrders.map((order) => _OrderCard(order: order)),
          ],
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => _showOrderDetail(context, order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Source icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _sourceColor(order.source).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _sourceIcon(order.source),
                  color: _sourceColor(order.source),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.orderNumber,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: PosTheme.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat('h:mm a').format(order.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(status: order.status),
                        const Spacer(),
                        _SyncBadge(isSynced: order.isSynced),
                      ],
                    ),
                    if (order.items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetail(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _OrderDetailSheet(order: order),
    );
  }

  IconData _sourceIcon(OrderSource source) {
    return switch (source) {
      OrderSource.dinein => Icons.table_restaurant,
      OrderSource.grab => Icons.delivery_dining,
      OrderSource.wongnai => Icons.restaurant,
    };
  }

  Color _sourceColor(OrderSource source) {
    return switch (source) {
      OrderSource.dinein => PosTheme.primaryBlue,
      OrderSource.grab => const Color(0xFF00B14F),
      OrderSource.wongnai => const Color(0xFFE5232A),
    };
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderStatus.pending => ('Pending', PosTheme.accentAmber),
      OrderStatus.confirmed => ('Confirmed', PosTheme.secondaryBlue),
      OrderStatus.completed => ('Ready', PosTheme.successGreen),
      OrderStatus.delivered => ('Delivered', PosTheme.primaryBlue),
      OrderStatus.cancelled => ('Cancelled', PosTheme.dangerRed),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final bool isSynced;
  const _SyncBadge({required this.isSynced});

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

class _OrderDetailSheet extends StatelessWidget {
  final Order order;
  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('MMM d, yyyy — h:mm a');

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: PosTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Order Number
              Text(
                order.orderNumber,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                timeFmt.format(order.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: 16),

              // Status + Sync row
              Row(
                children: [
                  _StatusChip(status: order.status),
                  const SizedBox(width: 8),
                  _SyncBadge(isSynced: order.isSynced),
                ],
              ),

              const Divider(height: 32),

              // Items
              Text(
                'Items',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}×',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: PosTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.menuItem.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '\$${item.lineTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),

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

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
