import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/pos_theme.dart';
import '../../../core/models/order.dart';
import '../../../core/models/api_models.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/repositories/order_repository.dart';
import '../providers/checkout_provider.dart';
import '../../printer/providers/printer_provider.dart';
import '../../printer/services/printer_service.dart';
import '../../printer/services/receipt_builder.dart';
import '../../printer/services/kitchen_ticket_builder.dart';
import '../../orders/services/order_polling_service.dart';

Future<bool> showCheckoutModal(BuildContext context, double total) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CheckoutModal(total: total),
  );
  return result ?? false;
}

class CheckoutModal extends ConsumerStatefulWidget {
  final double total;
  const CheckoutModal({super.key, required this.total});

  @override
  ConsumerState<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends ConsumerState<CheckoutModal> {
  final _tenderedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier).setOrderTotal(widget.total);
    });
  }

  @override
  void dispose() {
    _tenderedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: PosTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
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
                const Icon(Icons.payment, color: PosTheme.primaryBlue, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Checkout',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '฿${widget.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: PosTheme.primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Payment method selector
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Method',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _PaymentMethodButton(
                      icon: Icons.money,
                      label: 'Cash',
                      isSelected: checkout.paymentMethod == PaymentMethod.cash,
                      onTap: () => ref
                          .read(checkoutProvider.notifier)
                          .selectPaymentMethod(PaymentMethod.cash),
                    ),
                    const SizedBox(width: 12),
                    _PaymentMethodButton(
                      icon: Icons.qr_code,
                      label: 'PromptPay',
                      isSelected: checkout.paymentMethod == PaymentMethod.promptpay,
                      onTap: () => ref
                          .read(checkoutProvider.notifier)
                          .selectPaymentMethod(PaymentMethod.promptpay),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payment details
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: checkout.paymentMethod == PaymentMethod.cash
                  ? _CashPaymentSection(
                      total: widget.total,
                      tenderedController: _tenderedController,
                    )
                  : _PromptPaySection(total: widget.total),
            ),
          ),

          // Submit button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: checkout.canSubmit && checkout.status != CheckoutStatus.processing
                    ? () => _submitOrder(context, ref)
                    : null,
                child: checkout.status == CheckoutStatus.processing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Confirm Payment — ฿${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),

          // Error message
          if (checkout.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
              child: Text(
                checkout.errorMessage!,
                style: const TextStyle(color: PosTheme.dangerRed),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submitOrder(BuildContext context, WidgetRef ref) async {
    final checkoutNotifier = ref.read(checkoutProvider.notifier);
    checkoutNotifier.setProcessing();

    try {
      final cartState = ref.read(cartProvider);
      final checkout = ref.read(checkoutProvider);
      final cartItems = cartState.items.toList();

      final orderItems = cartItems.map((item) {
        // Build modifier summary string e.g. "Size: Large" for receipt notes
        final modifierSummary = item.selectedModifiers.isNotEmpty
            ? item.selectedModifiers.map((m) => '${m.groupName}: ${m.name}').join(', ')
            : null;
        final combinedNotes = [
          if (item.notes?.isNotEmpty == true) item.notes!,
          if (modifierSummary != null) modifierSummary,
        ].join(' | ');

        return OrderItemDto(
          skuId: item.menuItem.id,
          name: item.menuItem.name,
          quantity: item.quantity,
          // Modifier price baked in so local totals are correct
          unitPrice: item.unitPrice + item.modifierTotal,
          notes: combinedNotes.isNotEmpty ? combinedNotes : null,
        );
      }).toList();

      // Pass structured modifier data so the API can write order_item_modifier rows
      final modifiersPerItem = cartItems.map((item) => item.selectedModifiers).toList();

      final order = await ref.read(orderRepositoryProvider).createOrder(
            source: OrderSource.dinein,
            items: orderItems,
            totalAmount: widget.total,
            paymentMethod: checkout.paymentMethod,
            modifiersPerItem: modifiersPerItem,
          );

      // Clear cart and mark success
      ref.read(cartProvider.notifier).clear();
      checkoutNotifier.setSuccess(order.orderNumber);

      // Trigger immediate poll so other devices see this order faster
      ref.read(orderPollingServiceProvider.notifier).pollNow();

      // Auto-print receipt and kitchen ticket (if printer connected)
      _autoPrint(ref, order, checkout);

      if (context.mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order ${order.orderNumber} created!'),
            backgroundColor: PosTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      checkoutNotifier.setError('Failed to create order: $e');
    }
  }

  /// Queue receipt + kitchen ticket print jobs after successful checkout.
  Future<void> _autoPrint(WidgetRef ref, Order order, CheckoutState checkout) async {
    final printerState = ref.read(printerProvider);
    if (!printerState.isConnected) return;

    try {
      // Build receipt bytes
      final receiptBuilder = ReceiptBuilder();
      final receiptBytes = await receiptBuilder.buildReceipt(
        order: order,
        tenderedAmount: checkout.paymentMethod == PaymentMethod.cash
            ? checkout.tenderedAmount
            : null,
        changeAmount: checkout.paymentMethod == PaymentMethod.cash
            ? checkout.changeAmount
            : null,
      );

      ref.read(printerProvider.notifier).enqueueJob(PrintJob(
        type: PrintJobType.receipt,
        data: receiptBytes,
        orderNumber: order.orderNumber,
      ));

      // Build kitchen ticket bytes
      final kitchenBuilder = KitchenTicketBuilder();
      final kitchenBytes = await kitchenBuilder.buildTicket(order: order);

      ref.read(printerProvider.notifier).enqueueJob(PrintJob(
        type: PrintJobType.kitchenTicket,
        data: kitchenBytes,
        orderNumber: order.orderNumber,
      ));
    } catch (e) {
      debugPrint('Auto-print failed: $e');
    }
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? PosTheme.primaryBlue.withValues(alpha: 0.1)
                : PosTheme.backgroundLight,
            border: Border.all(
              color: isSelected ? PosTheme.primaryBlue : PosTheme.borderLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? PosTheme.primaryBlue : PosTheme.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? PosTheme.primaryBlue : PosTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashPaymentSection extends ConsumerWidget {
  final double total;
  final TextEditingController tenderedController;

  const _CashPaymentSection({
    required this.total,
    required this.tenderedController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutProvider);
    final suggestions = ref.read(checkoutProvider.notifier).quickCashSuggestions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount Received',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Quick cash buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((amount) {
            return ActionChip(
              label: Text('฿${amount.toStringAsFixed(0)}'),
              onPressed: () {
                tenderedController.text = amount.toStringAsFixed(0);
                ref.read(checkoutProvider.notifier).setTenderedAmount(amount);
              },
              backgroundColor: PosTheme.backgroundLight,
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Manual input
        TextField(
          controller: tenderedController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            prefixText: '฿ ',
            hintText: 'Enter amount',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                tenderedController.clear();
                ref.read(checkoutProvider.notifier).setTenderedAmount(0);
              },
            ),
          ),
          style: Theme.of(context).textTheme.headlineSmall,
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0;
            ref.read(checkoutProvider.notifier).setTenderedAmount(amount);
          },
        ),

        const SizedBox(height: 24),

        // Change display
        if (checkout.tenderedAmount != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: checkout.changeAmount >= 0
                  ? PosTheme.successGreen.withValues(alpha: 0.1)
                  : PosTheme.dangerRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: checkout.changeAmount >= 0
                    ? PosTheme.successGreen
                    : PosTheme.dangerRed,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  checkout.changeAmount >= 0 ? 'Change' : 'Insufficient',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '฿${checkout.changeAmount.abs().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: checkout.changeAmount >= 0
                        ? PosTheme.successGreen
                        : PosTheme.dangerRed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _PromptPaySection extends StatelessWidget {
  final double total;

  const _PromptPaySection({required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // QR Placeholder
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: PosTheme.borderLight, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_2,
                size: 80,
                color: PosTheme.primaryBlue,
              ),
              const SizedBox(height: 8),
              Text(
                '฿${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: PosTheme.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Scan QR code to pay via PromptPay',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: PosTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
