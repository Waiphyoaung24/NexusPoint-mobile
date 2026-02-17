import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import '../../../core/models/order.dart';

/// Builds ESC/POS byte data for kitchen tickets.
/// Kitchen tickets use larger fonts and a different layout than receipts.
class KitchenTicketBuilder {
  final PaperSize paperSize;

  KitchenTicketBuilder({this.paperSize = PaperSize.mm80});

  /// Build kitchen ticket bytes from an order.
  Future<List<int>> buildTicket({required Order order}) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    // --- Kitchen Header ---
    bytes += generator.text(
      'KITCHEN ORDER',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.emptyLines(1);

    // --- Source Badge ---
    final sourceBadge = _getSourceBadge(order);
    bytes += generator.text(
      sourceBadge,
      styles: const PosStyles(align: PosAlign.center, reverse: true),
    );
    bytes += generator.emptyLines(1);

    // --- Order Info ---
    bytes += generator.text('Order: ${order.orderNumber}');
    bytes += generator.text(DateFormat('HH:mm').format(order.createdAt));
    bytes += generator.hr(ch: '=');

    // --- Items (larger font for kitchen) ---
    for (final item in order.items) {
      bytes += generator.text(
        '${item.quantity}x ${item.menuItem.name}',
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size2,
        ),
      );

      if (item.notes?.isNotEmpty ?? false) {
        bytes += generator.text(
          '>>> ${item.notes} <<<',
          styles: const PosStyles(bold: true, reverse: true),
        );
      }

      bytes += generator.emptyLines(1);
    }

    bytes += generator.hr(ch: '=');
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  /// Get the source badge text based on order source.
  String _getSourceBadge(Order order) {
    switch (order.source) {
      case OrderSource.grab:
        return '[GRAB DELIVERY]';
      case OrderSource.wongnai:
        return '[LINE MAN]';
      case OrderSource.dinein:
        if (order.tableNumber != null) {
          return '[TABLE ${order.tableNumber}]';
        }
        return '[DINE-IN]';
    }
  }
}
