import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/pos_theme.dart';
import '../../../core/database/app_database.dart';
import '../../floor_plan/providers/floor_plan_provider.dart';
import '../../floor_plan/widgets/floor_plan_canvas.dart';
import '../../shell/pos_shell.dart';
import '../providers/order_context_provider.dart';

/// Source selection screen shown before the speed register.
/// User picks dine-in (then table), takeaway, or delivery.
class OrderSetupScreen extends ConsumerWidget {
  const OrderSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: PosTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New Order',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: PosTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select order type to get started',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: PosTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                // Three source buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SourceCard(
                      icon: Icons.restaurant,
                      label: 'Dine-in',
                      sublabel: 'Select a table',
                      color: PosTheme.primaryBlue,
                      onTap: () => _showTablePicker(context, ref),
                    ),
                    const SizedBox(width: 24),
                    _SourceCard(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Takeaway',
                      sublabel: 'Counter pickup',
                      color: PosTheme.accentAmber,
                      onTap: () => _selectTakeaway(context, ref),
                    ),
                    const SizedBox(width: 24),
                    _SourceCard(
                      icon: Icons.delivery_dining,
                      label: 'Delivery',
                      sublabel: 'Platform order',
                      color: PosTheme.successGreen,
                      onTap: () => _showDeliveryPicker(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: PosTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTablePicker(BuildContext context, WidgetRef ref) {
    // Trigger floor plan sync
    ref.read(floorPlanProvider);

    showDialog(
      context: context,
      builder: (ctx) => _TablePickerDialog(
        onTableSelected: (table) {
          Navigator.of(ctx).pop();
          ref.read(orderContextProvider.notifier).state = OrderContext(
            orderType: OrderType.dineIn,
            tableId: table.id,
            tableNumber: table.number,
          );
          _navigateToRegister(context, ref);
        },
      ),
    );
  }

  Future<void> _selectTakeaway(BuildContext context, WidgetRef ref) async {
    final ticketNumber = await _generateTakeawayNumber();
    ref.read(orderContextProvider.notifier).state = OrderContext(
      orderType: OrderType.takeaway,
      ticketNumber: ticketNumber,
    );
    if (context.mounted) _navigateToRegister(context, ref);
  }

  void _showDeliveryPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _DeliveryPlatformDialog(
        onSelected: (platform) {
          Navigator.of(ctx).pop();
          ref.read(orderContextProvider.notifier).state = OrderContext(
            orderType: OrderType.delivery,
            deliveryPlatform: platform,
          );
          _navigateToRegister(context, ref);
        },
      ),
    );
  }

  void _navigateToRegister(BuildContext context, WidgetRef ref) {
    // Navigate to speed register (index 2 in shell)
    ref.read(shellNavigationProvider.notifier).state = 2;
    Navigator.of(context).pop();
  }

  Future<String> _generateTakeawayNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastDate = prefs.getString('takeaway_date') ?? '';

    int counter;
    if (lastDate != today) {
      counter = 1;
      await prefs.setString('takeaway_date', today);
    } else {
      counter = (prefs.getInt('takeaway_counter') ?? 0) + 1;
    }

    await prefs.setInt('takeaway_counter', counter);
    return 'T-${counter.toString().padLeft(3, '0')}';
  }
}

// ─── Source Card ───────────────────────────────────────────────

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _SourceCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 180,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PosTheme.borderLight, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: PosTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sublabel,
                style: GoogleFonts.openSans(
                  fontSize: 13,
                  color: PosTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Table Picker Dialog ──────────────────────────────────────

class _TablePickerDialog extends ConsumerWidget {
  final void Function(LocalTable table) onTableSelected;

  const _TablePickerDialog({required this.onTableSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(floorPlanStreamProvider);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 720,
        height: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Select Table',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PosTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap an available table to start the order',
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: PosTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tablesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Could not load tables: $e'),
                ),
                data: (tables) {
                  if (tables.isEmpty) {
                    return Center(
                      child: Text(
                        'No tables configured for this branch',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: PosTheme.textSecondary,
                        ),
                      ),
                    );
                  }
                  return FittedBox(
                    fit: BoxFit.contain,
                    child: FloorPlanCanvas(
                      tables: tables,
                      onTableTap: (table) {
                        if (table.status == 'available') {
                          onTableSelected(table);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Delivery Platform Dialog ─────────────────────────────────

class _DeliveryPlatformDialog extends StatelessWidget {
  final void Function(String platform) onSelected;

  const _DeliveryPlatformDialog({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Platform',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: PosTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _PlatformTile(
              label: 'Grab',
              color: PosTheme.successGreen,
              onTap: () => onSelected('grab'),
            ),
            const SizedBox(height: 8),
            _PlatformTile(
              label: 'LINE MAN',
              color: PosTheme.successGreen,
              onTap: () => onSelected('lineman'),
            ),
            const SizedBox(height: 8),
            _PlatformTile(
              label: 'Wongnai',
              color: PosTheme.secondaryBlue,
              onTap: () => onSelected('wongnai'),
            ),
            const SizedBox(height: 8),
            _PlatformTile(
              label: 'Other',
              color: PosTheme.textSecondary,
              onTap: () => onSelected('other'),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PlatformTile({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PosTheme.borderLight),
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
              Text(
                label,
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: PosTheme.textPrimary,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: PosTheme.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
