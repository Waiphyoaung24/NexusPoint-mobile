import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import '../../../core/models/order.dart';

/// Builds ESC/POS byte data for customer receipts.
class ReceiptBuilder {
  final String storeName;
  final PaperSize paperSize;

  ReceiptBuilder({
    this.storeName = 'NexusPoint POS',
    this.paperSize = PaperSize.mm80,
  });

  /// Build receipt bytes from an order.
  Future<List<int>> buildReceipt({
    required Order order,
    double? tenderedAmount,
    double? changeAmount,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    // --- Header ---
    bytes += generator.text(
      storeName,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.emptyLines(1);

    // --- Order Info ---
    bytes += generator.row([
      PosColumn(text: 'Order:', width: 4),
      PosColumn(
        text: order.orderNumber,
        width: 8,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.text(
      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    // --- Items ---
    for (final item in order.items) {
      bytes += generator.row([
        PosColumn(text: item.menuItem.name, width: 7),
        PosColumn(
          text: '${item.quantity}x',
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: _formatCurrency(item.unitPrice * item.quantity),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      if (item.notes?.isNotEmpty ?? false) {
        bytes += generator.text(
          '  Note: ${item.notes}',
          styles: const PosStyles(fontType: PosFontType.fontB),
        );
      }
    }

    bytes += generator.hr();

    // --- Summary ---
    bytes += generator.row([
      PosColumn(text: 'Total:', width: 8, styles: const PosStyles(bold: true)),
      PosColumn(
        text: _formatCurrency(order.totalAmount),
        width: 4,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    // --- Payment ---
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      'Payment: ${order.paymentMethod.name.toUpperCase()}',
    );

    // Cash change info
    if (tenderedAmount != null && changeAmount != null) {
      bytes += generator.row([
        PosColumn(text: 'Tendered:', width: 8),
        PosColumn(
          text: _formatCurrency(tenderedAmount),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Change:', width: 8),
        PosColumn(
          text: _formatCurrency(changeAmount),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    // --- Footer ---
    bytes += generator.emptyLines(2);
    bytes += generator.text(
      'Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)}B';
  }
}
