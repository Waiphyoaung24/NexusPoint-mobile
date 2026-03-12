import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/pos_theme.dart';
import 'providers/floor_plan_provider.dart';
import 'widgets/floor_plan_canvas.dart';
import 'widgets/table_action_sheet.dart';

class FloorPlanScreen extends ConsumerStatefulWidget {
  const FloorPlanScreen({super.key});

  @override
  ConsumerState<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends ConsumerState<FloorPlanScreen> {
  @override
  void initState() {
    super.initState();
    // Start polling when screen opens
    ref.read(floorPlanPollingProvider);
  }

  void _onTableTap(LocalTable table) {
    ref.read(selectedTableIdProvider.notifier).state = table.id;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TableActionSheet(table: table),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Trigger initial API sync — writes tables into Drift so the stream emits
    ref.watch(floorPlanProvider);
    final tablesAsync = ref.watch(floorPlanStreamProvider);
    final isOnline = ref.watch(floorPlanOnlineProvider);

    return Scaffold(
      backgroundColor: PosTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Floor Plan'),
        actions: [
          // Online/offline badge
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline
                        ? PosTheme.successGreen
                        : PosTheme.statusOffline,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 13,
                    color: isOnline
                        ? PosTheme.successGreen
                        : PosTheme.statusOffline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline warning banner
          if (!isOnline)
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF3CD),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Color(0xFF856404)),
                  SizedBox(width: 8),
                  Text(
                    'Offline mode — showing last known state',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF856404),
                    ),
                  ),
                ],
              ),
            ),
          // Legend
          _buildLegend(),
          // Canvas
          Expanded(
            child: tablesAsync.when(
              data: (tables) => tables.isEmpty
                  ? const Center(
                      child: Text(
                        'No tables configured.\nAsk your manager to set up the floor plan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: PosTheme.textSecondary),
                      ),
                    )
                  : FloorPlanCanvas(
                      tables: tables,
                      onTableTap: _onTableTap,
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error loading floor plan: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      height: 44,
      color: PosTheme.surfaceWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _legendItem(const Color(0xFF22C55E), 'Available'),
          const SizedBox(width: 16),
          _legendItem(const Color(0xFF1E40AF), 'Occupied'),
          const SizedBox(width: 16),
          _legendItem(const Color(0xFFF59E0B), 'Reserved'),
          const SizedBox(width: 16),
          _legendItem(const Color(0xFFCBD5E1), 'Cleaning'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12, color: PosTheme.textSecondary)),
    ],
  );
}
