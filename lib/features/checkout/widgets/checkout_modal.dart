import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/pos_theme.dart';
import '../../../core/models/order.dart';
import '../../../core/models/api_models.dart';
import '../../../core/models/user.dart';
import '../../../core/utils/permission_gate.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/repositories/order_repository.dart';
import '../../orders/providers/order_context_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/role_based_approval.dart';
import '../providers/checkout_provider.dart';
import '../../printer/providers/printer_provider.dart';
import '../../printer/services/printer_service.dart';
import '../../printer/services/receipt_builder.dart';
import '../../printer/services/kitchen_ticket_builder.dart';
import '../../orders/services/order_polling_service.dart';
import 'discount_entry_dialog.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    // Source badge
                    _buildSourceBadge(ref),
                  ],
                ),
                const SizedBox(height: 16),
                // VAT breakdown
                _buildVatBreakdown(context, ref),
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
                      isSelected: checkout.paymentMethod == PaymentMethod.cash && !checkout.isSplit,
                      onTap: () => ref
                          .read(checkoutProvider.notifier)
                          .selectPaymentMethod(PaymentMethod.cash),
                    ),
                    const SizedBox(width: 12),
                    _PaymentMethodButton(
                      icon: Icons.qr_code,
                      label: 'PromptPay',
                      isSelected: checkout.paymentMethod == PaymentMethod.promptpay && !checkout.isSplit,
                      onTap: () => ref
                          .read(checkoutProvider.notifier)
                          .selectPaymentMethod(PaymentMethod.promptpay),
                    ),
                    const SizedBox(width: 12),
                    _PaymentMethodButton(
                      icon: Icons.call_split,
                      label: 'Split',
                      isSelected: checkout.isSplit,
                      onTap: () => _showSplitPaymentDialog(context, ref),
                    ),
                  ],
                ),
                // Split payment indicator
                if (checkout.isSplit) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PosTheme.primaryBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PosTheme.primaryBlue.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        ...checkout.payments.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.method.name.toUpperCase(),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              Text('฿${p.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 13, color: PosTheme.primaryBlue)),
                            ],
                          ),
                        )),
                        const Divider(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Cash remainder',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('฿${checkout.remainingBalance.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                    color: PosTheme.primaryBlue)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => ref.read(checkoutProvider.notifier).cancelSplit(),
                            child: const Text('Cancel Split', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                        'Confirm Payment — ฿${ref.read(cartProvider).grandTotal.toStringAsFixed(2)}',
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

      // Read order context and auth for new fields
      final orderCtx = ref.read(orderContextProvider);
      final authState = ref.read(authProvider);
      final userId = authState.maybeWhen(
        authenticated: (user) => user.id,
        orElse: () => null,
      );

      // Map OrderType to source enum
      final source = switch (orderCtx?.orderType) {
        OrderType.delivery => _deliverySource(orderCtx?.deliveryPlatform),
        _ => OrderSource.dinein,
      };

      // Convert Dart enum camelCase to API snake_case
      final orderTypeStr = switch (orderCtx?.orderType) {
        OrderType.dineIn => 'dine_in',
        OrderType.takeaway => 'takeaway',
        OrderType.delivery => 'delivery',
        null => null,
      };

      final order = await ref.read(orderRepositoryProvider).createOrder(
            source: source,
            orderType: orderTypeStr,
            tableId: orderCtx?.tableId,
            tableNumber: orderCtx?.tableNumber?.toString(),
            createdBy: userId,
            subtotalAmount: cartState.subtotal,
            vatAmount: cartState.taxAmount,
            vatRate: cartState.vatRate * 100,
            discountPercent: cartState.hasDiscount ? cartState.discountPercent : null,
            discountAmount: cartState.hasDiscount ? cartState.discountAmount : null,
            discountApproverId: cartState.discountApproverId,
            discountReason: cartState.discountReason,
            items: orderItems,
            totalAmount: cartState.grandTotal,
            paymentMethod: checkout.paymentMethod,
            tenderedAmount: checkout.tenderedAmount,
            changeAmount: checkout.changeAmount > 0 ? checkout.changeAmount : null,
            payments: checkout.allPayments.map((p) => p.toJson()).toList(),
            modifiersPerItem: modifiersPerItem,
          );

      // Clear cart, order context, and mark success
      ref.read(cartProvider.notifier).clear();
      ref.read(orderContextProvider.notifier).state = null;
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

  Widget _buildSourceBadge(WidgetRef ref) {
    final orderCtx = ref.watch(orderContextProvider);
    if (orderCtx == null) return const SizedBox.shrink();

    final (label, color) = switch (orderCtx.orderType) {
      OrderType.dineIn => ('Dine-in — Table ${orderCtx.tableNumber ?? ''}', PosTheme.primaryBlue),
      OrderType.takeaway => ('Takeaway — ${orderCtx.ticketNumber ?? ''}', PosTheme.accentAmber),
      OrderType.delivery => ('Delivery — ${orderCtx.deliveryPlatform ?? ''}', PosTheme.successGreen),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.openSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildVatBreakdown(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);
    final userRole = authState.whenOrNull(
      authenticated: (user) => user.staffRole ?? user.role,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PosTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _vatRow(context, 'Subtotal', cart.subtotal),

          // Discount line (F-008)
          if (cart.hasDiscount) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Discount (${cart.discountPercent.toStringAsFixed(0)}%)',
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                        color: PosTheme.dangerRed,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        ref.read(cartProvider.notifier).removeDiscount();
                      },
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: PosTheme.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                Text(
                  '-\$${cart.discountAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    color: PosTheme.dangerRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          // Discount button (F-008) — only for owner/manager
          if (!cart.hasDiscount)
            PermissionGate(
              role: userRole,
              action: 'discount.apply',
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _handleApplyDiscount(context, ref),
                  icon: const Icon(Icons.percent, size: 16),
                  label: const Text('Apply Discount'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PosTheme.primaryBlue,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 4),
          _vatRow(context, 'VAT ${(cart.vatRate * 100).toStringAsFixed(0)}%', cart.taxAmount),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1),
          ),
          _vatRow(context, 'Grand Total', cart.grandTotal, bold: true),
        ],
      ),
    );
  }

  Future<void> _handleApplyDiscount(BuildContext context, WidgetRef ref) async {
    // Role-based approval
    final approval = await showRoleBasedApproval(
      context,
      ref: ref,
      action: 'discount.apply',
    );
    if (approval == null || !context.mounted) return;

    // Show discount entry dialog
    final cart = ref.read(cartProvider);
    final entry = await showDiscountEntryDialog(
      context,
      subtotal: cart.subtotal,
    );
    if (entry == null || !context.mounted) return;

    // Apply discount to cart
    ref.read(cartProvider.notifier).applyDiscount(
          percent: entry.percent,
          approverId: approval.approverId,
          reason: entry.reason,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Discount applied: ${entry.percent.toStringAsFixed(0)}%'),
          backgroundColor: PosTheme.successGreen,
        ),
      );
    }
  }

  /// F-006: Show split payment dialog — user picks first method + amount.
  void _showSplitPaymentDialog(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider);
    final total = cart.grandTotal;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        PaymentMethod selectedMethod = PaymentMethod.promptpay;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Split Payment'),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total: ฿${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    const Text('First payment method:'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('PromptPay'),
                          selected: selectedMethod == PaymentMethod.promptpay,
                          onSelected: (_) =>
                              setDialogState(() => selectedMethod = PaymentMethod.promptpay),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Card'),
                          selected: selectedMethod == PaymentMethod.card,
                          onSelected: (_) =>
                              setDialogState(() => selectedMethod = PaymentMethod.card),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount (฿)',
                        hintText: 'Remaining paid in cash',
                        border: const OutlineInputBorder(),
                        helperText: 'Max: ฿${total.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0 || amount >= total) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter an amount less than total')),
                      );
                      return;
                    }
                    ref.read(checkoutProvider.notifier).enableSplit(selectedMethod, amount);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Split'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _vatRow(BuildContext context, String label, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? PosTheme.textPrimary : PosTheme.textSecondary,
          ),
        ),
        Text(
          '฿${amount.toStringAsFixed(2)}',
          style: GoogleFonts.openSans(
            fontSize: bold ? 16 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? PosTheme.primaryBlue : PosTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  OrderSource _deliverySource(String? platform) {
    return switch (platform) {
      'grab' => OrderSource.grab,
      'wongnai' => OrderSource.wongnai,
      _ => OrderSource.dinein,
    };
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
