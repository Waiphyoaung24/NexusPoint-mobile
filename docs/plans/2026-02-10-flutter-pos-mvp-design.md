# Flutter Tablet POS - MVP Design Document

**Project:** NexusPoint Unified POS & Delivery Bridge System
**Module:** Tablet POS (Flutter)
**Design Date:** February 10, 2026
**Timeline:** 2-3 weeks
**Status:** Ready for Implementation

## Executive Summary

This document defines the technical design for the Flutter tablet POS application, implementing the Core Transaction Flow from EPIC-001. The app provides cross-platform (Android/iOS) point-of-sale functionality with offline-first architecture, Bluetooth receipt printing, and secure manager authorization.

### Scope (MVP - Phase 1)

**In Scope:**
- US-001: Offline order creation with automatic sync
- US-002: Bluetooth thermal printer integration (receipts + kitchen tickets)
- US-005: Manager PIN verification for critical actions
- Core features: Menu display, cart management, checkout flow, order history

**Out of Scope (Future Phases):**
- US-003: Visual table management
- US-004: Quick item disable toggle
- US-006: Advanced order search/filtering
- Multi-tenant switching (single tenant for MVP)

### Success Criteria

- ✅ Process orders offline for 4+ hours without internet
- ✅ Print receipts within 3 seconds on both Android and iOS
- ✅ Sync orders to server within 60 seconds when connectivity restored
- ✅ Block unauthorized price changes with PIN verification
- ✅ Support Android 8+ and iOS 13+ tablets

---

## Architecture Overview

### Technology Stack Alignment

The architecture mirrors the existing React/Astro web dashboard (nexuslab.asia):

| Web Dashboard | Flutter POS | Rationale |
|---------------|-------------|-----------|
| Astro + React Islands | Riverpod Providers | Granular, reactive state |
| Component-level state | StateNotifier | Local, scoped state management |
| TypeScript | Dart + Code Generation | Strong typing, compile-time safety |
| Lightweight (no Redux) | Riverpod (no BLoC) | Minimal boilerplate |
| SSR + hydration | Offline-first + sync | Similar data-fetching patterns |

### Core Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.0        # State management
  riverpod_annotation: ^2.3.0     # Code generation for providers
  drift: ^2.14.0                  # Type-safe SQLite
  freezed_annotation: ^2.4.0      # Immutable models
  json_annotation: ^4.8.1         # JSON serialization
  dio: ^5.4.0                     # HTTP client
  retrofit: ^4.0.0                # Type-safe REST client
  flutter_blue_plus: ^1.30.0      # Bluetooth (cross-platform)
  esc_pos_utils: ^1.1.0           # ESC/POS printer commands
  connectivity_plus: ^5.0.0       # Network state detection
  shared_preferences: ^2.2.0      # Local key-value storage

dev_dependencies:
  build_runner: ^2.4.0            # Code generation
  riverpod_generator: ^2.3.0      # Riverpod codegen
  drift_dev: ^2.14.0              # Drift codegen
  freezed: ^2.4.0                 # Freezed codegen
  retrofit_generator: ^8.0.0      # Retrofit codegen
  mockito: ^5.4.0                 # Mocking for tests
```

---

## Project Structure (Feature-First)

```
lib/
├── main.dart                    # App entry point, ProviderScope setup
├── core/
│   ├── api/
│   │   ├── dio_client.dart      # Dio instance with JWT interceptor
│   │   ├── api_service.dart     # Retrofit API definitions
│   │   └── api_exception.dart   # Custom exception types
│   ├── database/
│   │   ├── app_database.dart    # Drift database definition
│   │   ├── daos/                # Data Access Objects
│   │   │   ├── order_dao.dart
│   │   │   ├── menu_dao.dart
│   │   │   └── sync_queue_dao.dart
│   │   └── tables/              # Drift table definitions
│   │       ├── orders.dart
│   │       ├── menu_items.dart
│   │       └── sync_queue.dart
│   ├── providers/
│   │   ├── auth_provider.dart   # Global auth state
│   │   ├── connectivity_provider.dart
│   │   └── sync_provider.dart   # Background sync orchestrator
│   └── models/
│       ├── order.dart           # Freezed domain models
│       ├── menu_item.dart
│       ├── cart_item.dart
│       └── api_models.dart      # Request/response DTOs
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_notifier.dart
│   │   └── widgets/
│   │       ├── login_screen.dart
│   │       └── pin_dialog.dart
│   ├── menu/
│   │   ├── providers/
│   │   │   └── menu_provider.dart
│   │   ├── repositories/
│   │   │   └── menu_repository.dart
│   │   └── widgets/
│   │       ├── menu_grid.dart
│   │       └── menu_item_card.dart
│   ├── cart/
│   │   ├── providers/
│   │   │   └── cart_provider.dart
│   │   └── widgets/
│   │       ├── cart_screen.dart
│   │       ├── cart_item_list.dart
│   │       └── checkout_button.dart
│   ├── orders/
│   │   ├── providers/
│   │   │   └── order_provider.dart
│   │   ├── repositories/
│   │   │   └── order_repository.dart
│   │   └── widgets/
│   │       ├── order_history_screen.dart
│   │       └── sync_status_indicator.dart
│   └── printer/
│       ├── services/
│       │   └── printer_service.dart
│       ├── providers/
│       │   └── printer_provider.dart
│       └── widgets/
│           ├── printer_settings_screen.dart
│           └── printer_scanner.dart
└── shared/
    └── widgets/
        ├── error_banner.dart
        └── loading_overlay.dart
