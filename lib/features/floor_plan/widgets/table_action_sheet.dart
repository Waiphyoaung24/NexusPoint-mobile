import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/pos_theme.dart';
import '../repositories/floor_plan_repository.dart';

class TableActionSheet extends ConsumerStatefulWidget {
  final LocalTable table;

  const TableActionSheet({super.key, required this.table});

  @override
  ConsumerState<TableActionSheet> createState() => _TableActionSheetState();
}

class _TableActionSheetState extends ConsumerState<TableActionSheet> {
  int _guestCount = 1;

  @override
  void initState() {
    super.initState();
    _guestCount = (widget.table.seats / 2).ceil().clamp(1, widget.table.seats);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: PosTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Table header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Table ${widget.table.number}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: PosTheme.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              _statusBadge(),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: PosTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${widget.table.seats} seats',
                style: const TextStyle(fontSize: 14, color: PosTheme.textSecondary),
              ),
            ],
          ),
          const Divider(height: 28),
          // Context-aware content
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.table.status) {
      case 'available':
        return _buildAvailableContent();
      case 'occupied':
        return _buildOccupiedContent();
      case 'reserved':
        return _buildReservedContent();
      case 'cleaning':
        return _buildCleaningContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAvailableContent() => Column(
    children: [
      const Align(
        alignment: Alignment.centerLeft,
        child: Text('Guests', style: TextStyle(fontSize: 14, color: PosTheme.textSecondary)),
      ),
      const SizedBox(height: 12),
      // Stepper
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepperButton(
            Icons.remove,
            _guestCount > 1 ? () => setState(() => _guestCount--) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '$_guestCount',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: PosTheme.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          _stepperButton(
            Icons.add,
            _guestCount < widget.table.seats
                ? () => setState(() => _guestCount++)
                : null,
          ),
        ],
      ),
      const SizedBox(height: 24),
      _primaryButton(
        label: 'New Dine-In Order',
        icon: Icons.arrow_forward_rounded,
        onPressed: _onNewOrder,
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    ],
  );

  Widget _buildOccupiedContent() => Column(
    children: [
      // Order summary placeholder — F-003 will provide real order data
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PosTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.receipt_long, color: PosTheme.textSecondary),
            SizedBox(width: 12),
            Text('Active order in progress',
                style: TextStyle(color: PosTheme.textSecondary)),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _primaryButton(
        label: 'Open Order',
        icon: Icons.arrow_forward_rounded,
        onPressed: _onOpenOrder,
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
        label: const Text('Transfer Table'),
      ),
    ],
  );

  Widget _buildReservedContent() => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          border: Border.all(color: const Color(0xFFF59E0B)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.event_available, color: Color(0xFFF59E0B)),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reservation',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                Text('Tap to seat guests',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E))),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _primaryButton(
        label: 'Seat Guests',
        icon: Icons.arrow_forward_rounded,
        color: PosTheme.successGreen,
        onPressed: () => Navigator.pop(context),
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(foregroundColor: PosTheme.dangerRed),
        child: const Text('No Show'),
      ),
    ],
  );

  Widget _buildCleaningContent() => Column(
    children: [
      const Text('This table is being cleaned.',
          style: TextStyle(color: PosTheme.textSecondary)),
      const SizedBox(height: 20),
      _primaryButton(
        label: 'Mark Available',
        icon: Icons.check_circle_outline_rounded,
        color: PosTheme.successGreen,
        onPressed: _onMarkAvailable,
      ),
    ],
  );

  void _onNewOrder() {
    // Update local status optimistically
    ref.read(floorPlanRepositoryProvider).updateStatusLocally(
      widget.table.id,
      'occupied',
    );
    Navigator.pop(context);
    // F-003 will handle routing to order creation with tableId + guestCount
  }

  void _onOpenOrder() {
    Navigator.pop(context);
    // F-003 will handle routing to existing order
  }

  void _onMarkAvailable() {
    ref.read(floorPlanRepositoryProvider).updateStatusLocally(
      widget.table.id,
      'available',
    );
    Navigator.pop(context);
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? color,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? PosTheme.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  Widget _stepperButton(IconData icon, VoidCallback? onPressed) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      border: Border.all(color: PosTheme.borderLight),
      borderRadius: BorderRadius.circular(10),
    ),
    child: IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      color: onPressed != null ? PosTheme.primaryBlue : PosTheme.borderLight,
    ),
  );

  Widget _statusBadge() {
    final colors = {
      'available': (bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534)),
      'occupied': (bg: const Color(0xFFDBEAFE), fg: PosTheme.primaryBlue),
      'reserved': (bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
      'cleaning': (bg: PosTheme.backgroundLight, fg: PosTheme.textSecondary),
    };
    final c = colors[widget.table.status] ??
        (bg: PosTheme.backgroundLight, fg: PosTheme.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.table.status[0].toUpperCase() + widget.table.status.substring(1),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: c.fg,
        ),
      ),
    );
  }
}
