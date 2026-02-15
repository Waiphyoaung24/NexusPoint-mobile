import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/pos_theme.dart';
import '../../../core/models/order.dart';
import '../../orders/providers/order_provider.dart';
import '../../orders/repositories/order_repository.dart';

class BridgeDashboardScreen extends ConsumerWidget {
  const BridgeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridge Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(ordersProvider);
            },
            tooltip: 'Refresh Orders',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) => _buildKanbanBoard(context, orders),
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
                'Failed to load orders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: PosTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKanbanBoard(BuildContext context, List<Order> orders) {
    // Filter orders by status
    final incomingOrders =
        orders.where((o) => o.status == OrderStatus.pending).toList();
    final cookingOrders =
        orders.where((o) => o.status == OrderStatus.confirmed).toList();
    final readyOrders =
        orders.where((o) => o.status == OrderStatus.completed).toList();
    // delivered orders are intentionally excluded — they leave the board

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Incoming Column
          Expanded(
            child: KanbanColumn(
              title: 'Incoming Orders',
              count: incomingOrders.length,
              color: PosTheme.secondaryBlue,
              orders: incomingOrders,
            ),
          ),
          const SizedBox(width: 16),

          // Cooking Column
          Expanded(
            child: KanbanColumn(
              title: 'Cooking Now',
              count: cookingOrders.length,
              color: PosTheme.accentAmber,
              orders: cookingOrders,
            ),
          ),
          const SizedBox(width: 16),

          // Ready Column
          Expanded(
            child: KanbanColumn(
              title: 'Ready for Pickup',
              count: readyOrders.length,
              color: PosTheme.successGreen,
              orders: readyOrders,
            ),
          ),
        ],
      ),
    );
  }
}

class KanbanColumn extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final List<Order> orders;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PosTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PosTheme.borderLight),
        boxShadow: [PosTheme.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: PosTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Order Cards List
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: PosTheme.textSecondary.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No orders',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: PosTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return KanbanOrderCard(
                        order: order,
                        accentColor: color,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class KanbanOrderCard extends StatelessWidget {
  final Order order;
  final Color accentColor;

  const KanbanOrderCard({
    super.key,
    required this.order,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'order-${order.localId}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            _showOrderDetails(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Number & Time
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.orderNumber,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: PosTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(order.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Items List
                ...order.items.take(3).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: PosTheme.textPrimary,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.menuItem.name,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),

                if (order.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${order.items.length - 3} more items',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: PosTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Footer: Total & Sync Status
                Row(
                  children: [
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: PosTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    _buildSyncIndicator(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncIndicator(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          order.isSynced ? Icons.cloud_done : Icons.cloud_queue,
          size: 14,
          color: order.isSynced
              ? PosTheme.successGreen
              : PosTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          order.isSynced ? 'Synced' : 'Local',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: order.isSynced
                    ? PosTheme.successGreen
                    : PosTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsModal(order: order),
    );
  }
}

class OrderDetailsModal extends ConsumerStatefulWidget {
  final Order order;

  const OrderDetailsModal({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<OrderDetailsModal> createState() => _OrderDetailsModalState();
}

class _OrderDetailsModalState extends ConsumerState<OrderDetailsModal> {
  bool _isUpdating = false;

  // Determine the next logical status and button label
  ({OrderStatus? next, String label, Color color, IconData icon, bool isDelivery})?
      get _nextAction {
    return switch (widget.order.status) {
      OrderStatus.pending => (
          next: OrderStatus.confirmed,
          label: 'Start Cooking',
          color: PosTheme.accentAmber,
          icon: Icons.outdoor_grill_outlined,
          isDelivery: false,
        ),
      OrderStatus.confirmed => (
          next: OrderStatus.completed,
          label: 'Mark Ready',
          color: PosTheme.successGreen,
          icon: Icons.check_circle_outline,
          isDelivery: false,
        ),
      OrderStatus.completed => (
          next: OrderStatus.delivered,
          label: 'Mark Delivered',
          color: PosTheme.primaryBlue,
          icon: Icons.local_shipping_outlined,
          isDelivery: true,
        ),
      _ => null, // delivered / cancelled — final states
    };
  }

  Future<void> _advanceStatus() async {
    final action = _nextAction;
    final localId = widget.order.localId;
    if (action == null || action.next == null || localId == null) return;

    setState(() => _isUpdating = true);
    try {
      if (action.isDelivery) {
        // Mark delivered locally + push to cloud if already synced
        await ref.read(orderRepositoryProvider).markDelivered(
              localId,
              serverId: widget.order.isSynced ? widget.order.orderId : null,
            );
      } else {
        await ref
            .read(orderRepositoryProvider)
            .updateStatus(localId, action.next!);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = _nextAction;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: PosTheme.surfaceWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: PosTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.orderNumber,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order Details',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: PosTheme.textSecondary,
                                ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items
                  Text(
                    'Items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...widget.order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: PosTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${item.quantity}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: PosTheme.primaryBlue,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.menuItem.name,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (item.notes != null)
                                    Text(
                                      item.notes!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: PosTheme.textSecondary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 24),
                  const Divider(),
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
                        '\$${widget.order.totalAmount.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: PosTheme.primaryBlue,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action Button
          if (action != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _isUpdating ? null : _advanceStatus,
                    style: FilledButton.styleFrom(
                      backgroundColor: action.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(action.icon),
                    label: Text(
                      _isUpdating ? 'Updating…' : action.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
}
