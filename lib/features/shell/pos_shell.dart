import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pos_theme.dart';
import '../../shared/widgets/connection_heartbeat.dart';
import '../auth/providers/auth_provider.dart';
import '../menu/widgets/menu_screen.dart';
import '../dashboard/widgets/bridge_dashboard_screen.dart';
import '../register/widgets/speed_register_screen.dart';
import '../orders/widgets/order_history_screen.dart';
import '../orders/widgets/order_setup_screen.dart';
import '../orders/providers/order_context_provider.dart';
import '../orders/services/sync_service.dart';
import '../orders/services/order_polling_service.dart';
import '../printer/providers/printer_provider.dart';
import '../printer/widgets/printer_settings_screen.dart';
import '../floor_plan/floor_plan_screen.dart';
import '../../core/providers/current_branch_provider.dart';
import '../../core/providers/database_provider.dart';

// Shell Navigation State
final shellNavigationProvider = StateProvider<int>((ref) => 0);

class PosShell extends ConsumerWidget {
  const PosShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final selectedIndex = ref.watch(shellNavigationProvider);
    // Initialize the sync service so it starts listening for connectivity
    // and processes any pending queue items when the shell mounts.
    ref.watch(syncServiceProvider);
    // Initialize order polling so orders from other devices appear automatically.
    ref.watch(orderPollingServiceProvider);

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            extended: MediaQuery.of(context).size.width >= 1024,
            leading: _buildLeadingSection(context, authState),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  child: _buildTrailingSection(context, ref),
                ),
              ),
            ),
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                // Show order setup screen before speed register
                final orderCtx = ref.read(orderContextProvider);
                if (orderCtx == null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OrderSetupScreen(),
                    ),
                  );
                  return;
                }
              }
              ref.read(shellNavigationProvider.notifier).state = index;
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Bridge'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.table_restaurant_outlined),
                selectedIcon: Icon(Icons.table_restaurant),
                label: Text('Tables'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Orders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: Text('Menu'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: Text('History'),
              ),
            ],
          ),

          // Vertical Divider
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: PosTheme.borderLight,
          ),

          // Main Content Area
          Expanded(
            child: _buildScreen(selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingSection(BuildContext context, AuthState authState) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // User Profile Avatar
        authState.whenOrNull(
              authenticated: (user) => _buildUserAvatar(context, user),
            ) ??
            CircleAvatar(
              radius: 24,
              backgroundColor: PosTheme.borderLight,
              child: const Icon(
                Icons.person,
                color: PosTheme.textSecondary,
              ),
            ),

        const SizedBox(height: 16),

        // User Info (when extended)
        if (MediaQuery.of(context).size.width >= 1024)
          authState.whenOrNull(
            authenticated: (user) => Column(
              children: [
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (user.role != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: PosTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.role!.name.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: PosTheme.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
              ],
            ),
          ) ??
              const SizedBox.shrink(),

        const SizedBox(height: 16),

        // Connection Status
        const ConnectionHeartbeat(
          status: ConnectionStatus.online,
        ),

        // Branch Name Badge
        const SizedBox(height: 8),
        _BranchBadge(),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildUserAvatar(BuildContext context, user) {
    final initials = _getInitials(user.email);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            PosTheme.primaryBlue,
            PosTheme.secondaryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: PosTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }

  String _getInitials(String email) {
    final parts = email.split('@')[0].split('.');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return email.substring(0, 2).toUpperCase();
  }

  Widget _buildTrailingSection(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        const SizedBox(height: 4),

        // Printer Status
        _PrinterIndicator(),

        const SizedBox(height: 4),

        // Settings Button (opens Printer Settings)
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PrinterSettingsScreen(),
              ),
            );
          },
          tooltip: 'Printer Settings',
        ),

        const SizedBox(height: 4),

        // Switch Branch Button
        IconButton(
          icon: const Icon(Icons.swap_horiz_rounded),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Switch Branch?'),
                content: const Text(
                  'Cart and floor plan data will reload for the new branch.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Switch'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              // Clear floor plan cache
              try {
                final db = ref.read(appDatabaseProvider);
                await db.floorPlanDao.deleteAll();
              } catch (e) {
                debugPrint('⚠️ Failed to clear floor plan cache: $e');
              }

              await ref.read(authProvider.notifier).switchBranch();
            }
          },
          tooltip: 'Switch Branch',
        ),

        const SizedBox(height: 4),

        // Logout Button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await ref.read(authProvider.notifier).logout();
          },
          tooltip: 'Logout',
          color: PosTheme.dangerRed,
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const BridgeDashboardScreen();
      case 1:
        return const FloorPlanScreen();
      case 2:
        return const SpeedRegisterScreen();
      case 3:
        return const MenuScreen(); // Existing menu screen
      case 4:
        return const OrderHistoryScreen();
      default:
        return const BridgeDashboardScreen();
    }
  }

}

class _BranchBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchName = ref.watch(currentBranchNameProvider);

    return branchName.when(
      data: (name) {
        if (name == null) return const SizedBox.shrink();
        final display = name.length > 12 ? '${name.substring(0, 12)}...' : name;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: PosTheme.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.store_rounded,
                size: 12,
                color: PosTheme.primaryBlue,
              ),
              const SizedBox(width: 4),
              Text(
                display,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: PosTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Small printer connection indicator for the navigation rail.
class _PrinterIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerState = ref.watch(printerProvider);

    return Tooltip(
      message: printerState.isConnected
          ? 'Printer: ${printerState.deviceName}'
          : 'Printer disconnected',
      child: Icon(
        printerState.isConnected ? Icons.print : Icons.print_disabled,
        size: 20,
        color: printerState.isConnected
            ? PosTheme.successGreen
            : PosTheme.textSecondary.withValues(alpha: 0.4),
      ),
    );
  }
}
