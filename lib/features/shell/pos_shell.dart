import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/pos_theme.dart';
import '../../shared/widgets/connection_heartbeat.dart';
import '../auth/providers/auth_provider.dart';
import '../menu/widgets/menu_screen.dart';
import '../dashboard/widgets/bridge_dashboard_screen.dart';
import '../register/widgets/speed_register_screen.dart';
import '../orders/widgets/order_history_screen.dart';

// Shell Navigation State
final shellNavigationProvider = StateProvider<int>((ref) => 0);

class PosShell extends ConsumerWidget {
  const PosShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final selectedIndex = ref.watch(shellNavigationProvider);

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            extended: MediaQuery.of(context).size.width >= 1024,
            leading: _buildLeadingSection(context, authState),
            trailing: _buildTrailingSection(context, ref),
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
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
              authenticated: (user, _) => _buildUserAvatar(context, user),
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
            authenticated: (user, _) => Column(
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
      children: [
        const Divider(),
        const SizedBox(height: 8),

        // Settings Button
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // TODO: Navigate to settings
          },
          tooltip: 'Settings',
        ),

        const SizedBox(height: 8),

        // Logout Button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await ref.read(authProvider.notifier).logout();
          },
          tooltip: 'Logout',
          color: PosTheme.dangerRed,
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const BridgeDashboardScreen();
      case 1:
        return _buildFloorPlanPlaceholder();
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

  // Placeholder screens - will be replaced with actual implementations
  Widget _buildBridgeDashboardPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard,
            size: 64,
            color: PosTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Bridge Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: PosTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kanban board coming soon',
            style: TextStyle(
              fontSize: 14,
              color: PosTheme.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorPlanPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant,
            size: 64,
            color: PosTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Interactive Floor Plan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: PosTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pan/zoom table layout coming soon',
            style: TextStyle(
              fontSize: 14,
              color: PosTheme.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedRegisterPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: PosTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Speed Register',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: PosTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Split view register coming soon',
            style: TextStyle(
              fontSize: 14,
              color: PosTheme.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: PosTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Order History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: PosTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaction history coming soon',
            style: TextStyle(
              fontSize: 14,
              color: PosTheme.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
