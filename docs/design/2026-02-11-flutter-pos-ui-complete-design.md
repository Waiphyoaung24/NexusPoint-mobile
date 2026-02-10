# Flutter POS - Complete UI/UX Design Specification

**Project:** NexusPoint Bridge-Centric POS
**Design Date:** February 11, 2026
**Target:** Android/iOS Tablets (10-12" Landscape)
**Theme:** Industrial Command Center (Dark OLED)

---

## Design Philosophy

### Aesthetic Direction: Industrial Command Center

**Inspiration:** NASA mission control meets high-end restaurant operations center.

**Core Principles:**
1. **Tactical Clarity**: Information hierarchy optimized for quick decision-making
2. **Ambient Awareness**: Status indicators pulse and glow to communicate health
3. **Touch-First**: Every interaction designed for fingers, not mice
4. **Flow Visualization**: Orders move through the system with Hero animations

**Visual Language:**
- **Colors**: Deep OLED black (#020617) with tactical green (#22C55E) and amber (#F59E0B)
- **Typography**: Cinzel (authority) + Josefin Sans (clarity)
- **Spacing**: Generous 16px base unit, 24px for breathing room
- **Elevation**: Subtle (2-4dp) with colored glows, not harsh shadows
- **Motion**: 200-300ms curves, Hero transitions for order flow

---

## Theme Configuration

### Material 3 Dark Theme

```dart
class PosTheme {
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF22C55E),        // Tactical green
        secondary: Color(0xFFF59E0B),      // Amber warning
        tertiary: Color(0xFF3B82F6),       // Info blue
        error: Color(0xFFEF4444),          // Urgent red
        background: Color(0xFF020617),     // Deep OLED black
        surface: Color(0xFF0F172A),        // Elevated surface
        surfaceVariant: Color(0xFF1E293B), // Cards
        onPrimary: Color(0xFF000000),
        onSecondary: Color(0xFF000000),
        onSurface: Color(0xFFF8FAFC),      // Primary text
        onSurfaceVariant: Color(0xFF94A3B8), // Secondary text
        outline: Color(0xFF334155),        // Borders
      ),

      // Typography
      textTheme: TextTheme(
        // Headers - Cinzel (Authority)
        displayLarge: GoogleFonts.cinzel(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF8FAFC),
        ),
        displayMedium: GoogleFonts.cinzel(
          fontSize: 45,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        headlineLarge: GoogleFonts.cinzel(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        headlineMedium: GoogleFonts.cinzel(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),

        // Body - Josefin Sans (Clarity)
        titleLarge: GoogleFonts.josefinSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        titleMedium: GoogleFonts.josefinSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        bodyLarge: GoogleFonts.josefinSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFF8FAFC),
        ),
        bodyMedium: GoogleFonts.josefinSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFCBD5E1),
        ),
        labelLarge: GoogleFonts.josefinSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Color(0xFFF8FAFC),
        ),
      ),

      // Components
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: Color(0xFF1E293B),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Color(0xFF334155),
            width: 1,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFF1E293B),
        labelStyle: GoogleFonts.josefinSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
```

---

## 1. Navigation Shell Architecture

### Layout: Permanent NavigationRail (Left Sidebar)

```
┌──────────────────────────────────────────┐
│ Nav │        Main Content Area           │
│ Rail│                                     │
│     │                                     │
│  👤 │                                     │
│ 🟢🟢│                                     │
│     │                                     │
│  🏠 │         <Dynamic Screen>            │
│  🍽️ │                                     │
│  📋 │                                     │
│  🏪 │                                     │
│  📊 │                                     │
│     │                                     │
│  ⚙️ │                                     │
└──────────────────────────────────────────┘
```

### Component Structure

```dart
class PosShell extends ConsumerWidget {
  const PosShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            extended: true,
            backgroundColor: Color(0xFF0F172A),
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(navigationProvider.notifier).state = index;
            },

            // Top: User Profile + Connection Status
            leading: Column(
              children: [
                SizedBox(height: 16),
                // User Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF1E293B),
                  child: Icon(Icons.person, color: Color(0xFF22C55E)),
                ),
                SizedBox(height: 8),
                // Connection Status Indicators
                ConnectionHeartbeat(),
                SizedBox(height: 24),
              ],
            ),

            // Middle: Navigation Items
            destinations: [
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

            // Bottom: Settings
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: Icon(Icons.settings_outlined),
                    onPressed: () {
                      // Navigate to settings
                    },
                  ),
                ),
              ),
            ),
          ),

          // Vertical Divider
          VerticalDivider(thickness: 1, width: 1, color: Color(0xFF334155)),

          // Main Content
          Expanded(
            child: _buildScreen(currentIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0: return BridgeDashboardScreen();
      case 1: return FloorPlanScreen();
      case 2: return OrdersScreen();
      case 3: return SpeedRegisterScreen();
      case 4: return HistoryScreen();
      default: return BridgeDashboardScreen();
    }
  }
}
```

### Connection Heartbeat Widget

**Purpose**: Real-time visual indicator of external platform connections.

```dart
class ConnectionHeartbeat extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grab = ref.watch(grabConnectionProvider);
    final lineman = ref.watch(linemanConnectionProvider);
    final internet = ref.watch(internetProvider);

    return Column(
      children: [
        _buildStatusDot('Grab', grab, Colors.green),
        SizedBox(height: 4),
        _buildStatusDot('Lineman', lineman, Colors.orange),
        SizedBox(height: 4),
        _buildStatusDot('Internet', internet, Colors.blue),
      ],
    );
  }

  Widget _buildStatusDot(String label, bool isConnected, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? color : Colors.grey,
            boxShadow: isConnected ? [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ] : [],
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isConnected ? color : Colors.grey,
          ),
        ),
      ],
    );
  }
}
```

---

## 2. Bridge Dashboard Screen (3-Column Kanban)

### Layout: Kanban Board with Live Updates

```
┌─────────────────────────────────────────────────────────────┐
│  🌉 Bridge Dashboard          🟢 Auto-Accept: ON    🔄 Sync │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│ │  Incoming    │  │  Cooking     │  │  Ready       │       │
│ │  (External)  │  │  (Kitchen)   │  │  (Pickup)    │       │
│ ├──────────────┤  ├──────────────┤  ├──────────────┤       │
│ │              │  │              │  │              │       │
│ │ [Order Card] │  │ [Order Card] │  │ [Order Card] │       │
│ │              │  │              │  │              │       │
│ │ [Order Card] │  │ [Order Card] │  │ [Order Card] │       │
│ │              │  │              │  │              │       │
│ │              │  │              │  │              │       │
│ └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Component Structure

```dart
class BridgeDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingOrders = ref.watch(incomingOrdersProvider);
    final cookingOrders = ref.watch(cookingOrdersProvider);
    final readyOrders = ref.watch(readyOrdersProvider);
    final autoAccept = ref.watch(autoAcceptProvider);

    return Scaffold(
      backgroundColor: Color(0xFF020617),
      body: Column(
        children: [
          // Header Bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(
                bottom: BorderSide(color: Color(0xFF334155)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bridge, color: Color(0xFF22C55E), size: 28),
                SizedBox(width: 12),
                Text(
                  'Bridge Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Spacer(),

                // Auto-Accept Toggle
                Row(
                  children: [
                    Text('Auto-Accept:', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 8),
                    Switch(
                      value: autoAccept,
                      onChanged: (value) {
                        ref.read(autoAcceptProvider.notifier).state = value;
                      },
                      activeColor: Color(0xFF22C55E),
                    ),
                  ],
                ),

                SizedBox(width: 24),

                // Sync Status
                SyncStatusIndicator(),
              ],
            ),
          ),

          // 3-Column Kanban
          Expanded(
            child: Row(
              children: [
                // Column 1: Incoming (External Orders)
                Expanded(
                  child: KanbanColumn(
                    title: 'Incoming Orders',
                    subtitle: '${incomingOrders.length} pending',
                    color: Color(0xFF3B82F6), // Blue
                    orders: incomingOrders,
                    onAccept: (order) => _acceptOrder(ref, order),
                    onReject: (order) => _rejectOrder(ref, order),
                  ),
                ),

                VerticalDivider(width: 1, color: Color(0xFF334155)),

                // Column 2: Cooking (Kitchen)
                Expanded(
                  child: KanbanColumn(
                    title: 'Cooking Now',
                    subtitle: '${cookingOrders.length} active',
                    color: Color(0xFFF59E0B), // Amber
                    orders: cookingOrders,
                    showTimer: true,
                  ),
                ),

                VerticalDivider(width: 1, color: Color(0xFF334155)),

                // Column 3: Ready (Waiting Pickup)
                Expanded(
                  child: KanbanColumn(
                    title: 'Ready for Pickup',
                    subtitle: '${readyOrders.length} waiting',
                    color: Color(0xFF22C55E), // Green
                    orders: readyOrders,
                    showRider: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _acceptOrder(WidgetRef ref, Order order) {
    ref.read(orderActionProvider.notifier).acceptOrder(order);
    HapticFeedback.mediumImpact();
  }

  void _rejectOrder(WidgetRef ref, Order order) {
    // Show rejection dialog
  }
}
```

### Kanban Order Card

```dart
class KanbanOrderCard extends StatelessWidget {
  final Order order;
  final Color platformColor;
  final bool showActions;
  final bool showTimer;
  final bool showRider;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'order-${order.id}',
      child: Card(
        margin: EdgeInsets.all(8),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: platformColor,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      // Platform Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: platformColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.source.toUpperCase(),
                          style: TextStyle(
                            color: platformColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),

                      // Timer or Stock Warning
                      if (showTimer)
                        TimerBadge(startTime: order.createdAt)
                      else if (order.hasLowStock)
                        Icon(
                          Icons.warning_amber,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Order ID (Large)
                  Text(
                    order.orderNumber,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Items Summary
                  Text(
                    order.itemsSummary, // "2x Pad Thai, 1x Tom Yum"
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 12),

                  // Total
                  Text(
                    '฿${order.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Color(0xFF22C55E),
                    ),
                  ),

                  // Rider Info (for Ready column)
                  if (showRider && order.riderName != null) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.delivery_dining,
                            size: 16, color: Color(0xFF94A3B8)),
                        SizedBox(width: 4),
                        Text(
                          order.riderName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Action Buttons (for Incoming column)
                  if (showActions) ...[
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onAccept,
                            icon: Icon(Icons.check, size: 18),
                            label: Text('Accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF22C55E),
                              foregroundColor: Colors.black,
                              minimumSize: Size(0, 44),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onReject,
                            icon: Icon(Icons.close, size: 18),
                            label: Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFFEF4444),
                              side: BorderSide(color: Color(0xFFEF4444)),
                              minimumSize: Size(0, 44),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 3. Interactive Floor Plan Screen

### Layout: Pan/Zoom Table Management

```
┌─────────────────────────────────────────────────────────────┐
│  🍽️ Floor Plan                           🔍 Zoom: 100%      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│              [Interactive Viewer Area]                        │
│                                                               │
│   ┌─────┐     ┌─────┐                     ┌──────┐         │
│   │  1  │     │  2  │    ┌─────┐         │  VIP │         │
│   │ 45m │     │EMPTY│    │  3  │         │  5   │         │
│   └─────┘     └─────┘    │ 12m │         │ 30m  │         │
│                           └─────┘         └──────┘         │
│                                                               │
│   ┌─────┐                                                    │
│   │  4  │         ┌──────────┐                              │
│   │ 🧾  │         │  Bar (6) │                              │
│   └─────┘         └──────────┘                              │
│                                                               │
└─────────────────────────────────────────────────────────────┘
│ [+] Add Table    [⚙] Layout Mode                             │
└─────────────────────────────────────────────────────────────┘
```

### Component Structure

```dart
class FloorPlanScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends ConsumerState<FloorPlanScreen> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    final tables = ref.watch(tablesProvider);
    final isEditMode = ref.watch(floorPlanEditModeProvider);

    return Scaffold(
      backgroundColor: Color(0xFF020617),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(
                bottom: BorderSide(color: Color(0xFF334155)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.table_restaurant,
                    color: Color(0xFF22C55E), size: 28),
                SizedBox(width: 12),
                Text(
                  'Floor Plan',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Spacer(),

                // Zoom Indicator
                Text(
                  'Zoom: ${(_transformationController.value.getMaxScaleOnAxis() * 100).toInt()}%',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // Interactive Floor Plan
          Expanded(
            child: Stack(
              children: [
                // Grid Background
                CustomPaint(
                  size: Size.infinite,
                  painter: GridPainter(color: Color(0xFF1E293B)),
                ),

                // Tables (Pan & Zoom)
                InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: EdgeInsets.all(double.infinity),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Container(
                    width: 2000,
                    height: 2000,
                    child: Stack(
                      children: tables.map((table) {
                        return Positioned(
                          left: table.x,
                          top: table.y,
                          child: TableWidget(
                            table: table,
                            isEditMode: isEditMode,
                            onTap: () => _handleTableTap(table),
                            onLongPress: isEditMode
                                ? () => _startDragging(table)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(
                top: BorderSide(color: Color(0xFF334155)),
              ),
            ),
            child: Row(
              children: [
                if (isEditMode) ...[
                  ElevatedButton.icon(
                    onPressed: _addTable,
                    icon: Icon(Icons.add),
                    label: Text('Add Table'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF22C55E),
                      foregroundColor: Colors.black,
                      minimumSize: Size(0, 48),
                    ),
                  ),
                  SizedBox(width: 16),
                ],
                TextButton.icon(
                  onPressed: () {
                    ref.read(floorPlanEditModeProvider.notifier).state =
                        !isEditMode;
                  },
                  icon: Icon(isEditMode ? Icons.check : Icons.edit),
                  label: Text(isEditMode ? 'Done' : 'Layout Mode'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTableTap(Table table) {
    // Show Quick Actions Bottom Sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E293B),
      builder: (context) => TableQuickActionsSheet(table: table),
    );
  }
}
```

### Table Widget

```dart
class TableWidget extends StatelessWidget {
  final Table table;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: table.width,
        height: table.height,
        decoration: BoxDecoration(
          color: _getTableColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
            width: 2,
          ),
          boxShadow: table.status == TableStatus.seated ? [
            BoxShadow(
              color: Color(0xFF22C55E).withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ] : [],
        ),
        child: Stack(
          children: [
            // Table Number (Center)
            Center(
              child: Text(
                table.number.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(),
                ),
              ),
            ),

            // Timer Badge (Top Right)
            if (table.status == TableStatus.seated && table.seatedAt != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDuration(
                      DateTime.now().difference(table.seatedAt!),
                    ),
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),

            // Status Icon (Bottom Left)
            if (table.billPrinted)
              Positioned(
                bottom: 4,
                left: 4,
                child: Icon(
                  Icons.receipt,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTableColor() {
    switch (table.status) {
      case TableStatus.empty:
        return Color(0xFF1E293B).withOpacity(0.5);
      case TableStatus.seated:
        return Color(0xFF22C55E).withOpacity(0.2);
      case TableStatus.reserved:
        return Color(0xFF3B82F6).withOpacity(0.2);
    }
  }

  Color _getBorderColor() {
    switch (table.status) {
      case TableStatus.empty:
        return Color(0xFF334155);
      case TableStatus.seated:
        return Color(0xFF22C55E);
      case TableStatus.reserved:
        return Color(0xFF3B82F6);
    }
  }

  Color _getTextColor() {
    return table.status == TableStatus.empty
        ? Color(0xFF64748B)
        : Color(0xFFF8FAFC);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
}
```

---

## 4. Speed Register Screen (Order Taking)

### Layout: 2/3 Menu + 1/3 Cart Split

```
┌─────────────────────────────────────────────────────────────┐
│  🏪 Speed Register                           Table 5 🔒      │
├─────────────────────────────────────────────────────────────┤
│                         │                                     │
│  [Appetizers][Mains]   │  Cart (3 items)                    │
│  [Drinks][Desserts]     │  ─────────────────                 │
│                         │  2x Pad Thai      ฿240.00          │
│  ┌────┐ ┌────┐ ┌────┐ │  1x Tom Yum       ฿120.00          │
│  │Pad │ │Som │ │Tom │ │                                     │
│  │Thai│ │Tam │ │Yum │ │  [Edit] [Remove]                    │
│  │฿120│ │฿80 │ │฿120│ │                                     │
│  └────┘ └────┘ └────┘ │  ──────────────────────────         │
│  ┌────┐ ┌────┐ ┌────┐ │  Subtotal:        ฿360.00          │
│  │... │ │... │ │... │ │  Tax (7%):        ฿ 25.20          │
│  └────┘ └────┘ └────┘ │  ──────────────────────────         │
│                         │  Total:           ฿385.20          │
│                         │                                     │
│                         │  [SEND TO KITCHEN ──>]             │
└─────────────────────────┴─────────────────────────────────────┘
```

### Component Structure

```dart
class SpeedRegisterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = ref.watch(menuProvider);
    final cart = ref.watch(cartProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: Color(0xFF020617),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(
                bottom: BorderSide(color: Color(0xFF334155)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu,
                    color: Color(0xFF22C55E), size: 28),
                SizedBox(width: 12),
                Text(
                  'Speed Register',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Spacer(),

                // Current Table/Order Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      Text('Table 5', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.lock, size: 16, color: Color(0xFF22C55E)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Split View
          Expanded(
            child: Row(
              children: [
                // Left: Menu (2/3)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Category Tabs
                      CategoryTabBar(
                        selectedCategory: selectedCategory,
                        onCategorySelected: (category) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              category;
                        },
                      ),

                      // Menu Grid
                      Expanded(
                        child: menuItems.when(
                          data: (items) => MenuItemGrid(
                            items: items.where((item) =>
                                item.category == selectedCategory).toList(),
                            onItemTap: (item) {
                              ref.read(cartProvider.notifier).addItem(item);
                              HapticFeedback.lightImpact();
                            },
                          ),
                          loading: () => Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF22C55E),
                            ),
                          ),
                          error: (error, stack) => Center(
                            child: Text('Error loading menu'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                VerticalDivider(width: 1, color: Color(0xFF334155)),

                // Right: Cart (1/3)
                Expanded(
                  flex: 1,
                  child: CartPanel(cart: cart),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Menu Item Tile (with Stock Badge)

```dart
class MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLowStock = item.inventoryQty < 5;

    return Card(
      child: InkWell(
        onTap: item.isAvailable ? onTap : null,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.restaurant,
                            size: 48,
                            color: Color(0xFF334155),
                          ),
                  ),
                ),

                // Details
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '฿${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Stock Warning Badge
            if (isLowStock && item.isAvailable)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Qty: ${item.inventoryQty}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Out of Stock Overlay
            if (!item.isAvailable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'OUT OF STOCK',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Shared Components

### Sync Status Indicator

```dart
class SyncStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(syncStatus),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(syncStatus),
          SizedBox(width: 8),
          Text(
            _getStatusText(syncStatus),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getTextColor(syncStatus),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Color(0xFF22C55E).withOpacity(0.2);
      case SyncStatus.syncing:
        return Color(0xFFF59E0B).withOpacity(0.2);
      case SyncStatus.offline:
        return Color(0xFFEF4444).withOpacity(0.2);
    }
  }

  Color _getTextColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Color(0xFF22C55E);
      case SyncStatus.syncing:
        return Color(0xFFF59E0B);
      case SyncStatus.offline:
        return Color(0xFFEF4444);
    }
  }

  Widget _buildIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Icon(Icons.cloud_done, size: 16, color: Color(0xFF22C55E));
      case SyncStatus.syncing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Color(0xFFF59E0B)),
          ),
        );
      case SyncStatus.offline:
        return Icon(Icons.cloud_off, size: 16, color: Color(0xFFEF4444));
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.offline:
        return 'Offline Mode';
    }
  }
}
```

### Timer Badge (for Orders)

```dart
class TimerBadge extends StatefulWidget {
  final DateTime startTime;

  @override
  _TimerBadgeState createState() => _TimerBadgeState();
}

class _TimerBadgeState extends State<TimerBadge> {
  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.startTime);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _elapsed.inMinutes;
    final isUrgent = minutes > 15;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUrgent
            ? Color(0xFFEF4444).withOpacity(0.2)
            : Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? Color(0xFFEF4444) : Color(0xFF334155),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 14,
            color: isUrgent ? Color(0xFFEF4444) : Color(0xFFF59E0B),
          ),
          SizedBox(width: 4),
          Text(
            '${minutes}m',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUrgent ? Color(0xFFEF4444) : Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. Animation Guidelines

### Hero Transitions (Order Flow)

```dart
// When accepting an order in Bridge Dashboard
Hero(
  tag: 'order-${order.id}',
  child: KanbanOrderCard(order: order),
);

// The card animates from "Incoming" to "Cooking" column
```

### Staggered Reveals (List Items)

```dart
class StaggeredList extends StatelessWidget {
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: AlwaysStoppedAnimation(1.0),
                curve: Interval(
                  index * 0.05,
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: children[index],
          ),
        );
      },
    );
  }
}
```

### Haptic Feedback Guidelines

```dart
// Use for critical actions
HapticFeedback.mediumImpact(); // Accept/Reject orders
HapticFeedback.lightImpact();  // Add item to cart
HapticFeedback.heavyImpact();  // Error states
```

---

## 7. Accessibility Guidelines

### Touch Targets

- **Minimum:** 44x44px for all interactive elements
- **Preferred:** 56x64px for primary actions
- **Spacing:** 8px minimum between adjacent touch targets

### Color Contrast

- **Text on Background:** Minimum 7:1 (WCAG AAA for dark mode)
- **Interactive Elements:** Minimum 3:1
- **Status Indicators:** Use icons + color, never color alone

### Keyboard Navigation (for testing)

```dart
// Ensure logical tab order
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      FocusTraversalOrder(order: NumericFocusOrder(1.0), child: Widget1()),
      FocusTraversalOrder(order: NumericFocusOrder(2.0), child: Widget2()),
    ],
  ),
);
```

---

## 8. Responsive Breakpoints

### Landscape Tablet Optimizations

```dart
class ResponsiveLayout {
  static bool isSmallTablet(BuildContext context) {
    return MediaQuery.of(context).size.width < 900;
  }

  static bool isLargeTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  static double getKanbanColumnWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) return 280;
    if (width < 1200) return 320;
    return 380;
  }

  static int getMenuGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }
}
```

---

## Summary: Implementation Priority

### Phase 1: Core Shell (Week 1)
1. ✅ PosShell with NavigationRail
2. ✅ Connection Heartbeat indicator
3. ✅ Theme configuration
4. ✅ Sync Status indicator

### Phase 2: Bridge Dashboard (Week 1-2)
1. ✅ 3-column Kanban layout
2. ✅ Order cards with Hero animations
3. ✅ Accept/Reject actions
4. ✅ Timer badges

### Phase 3: Floor Plan & Register (Week 2)
1. ✅ Interactive floor plan with pan/zoom
2. ✅ Table widgets with status
3. ✅ Speed register split view
4. ✅ Cart panel

### Phase 4: Polish & Testing (Week 3)
1. ✅ Haptic feedback
2. ✅ Staggered animations
3. ✅ Accessibility audit
4. ✅ Performance optimization

---

**Design Status:** ✅ Ready for Implementation
**Next Step:** Begin with PosShell and NavigationRail, then build screens incrementally