```

---

## Data Layer Design

### 1. Local Database Schema (Drift)

#### Orders Table
```dart
@DataClassName('LocalOrder')
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text().nullable()();        // UUID from server
  TextColumn get orderNumber => text()();               // ORD-20260210-001
  TextColumn get source => textWithLength(min: 1, max: 20)
    .withDefault(const Constant('dinein'))();           // dinein, grab, wongnai
  TextColumn get status => textWithLength(min: 1, max: 20)(); // pending, confirmed, completed
  RealColumn get totalAmount => real()();
  TextColumn get paymentMethod => text()();             // cash, promptpay, card
  TextColumn get itemsJson => text()();                 // JSON array of order items
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
```

#### Menu Items Table (Cache)
```dart
@DataClassName('LocalMenuItem')
class MenuItems extends Table {
  TextColumn get id => text()();                        // UUID from server
  TextColumn get tenantId => text()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get category => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  IntColumn get inventoryQty => integer().withDefault(const Constant(0))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### Sync Queue Table
```dart
@DataClassName('SyncQueueItem')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();                // order, menu_item, etc.
  IntColumn get entityId => integer()();                // FK to local entity
  TextColumn get action => text()();                    // create, update, delete
  TextColumn get payloadJson => text()();               // Serialized request
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
}
```

### 2. Offline-First Strategy

#### Dual-Write Pattern (Repository Layer)

```dart
class OrderRepository {
  final PosApiService _api;
  final OrderDao _localDb;
  final SyncQueueDao _syncQueue;
  final ConnectivityProvider _connectivity;

  Future<Order> createOrder(OrderRequest request) async {
    // PHASE 1: Local write (always succeeds)
    final localOrder = await _localDb.insertOrder(
      orderNumber: _generateOrderNumber(),
      source: request.source,
      totalAmount: request.totalAmount,
      paymentMethod: request.paymentMethod,
      itemsJson: jsonEncode(request.items),
      isSynced: false,
    );

    // PHASE 2: Attempt server sync (if online)
    if (_connectivity.isOnline) {
      try {
        final serverResponse = await _api.createOrder(request);

        // Update local record with server ID
        await _localDb.updateOrder(
          localOrder.id,
          orderId: serverResponse.orderId,
          syncedAt: DateTime.now(),
          isSynced: true,
        );

        return Order.fromServer(serverResponse);
      } catch (e) {
        // Queue for background sync
        await _syncQueue.enqueue(
          entityType: 'order',
          entityId: localOrder.id,
          action: 'create',
          payloadJson: jsonEncode(request.toJson()),
          priority: 1,
        );

        // Return local order (user doesn't see failure)
        return Order.fromLocal(localOrder);
      }
    } else {
      // Offline: queue immediately
      await _syncQueue.enqueue(
        entityType: 'order',
        entityId: localOrder.id,
        action: 'create',
        payloadJson: jsonEncode(request.toJson()),
        priority: 1,
      );

      return Order.fromLocal(localOrder);
    }
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final sequence = _localDb.getTodayOrderCount() + 1;
    return 'ORD-$dateStr-${sequence.toString().padLeft(3, '0')}';
  }
}
```

#### Background Sync Service

```dart
@riverpod
class SyncService extends _$SyncService {
  Timer? _syncTimer;

  @override
  SyncStatus build() {
    _startPeriodicSync();
    return SyncStatus.idle();
  }

  void _startPeriodicSync() {
    // Sync every 30 seconds when online
    _syncTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (ref.read(connectivityProvider).isOnline) {
        processSyncQueue();
      }
    });
  }

  Future<void> processSyncQueue() async {
    state = SyncStatus.syncing();

    final queue = await ref.read(syncQueueDaoProvider).getPendingItems();
    int successCount = 0;
    int failureCount = 0;

    for (final item in queue) {
      try {
        await _syncItem(item);
        await ref.read(syncQueueDaoProvider).markCompleted(item.id);
        successCount++;
      } catch (e) {
        // Exponential backoff
        final newRetryCount = item.retryCount + 1;
        if (newRetryCount < 5) {
          await ref.read(syncQueueDaoProvider).incrementRetry(item.id);
          failureCount++;
        } else {
          // Move to dead letter queue after 5 attempts
          await ref.read(syncQueueDaoProvider).markFailed(item.id);
        }
      }
    }

    state = SyncStatus.completed(
      synced: successCount,
      failed: failureCount,
    );
  }

  Future<void> _syncItem(SyncQueueItem item) async {
    switch (item.entityType) {
      case 'order':
        final payload = OrderRequest.fromJson(jsonDecode(item.payloadJson));
        final response = await ref.read(posApiServiceProvider).createOrder(payload);
        await ref.read(orderDaoProvider).markSynced(item.entityId, response.orderId);
        break;
      // Handle other entity types...
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}
```

---

## API Integration Layer

### 1. Retrofit API Service

```dart
@RestApi(baseUrl: 'https://api.nexuslab.asia')
abstract class PosApiService {
  factory PosApiService(Dio dio, {String baseUrl}) = _PosApiService;

  // Orders
  @POST('/api/v1/orders')
  Future<OrderResponse> createOrder(@Body() OrderRequest request);

  @GET('/api/v1/orders')
  Future<List<OrderResponse>> getOrders(
    @Query('tenant_id') String tenantId,
    @Query('branch_id') String branchId,
    @Query('from_date') String? fromDate,
  );

  // Menu Items
  @GET('/api/v1/menu-items')
  Future<List<MenuItemDto>> getMenuItems(
    @Query('tenant_id') String tenantId,
  );

  @PATCH('/api/v1/menu-items/{id}')
  Future<void> updateMenuItem(
    @Path('id') String id,
    @Body() Map<String, dynamic> updates,
  );

  // Authentication
  @POST('/api/v1/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/api/v1/auth/refresh')
  Future<AuthResponse> refreshToken(@Body() RefreshRequest request);
}
```

### 2. Dio Client with JWT Interceptor

```dart
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.nexuslab.asia',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // JWT Authentication Interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = ref.read(authTokenProvider);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, attempt refresh
          try {
            final newToken = await ref.read(authProvider.notifier).refreshToken();

            // Retry original request with new token
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';

            final response = await dio.fetch(opts);
            return handler.resolve(response);
          } catch (e) {
            // Refresh failed, logout user
            await ref.read(authProvider.notifier).logout();
            return handler.reject(error);
          }
        }
        return handler.next(error);
      },
    ),
  );

  // Logging Interceptor (dev only)
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  return dio;
}

@riverpod
PosApiService posApiService(PosApiServiceRef ref) {
  return PosApiService(ref.watch(dioProvider));
}
```

---

## Feature Implementation

### 1. Menu Display & Cart Management

#### Menu Provider
```dart
@riverpod
class Menu extends _$Menu {
  @override
  Future<List<MenuItem>> build() async {
    final repo = ref.read(menuRepositoryProvider);

    try {
      // Attempt to fetch fresh data from API
      final items = await repo.fetchFromApi();

      // Cache locally for offline access
      await repo.cacheLocally(items);

      return items;
    } catch (e) {
      // Fallback to local cache if API fails
      final cached = await repo.getFromCache();

      if (cached.isEmpty) {
        throw Exception('No menu items available offline');
      }

      return cached;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(menuRepositoryProvider);
      final items = await repo.fetchFromApi();
      await repo.cacheLocally(items);
      return items;
    });
  }
}

class MenuRepository {
  final PosApiService _api;
  final MenuDao _localDb;

  Future<List<MenuItem>> fetchFromApi() async {
    final tenantId = ref.read(currentTenantIdProvider);
    final dtos = await _api.getMenuItems(tenantId);
    return dtos.map((dto) => MenuItem.fromDto(dto)).toList();
  }

  Future<void> cacheLocally(List<MenuItem> items) async {
    await _localDb.transaction(() async {
      await _localDb.deleteAll();
      for (final item in items) {
        await _localDb.insertItem(item);
      }
    });
  }

  Future<List<MenuItem>> getFromCache() async {
    final items = await _localDb.getAllItems();
    return items.map((local) => MenuItem.fromLocal(local)).toList();
  }
}
```

#### Cart State Management
```dart
@freezed
class CartState with _$CartState {
  const factory CartState({
    @Default([]) List<CartItem> items,
    @Default(0.0) double subtotal,
    @Default(0.0) double tax,
    @Default(0.0) double total,
  }) = _CartState;

  const CartState._();

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
}

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required MenuItem menuItem,
    required int quantity,
    required double unitPrice,
    String? notes,
  }) = _CartItem;

  const CartItem._();

  double get lineTotal => unitPrice * quantity;
}

@riverpod
class Cart extends _$Cart {
  @override
  CartState build() => const CartState();

  void addItem(MenuItem item, {int quantity = 1, String? notes}) {
    final existingIndex = state.items.indexWhere(
      (cartItem) => cartItem.menuItem.id == item.id && cartItem.notes == notes,
    );

    List<CartItem> updatedItems;

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final existing = state.items[existingIndex];
      updatedItems = [...state.items];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      // Add new item
      updatedItems = [
        ...state.items,
        CartItem(
          menuItem: item,
          quantity: quantity,
          unitPrice: item.price,
          notes: notes,
        ),
      ];
    }

    state = _recalculate(updatedItems);
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(index);
      return;
    }

    final updatedItems = [...state.items];
    updatedItems[index] = updatedItems[index].copyWith(quantity: newQuantity);
    state = _recalculate(updatedItems);
  }

  void removeItem(int index) {
    final updatedItems = [...state.items]..removeAt(index);
    state = _recalculate(updatedItems);
  }

  void clear() {
    state = const CartState();
  }

  CartState _recalculate(List<CartItem> items) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.lineTotal);
    final tax = subtotal * 0.07; // 7% VAT (Thailand)
    final total = subtotal + tax;

    return CartState(
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
    );
  }
}
```

#### Checkout Flow
```dart
class CheckoutScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMethod _selectedPayment = PaymentMethod.cash;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Column(
        children: [
          // Cart items list
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return CartItemTile(
                  item: item,
                  onQuantityChanged: (qty) {
                    ref.read(cartProvider.notifier).updateQuantity(index, qty);
                  },
                  onRemove: () {
                    ref.read(cartProvider.notifier).removeItem(index);
                  },
                );
              },
            ),
          ),

          // Summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', cart.subtotal),
                _buildSummaryRow('Tax (7%)', cart.tax),
                Divider(),
                _buildSummaryRow('Total', cart.total, isBold: true),
              ],
            ),
          ),

          // Payment method selection
          PaymentMethodSelector(
            selected: _selectedPayment,
            onChanged: (method) => setState(() => _selectedPayment = method),
          ),

          // Process button
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: cart.isEmpty || _isProcessing ? null : _processPayment,
                child: _isProcessing
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Process Payment - ฿${cart.total.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : null)),
        Text(
          '฿${amount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: isBold ? FontWeight.bold : null),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final cart = ref.read(cartProvider);
      final tenantId = ref.read(currentTenantIdProvider);
      final branchId = ref.read(currentBranchIdProvider);

      // Build order request
      final orderRequest = OrderRequest(
        tenantId: tenantId,
        branchId: branchId,
        source: 'dinein',
        items: cart.items.map((item) => OrderItemDto(
          skuId: item.menuItem.id,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          notes: item.notes,
        )).toList(),
        totalAmount: cart.total,
        paymentMethod: _selectedPayment.name,
      );

      // Create order (handles offline/online)
      final order = await ref.read(orderRepositoryProvider).createOrder(orderRequest);

      // Print receipt
      await ref.read(printerServiceProvider).printReceipt(order);

      // Clear cart
      ref.read(cartProvider.notifier).clear();

      // Show success and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order completed: ${order.orderNumber}')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
```

---

## Bluetooth Printer Integration (US-002)

### Printer Service

```dart
class PrinterService {
  final BluetoothPrinter _bluetooth;

  Future<void> printReceipt(Order order) async {
    if (!await _bluetooth.isConnected) {
      throw PrinterNotConnectedException();
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text(
      'nexuslab.asia',
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.emptyLines(1);

    // Order info
    bytes += generator.row([
      PosColumn(text: 'Order:', width: 6),
      PosColumn(text: order.orderNumber, width: 6, align: PosAlign.right),
    ]);
    bytes += generator.text(
      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    // Items
    for (final item in order.items) {
      bytes += generator.row([
        PosColumn(text: item.name, width: 7),
        PosColumn(text: '${item.quantity}x', width: 2, align: PosAlign.center),
        PosColumn(
          text: '฿${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
          width: 3,
          align: PosAlign.right,
        ),
      ]);

      if (item.notes?.isNotEmpty ?? false) {
        bytes += generator.text(
          '  Note: ${item.notes}',
          styles: PosStyles(fontSize: PosFontSize.size1),
        );
      }
    }

    bytes += generator.hr();

    // Summary
    bytes += generator.row([
      PosColumn(text: 'Subtotal:', width: 9),
      PosColumn(
        text: '฿${order.subtotal.toStringAsFixed(2)}',
        width: 3,
        align: PosAlign.right,
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Tax (7%):', width: 9),
      PosColumn(
        text: '฿${order.tax.toStringAsFixed(2)}',
        width: 3,
        align: PosAlign.right,
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 9,
        styles: PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '฿${order.totalAmount.toStringAsFixed(2)}',
        width: 3,
        align: PosAlign.right,
        styles: PosStyles(bold: true, height: PosTextSize.size2),
      ),
    ]);

    bytes += generator.emptyLines(1);
    bytes += generator.text('Payment: ${order.paymentMethod.toUpperCase()}');

    // PromptPay QR Code (if applicable)
    if (order.paymentMethod == 'promptpay') {
      final promptPayQr = _generatePromptPayQR(order.totalAmount);
      bytes += generator.qrcode(promptPayQr, size: QRSize.Size6);
      bytes += generator.text(
        'Scan to pay with PromptPay',
        styles: PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.emptyLines(2);
    bytes += generator.text(
      'Thank you!',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    // Open cash drawer (if cash payment)
    if (order.paymentMethod == 'cash') {
      bytes += generator.drawer();
    }

    // Send to printer
    await _bluetooth.writeBytes(Uint8List.fromList(bytes));
  }

  Future<void> printKitchenTicket(Order order) async {
    if (!await _bluetooth.isConnected) {
      throw PrinterNotConnectedException();
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Kitchen header
    bytes += generator.text(
      'KITCHEN ORDER',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
    );
    bytes += generator.emptyLines(1);

    // Order source badge
    String sourceBadge;
    switch (order.source) {
      case 'grab':
        sourceBadge = '[GRAB DELIVERY]';
        break;
      case 'wongnai':
        sourceBadge = '[LINE MAN]';
        break;
      default:
        sourceBadge = order.tableNumber != null ? '[TABLE ${order.tableNumber}]' : '[TAKEOUT]';
    }

    bytes += generator.text(
      sourceBadge,
      styles: PosStyles(align: PosAlign.center, reverse: true),
    );
    bytes += generator.emptyLines(1);

    bytes += generator.text('Order: ${order.orderNumber}');
    bytes += generator.text(DateFormat('HH:mm').format(order.createdAt));
    bytes += generator.hr(ch: '=');

    // Items (larger font for kitchen)
    for (final item in order.items) {
      bytes += generator.text(
        '${item.quantity}x ${item.name}',
        styles: PosStyles(bold: true, height: PosTextSize.size2),
      );

      if (item.notes?.isNotEmpty ?? false) {
        bytes += generator.text(
          '>>> ${item.notes} <<<',
          styles: PosStyles(bold: true, reverse: true),
        );
      }

      bytes += generator.emptyLines(1);
    }

    bytes += generator.hr(ch: '=');
    bytes += generator.feed(3);
    bytes += generator.cut();

    await _bluetooth.writeBytes(Uint8List.fromList(bytes));
  }

  String _generatePromptPayQR(double amount) {
    // EMVQRCPS standard implementation
    // Payload: 00020101021129370016A000000677010111XXXXXXXXXXXX5802TH540X.XX6304YYYY
    final promptPayId = ref.read(tenantSettingsProvider).promptpayId;

    // Simplified - use emvqr package in real implementation
    return 'promptpay://${promptPayId}?amount=${amount.toStringAsFixed(2)}';
  }
}

// Printer scanner and connection
@riverpod
class PrinterScanner extends _$PrinterScanner {
  @override
  Future<List<BluetoothDevice>> build() async {
    final flutterBlue = FlutterBluePlus.instance;

    // Start scanning
    await flutterBlue.startScan(timeout: Duration(seconds: 5));

    // Collect results
    final devices = <BluetoothDevice>[];
    await for (final result in flutterBlue.scanResults) {
      devices.addAll(result.map((r) => r.device));
    }

    await flutterBlue.stopScan();
    return devices;
  }

  Future<void> connectToPrinter(BluetoothDevice device) async {
    try {
      await device.connect(timeout: Duration(seconds: 10));

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('paired_printer_id', device.id.toString());
      await prefs.setString('paired_printer_name', device.name);

      // Update provider state
      ref.invalidate(connectedPrinterProvider);
    } catch (e) {
      throw PrinterConnectionException('Failed to connect: $e');
    }
  }
}
```

---

## Manager PIN Security (US-005)

### PIN Verification System

```dart
@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    _loadCachedAuth();
    return AuthState.unauthenticated();
  }

  Future<void> _loadCachedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('current_user');

    if (token != null && userJson != null) {
      final user = User.fromJson(jsonDecode(userJson));
      state = AuthState.authenticated(user: user, token: token);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await ref.read(posApiServiceProvider).login(
        LoginRequest(email: email, password: password),
      );

      // Cache credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.token);
      await prefs.setString('current_user', jsonEncode(response.user.toJson()));

      state = AuthState.authenticated(user: response.user, token: response.token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyManagerPin(String pin) async {
    final user = state.user;
    if (user == null) return false;

    // Hash PIN locally
    final hashedPin = _hashPin(pin);

    // Compare with stored hash
    if (user.managerPinHash == hashedPin) {
      // Success - log attempt
      await _logPinAttempt(success: true);

      // Reset failure counter
      state = state.copyWith(failedPinAttempts: 0);
      return true;
    } else {
      // Failure - increment counter
      final newAttempts = state.failedPinAttempts + 1;
      state = state.copyWith(failedPinAttempts: newAttempts);

      // Log attempt
      await _logPinAttempt(success: false);

      // Lock after 3 attempts
      if (newAttempts >= 3) {
        await _notifyOwnerOfLockout();
        throw PinLockoutException('Too many failed attempts');
      }

      return false;
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<void> _logPinAttempt({required bool success}) async {
    final deviceId = await _getDeviceId();
    final log = AuditLog(
      userId: state.user!.id,
      action: 'pin_verification',
      deviceId: deviceId,
      success: success,
      timestamp: DateTime.now(),
    );

    // Log locally (will sync to server)
    await ref.read(auditLogRepositoryProvider).log(log);
  }

  Future<void> _notifyOwnerOfLockout() async {
    // Send notification to backend (queued if offline)
    await ref.read(posApiServiceProvider).notifySecurityEvent(
      SecurityEventDto(
        type: 'pin_lockout',
        userId: state.user!.id,
        deviceId: await _getDeviceId(),
        timestamp: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.id;
    } else {
      final info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? 'unknown';
    }
  }

  void resetPinAttempts() {
    state = state.copyWith(failedPinAttempts: 0);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');

    state = AuthState.unauthenticated();
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = Unauthenticated;

  const factory AuthState.authenticated({
    required User user,
    required String token,
    @Default(0) int failedPinAttempts,
  }) = Authenticated;
}
```

### PIN Dialog Widget

```dart
class ManagerPinDialog extends ConsumerStatefulWidget {
  final String actionDescription;
  final VoidCallback onSuccess;

  const ManagerPinDialog({
    required this.actionDescription,
    required this.onSuccess,
  });

  @override
  ConsumerState<ManagerPinDialog> createState() => _ManagerPinDialogState();
}

class _ManagerPinDialogState extends ConsumerState<ManagerPinDialog> {
  final _pinController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final failedAttempts = authState is Authenticated ? authState.failedPinAttempts : 0;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock, color: Colors.orange),
          SizedBox(width: 8),
          Text('Manager Authorization'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.actionDescription),
          SizedBox(height: 16),

          if (failedAttempts > 0)
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Failed attempts: $failedAttempts/3',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          if (failedAttempts > 0) SizedBox(height: 16),

          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Manager PIN',
              border: OutlineInputBorder(),
              errorText: _errorMessage,
            ),
            onSubmitted: (_) => _verifyPin(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verifyPin,
          child: _isVerifying
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text('Verify'),
        ),
      ],
    );
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();

    if (pin.length != 4) {
      setState(() => _errorMessage = 'PIN must be 4 digits');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final isValid = await ref.read(authProvider.notifier).verifyManagerPin(pin);

      if (isValid) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onSuccess();
        }
      } else {
        setState(() {
          _errorMessage = 'Incorrect PIN';
          _pinController.clear();
        });
      }
    } on PinLockoutException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}

// Usage example
class MenuItemCard extends StatelessWidget {
  final MenuItem item;

  void _editPrice(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ManagerPinDialog(
        actionDescription: 'Edit price for ${item.name}',
        onSuccess: () {
          // Show price edit dialog
          _showPriceEditDialog(context, ref);
        },
      ),
    );
  }
}
```

---

## Error Handling & Resilience

### Error Types

```dart
sealed class AppError {
  String get message;
  bool get isRetryable;
  bool get isCritical;
  VoidCallback? get onRetry;
}

class NetworkError extends AppError {
  final String message;
  final VoidCallback? onRetry;

  bool get isRetryable => true;
  bool get isCritical => false;
}

class PrinterError extends AppError {
  final String message;
  final VoidCallback? onRetry;

  bool get isRetryable => true;
  bool get isCritical => false;
}

class AuthError extends AppError {
  final String message;

  bool get isRetryable => false;
  bool get isCritical => true;
  VoidCallback? get onRetry => null;
}

class DataSyncError extends AppError {
  final String message;
  final VoidCallback? onRetry;

  bool get isRetryable => true;
  bool get isCritical => false;
}
```

### Global Error Handler

```dart
@riverpod
class ErrorNotifier extends _$ErrorNotifier {
  @override
  AppError? build() => null;

  void showError(AppError error) {
    state = error;

    // Auto-dismiss non-critical errors
    if (!error.isCritical) {
      Future.delayed(Duration(seconds: 5), () {
        if (state == error) {
          state = null;
        }
      });
    }
  }

  void dismiss() => state = null;
}

// Error banner widget
class GlobalErrorBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(errorNotifierProvider);

    if (error == null) return SizedBox.shrink();

    return MaterialBanner(
      backgroundColor: error.isCritical ? Colors.red : Colors.orange,
      content: Row(
        children: [
          Icon(
            error.isCritical ? Icons.error : Icons.warning,
            color: Colors.white,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              error.message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      actions: [
        if (error.isRetryable && error.onRetry != null)
          TextButton(
            onPressed: () {
              ref.read(errorNotifierProvider.notifier).dismiss();
              error.onRetry?.call();
            },
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        TextButton(
          onPressed: () => ref.read(errorNotifierProvider.notifier).dismiss(),
          child: Text('Dismiss', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
```

---

## Testing Strategy

### Unit Tests (80%+ Coverage Target)

```dart
// test/repositories/order_repository_test.dart
void main() {
  late OrderRepository repository;
  late MockPosApiService mockApi;
  late MockOrderDao mockDao;
  late MockSyncQueueDao mockSyncQueue;
  late MockConnectivityProvider mockConnectivity;

  setUp(() {
    mockApi = MockPosApiService();
    mockDao = MockOrderDao();
    mockSyncQueue = MockSyncQueueDao();
    mockConnectivity = MockConnectivityProvider();

    repository = OrderRepository(
      mockApi,
      mockDao,
      mockSyncQueue,
      mockConnectivity,
    );
  });

  group('createOrder', () {
    test('saves locally and queues when offline', () async {
      // Arrange
      when(() => mockConnectivity.isOnline).thenReturn(false);
      when(() => mockDao.insertOrder(any())).thenAnswer(
        (_) async => LocalOrder(id: 1, orderNumber: 'ORD-001', isSynced: false),
      );

      final request = OrderRequest(
        tenantId: 'tenant-1',
        branchId: 'branch-1',
        source: 'dinein',
        items: [],
        totalAmount: 100,
        paymentMethod: 'cash',
      );

      // Act
      final order = await repository.createOrder(request);

      // Assert
      verify(() => mockDao.insertOrder(any())).called(1);
      verify(() => mockSyncQueue.enqueue(
        entityType: 'order',
        entityId: 1,
        action: 'create',
        payloadJson: any(named: 'payloadJson'),
        priority: 1,
      )).called(1);
      verifyNever(() => mockApi.createOrder(any()));

      expect(order.isSynced, false);
    });

    test('syncs immediately when online', () async {
      // Arrange
      when(() => mockConnectivity.isOnline).thenReturn(true);
      when(() => mockDao.insertOrder(any())).thenAnswer(
        (_) async => LocalOrder(id: 1, orderNumber: 'ORD-001', isSynced: false),
      );
      when(() => mockApi.createOrder(any())).thenAnswer(
        (_) async => OrderResponse(orderId: 'server-123', orderNumber: 'ORD-001'),
      );
      when(() => mockDao.updateOrder(any(), orderId: any(named: 'orderId'))).thenAnswer(
        (_) async => {},
      );

      final request = OrderRequest(
        tenantId: 'tenant-1',
        branchId: 'branch-1',
        source: 'dinein',
        items: [],
        totalAmount: 100,
        paymentMethod: 'cash',
      );

      // Act
      final order = await repository.createOrder(request);

      // Assert
      verify(() => mockApi.createOrder(any())).called(1);
      verify(() => mockDao.updateOrder(
        1,
        orderId: 'server-123',
        syncedAt: any(named: 'syncedAt'),
        isSynced: true,
      )).called(1);
      verifyNever(() => mockSyncQueue.enqueue(any()));

      expect(order.orderId, 'server-123');
    });

    test('queues for retry when API fails', () async {
      // Arrange
      when(() => mockConnectivity.isOnline).thenReturn(true);
      when(() => mockDao.insertOrder(any())).thenAnswer(
        (_) async => LocalOrder(id: 1, orderNumber: 'ORD-001', isSynced: false),
      );
      when(() => mockApi.createOrder(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/orders')),
      );

      final request = OrderRequest(
        tenantId: 'tenant-1',
        branchId: 'branch-1',
        source: 'dinein',
        items: [],
        totalAmount: 100,
        paymentMethod: 'cash',
      );

      // Act
      final order = await repository.createOrder(request);

      // Assert
      verify(() => mockSyncQueue.enqueue(
        entityType: 'order',
        entityId: 1,
        action: 'create',
        payloadJson: any(named: 'payloadJson'),
        priority: 1,
      )).called(1);

      expect(order.isSynced, false);
    });
  });
}
```

### Widget Tests

```dart
// test/widgets/cart_screen_test.dart
void main() {
  testWidgets('Cart displays empty state when no items', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: CartScreen()),
      ),
    );

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('Checkout button enabled when cart has items', (tester) async {
    final cart = Cart();
    cart.addItem(MenuItem(
      id: '1',
      name: 'Test Item',
      price: 100,
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartProvider.overrideWith((ref) => cart),
        ],
        child: MaterialApp(home: CheckoutScreen()),
      ),
    );

    final button = find.byType(ElevatedButton);
    expect(button, findsOneWidget);
    expect(tester.widget<ElevatedButton>(button).enabled, true);
  });

  testWidgets('Manager PIN dialog appears on price edit', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: MenuItemCard(item: testMenuItem)),
      ),
    );

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('Manager Authorization'), findsOneWidget);
    expect(find.text('Manager PIN'), findsOneWidget);
  });
}
```

### Integration Tests

```dart
// integration_test/order_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete order flow: menu -> cart -> checkout -> print', (tester) async {
    // Initialize app with test providers
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // 1. Navigate to menu
    await tester.tap(find.byIcon(Icons.restaurant_menu));
    await tester.pumpAndSettle();

    // 2. Add item to cart
    await tester.tap(find.text('Pad Thai').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_shopping_cart));
    await tester.pumpAndSettle();

    // 3. Navigate to cart
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();

    // Verify item in cart
    expect(find.text('Pad Thai'), findsOneWidget);

    // 4. Proceed to checkout
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    // 5. Select payment method
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();

    // 6. Process payment
    await tester.tap(find.text('Process Payment'));
    await tester.pumpAndSettle(timeout: Duration(seconds: 5));

    // 7. Verify success
    expect(find.text('Order completed'), findsOneWidget);

    // 8. Verify order saved to database
    final db = await openDatabase();
    final orders = await db.select(db.orders).get();
    expect(orders.length, greaterThan(0));
    expect(orders.last.totalAmount, closeTo(120, 0.01)); // Pad Thai price
  });

  testWidgets('Offline order syncs when connectivity restored', (tester) async {
    // 1. Disable network
    await NetworkSimulator.disable();

    // 2. Create order
    await tester.pumpWidget(MyApp());
    // ... create order flow ...

    // 3. Verify order is marked as unsynced
    final db = await openDatabase();
    final order = await db.select(db.orders).getSingle();
    expect(order.isSynced, false);

    // 4. Re-enable network
    await NetworkSimulator.enable();
    await tester.pump(Duration(seconds: 35)); // Wait for sync timer

    // 5. Verify order is now synced
    final syncedOrder = await db.select(db.orders).getSingle();
    expect(syncedOrder.isSynced, true);
    expect(syncedOrder.orderId, isNotNull);
  });
}
```

---

## Platform-Specific Considerations

### Android

**Bluetooth Permissions (AndroidManifest.xml)**
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

**Runtime Permission Handling**
```dart
Future<bool> requestBluetoothPermissions() async {
  if (Platform.isAndroid) {
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ];

    final statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }
  return true;
}
```

### iOS

**Info.plist Configuration**
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access to connect to receipt printers</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth access to print receipts</string>
```

**Background Limitations**
- iOS restricts background Bluetooth operations
- Sync operations should complete before app backgrounds
- Use background fetch for periodic sync (15-minute minimum)

```dart
// iOS background fetch configuration
@pragma('vm:entry-point')
void backgroundFetchHandler() async {
  final container = ProviderContainer();
  await container.read(syncServiceProvider.notifier).processSyncQueue();
  container.dispose();
}
```

---

## Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| App Launch Time | < 2 seconds | Time to interactive home screen |
| Add to Cart | < 100ms | From tap to UI update |
| Order Creation (Offline) | < 200ms | Local DB write + UI feedback |
| Order Sync | < 5 seconds | From connectivity to server confirmation |
| Receipt Print | < 3 seconds | From button tap to print complete |
| Menu Load (Cached) | < 500ms | From navigation to grid display |
| Database Query | < 50ms | Average query response time |
| APK Size | < 50MB | Release build size |

---

## Security Checklist

- ✅ JWT tokens stored in secure storage (not SharedPreferences plaintext)
- ✅ PIN hashes use SHA-256 (never store plaintext)
- ✅ HTTPS/TLS 1.3 for all API calls
- ✅ SQL injection prevention (Drift parameterized queries)
- ✅ Certificate pinning for API client (optional, recommended for production)
- ✅ Audit logs for all sensitive actions
- ✅ No API keys or secrets in source code (use environment variables)
- ✅ Rate limiting for PIN attempts (3 max)
- ✅ Session timeout after 24 hours inactivity

---

## Deployment Checklist

### Pre-Launch
- [ ] Test on physical Android tablet (8.0+)
- [ ] Test on physical iPad (iOS 13+)
- [ ] Test with 3+ different Bluetooth printer models
- [ ] Verify offline mode works for 4+ hours
- [ ] Load test: 100 orders created offline, all sync successfully
- [ ] Security audit: penetration testing on API calls
- [ ] Performance audit: all targets met
- [ ] Accessibility audit: TalkBack/VoiceOver support

### App Store Preparation
- [ ] Android: Generate signed APK/AAB with release keystore
- [ ] iOS: Archive with distribution certificate
- [ ] App icons (1024x1024 for iOS, adaptive icon for Android)
- [ ] Screenshots for both platforms (tablets)
- [ ] Privacy policy URL
- [ ] App store descriptions
- [ ] Version 1.0.0 ready

### Post-Launch Monitoring
- [ ] Crashlytics/Sentry integration
- [ ] Analytics: track order flow completion rate
- [ ] Monitor sync queue size (alert if > 50 pending)
- [ ] Monitor print failure rate
- [ ] Monitor API error rates

---

## Next Steps

1. **Initialize Flutter Project**
   ```bash
   flutter create --org store.nexuspoint --platforms android,ios nexuspoint_pos
   cd nexuspoint_pos
   ```

2. **Set Up Git Worktree** (use superpowers:using-git-worktrees skill)
   - Create isolated workspace for development
   - Keep main directory clean

3. **Generate Implementation Plan** (use superpowers:writing-plans skill)
   - Break down into 2-week sprint tasks
   - Define acceptance criteria for each task
   - Set up Kanban board

4. **Scaffold Project Structure**
   - Create feature directories
   - Set up code generation scripts
   - Configure CI/CD pipeline

---

## Appendix: Key Decision Records

### Why Riverpod over BLoC?
**Decision:** Use Riverpod for state management
**Rationale:** Aligns with existing React/Astro lightweight approach. BLoC adds unnecessary ceremony for a 2-3 week MVP. Riverpod provides compile-time safety, testability, and less boilerplate.
**Trade-off:** Smaller community than BLoC, but growing rapidly.

### Why Drift over sqflite?
**Decision:** Use Drift for local database
**Rationale:** Type-safe queries at compile time, reactive streams for UI updates, built-in migration support. Worth the code generation overhead for fewer runtime bugs.
**Trade-off:** Requires build_runner, adds ~2-3 seconds to build time.

### Why Cross-Platform from Day One?
**Decision:** Build for both Android and iOS in MVP
**Rationale:** Merchant owners often use iPads. Supporting both early prevents technical debt and ensures printer compatibility is tested on both platforms.
**Trade-off:** Slightly slower initial development, but pays off in market reach.

### Why Offline-First Architecture?
**Decision:** Local DB as source of truth, server as sync target
**Rationale:** Food service environments have unreliable WiFi. System must continue operating during outages. This aligns with SRS NFR requirement of 4+ hour offline capability.
**Trade-off:** More complex sync logic, but critical for business continuity.

---

**Document Status:** ✅ Ready for Implementation
**Next Action:** Use superpowers:using-git-worktrees to set up development workspace
**Estimated Implementation Time:** 2-3 weeks (Core Transaction Flow MVP)
