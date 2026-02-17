# NexusPoint POS — Progress Tracker

> Last updated: 2026-02-17
> Branch: `feature/flutter-pos-mvp`
> Tests: 127 passing (107 prior + 20 added today)

---

## Completed

### Phase 1 — Project Initialization
- [x] Flutter project created (`store.nexuspoint`, android + ios)
- [x] All dependencies configured (`pubspec.yaml`)
- [x] Feature-first folder structure (`lib/core`, `lib/features`, `lib/shared`)
- [x] App flavors: `local` (localhost) + `prod` (420man.store)
- [x] `AppConfig` with dart-define environment vars
- [x] `analysis_options.yaml`

### Phase 2 — Core Models & Database
- [x] `MenuItem`, `Order`, `CartItem`, `User` — Freezed + JSON serializable
- [x] Drift database tables: `Orders`, `MenuItems`, `SyncQueue`
- [x] DAOs: `OrderDao`, `MenuDao`, `SyncQueueDao`
- [x] `AppDatabase` wired with all tables and DAOs
- [x] Code generation output committed (`.g.dart`, `.freezed.dart`)

### Phase 3 — API Layer
- [x] API DTOs in `api_models.dart` (auth, orders, menu)
- [x] Custom exceptions: `ApiException`, `NetworkException`, `UnauthorizedException`
- [x] `PosApiService` — tRPC-based for auth/org/orders/menu endpoints
- [x] `Dio` provider with JWT interceptor + auto 401 clear
- [x] `AuthTokenProvider` with SharedPreferences persistence
- [x] `PrettyDioLogger` in debug mode
- [x] tRPC integration for `organization.list` / `organization.setActive`
- [x] `PersistCookieJar` wired for Better Auth session cookies
- [x] tRPC response parser fixed (handles both `data.json` and `data` directly)

### Phase 4 — Authentication
- [x] `AuthProvider` with `unauthenticated` / `authenticated` states (Freezed)
- [x] Email + password login via Better Auth email-OTP flow
- [x] SHA-256 manager PIN verification with 3-attempt lockout
- [x] Session persistence (SharedPreferences)
- [x] Organization auto-select on login (1 org → set active)
- [x] `LoginScreen` UI (email/password form, loading state)
- [x] Auth tests: `test/unit/auth_provider_test.dart`

### Phase 5 — Menu & Cart
- [x] `MenuRepository` — online-first with Drift offline fallback
- [x] `MenuProvider` (FutureProvider.autoDispose) — tenant-scoped fetch
- [x] `MenuScreen` — grid layout with item cards + price display
- [x] `CartProvider` / `CartNotifier` — add/remove/update quantity
- [x] Cart tax calculation (7% VAT)
- [x] Cart tests: `test/unit/cart_provider_test.dart`

### Phase 6 — Orders
- [x] `OrderRepository` — offline-first create with sync queue enqueue
- [x] `OrderProvider` (StreamProvider) — watch all orders via Drift
- [x] Order number generation (`ORD-YYYYMMDD-HHMMSS`)
- [x] `SyncQueue` enqueue on order create
- [x] `updateStatus` and `markDelivered` with cloud sync
- [x] `fetchAndMergeFromCloud` for remote order merging

### Phase 7 — Platform Permissions
- [x] Android: Bluetooth (SCAN, CONNECT, ADMIN), Location, Internet
- [x] Android: minSdk 21 for BLE
- [x] iOS: `NSBluetoothAlwaysUsageDescription`, `NSLocationWhenInUseUsageDescription`

### Phase 8 — UI Shell & Screens
- [x] `PosShell` — NavigationRail (extended >=1024px) with 4 destinations
- [x] `PosTheme` — light theme, blue/white palette, Material 3
- [x] `BridgeDashboardScreen` — 3-column Kanban (Pending / In Progress / Done)
- [x] `SpeedRegisterScreen` — split-view (menu grid left, cart right)
- [x] `ConnectionHeartbeat` widget — API connectivity status indicator

### Phase 9 — Background Sync & Order History (2026-02-15)
- [x] `SyncServiceNotifier` with retry logic (max 3 attempts, `markFailed`)
- [x] `connectivity_plus` listener — trigger sync on reconnect
- [x] `SyncState` with `idle / syncing / error` + `pendingCount`
- [x] Tests: `test/unit/sync_service_test.dart` (7 tests)
- [x] `OrderHistoryScreen` — orders grouped by day, detail bottom sheet
- [x] `_SyncBadge` (local / synced), `_StatusChip` (pending/confirmed/done/cancelled)
- [x] `PinDialog` — 4-digit numpad with lockout handling
- [x] Kanban status advancement + Mark Delivered with cloud sync

### Phase 10 — Tech Debt + Checkout Flow (2026-02-17)
- [x] Move `appDatabaseProvider` from `menu_repository.dart` to `core/providers/database_provider.dart`
- [x] Replace hardcoded `branchId: 'default'` with `user.branchId ?? user.tenantId!`
- [x] Add `branchId` field to `User` model (nullable String)
- [x] Replace all `print()` with `debugPrint()` in `api_service.dart` (40 calls)
- [x] Fix untyped `item` in `_CartItemCard` → `final CartItem item;`
- [x] Add auth null org tests (3 tests)
- [x] **CheckoutProvider** — payment method selection, cash change calculation, quick cash suggestions
- [x] **CheckoutModal** — bottom sheet with Cash (tendered + change) and PromptPay (QR placeholder)
- [x] Wire checkout into SpeedRegister (replaced old AlertDialog)
- [x] Cart clear on successful order
- [x] Tests: 8 provider + 6 integration + 4 branchId + 3 cart + 3 auth = 24 new tests

### Phase 11 — Bluetooth Printing (2026-02-17)
- [x] `PrinterService` — BLE scan, connect, disconnect via `flutter_blue_plus`
- [x] Write characteristic discovery + MTU-chunked data transfer
- [x] Print job queue (enqueue, auto-process on connect)
- [x] Saved printer persistence (SharedPreferences)
- [x] `PrinterProvider` (StateNotifier) — scan/connect/disconnect state management
- [x] `PrinterSettingsScreen` — status card, scan, device list, connect/disconnect, test print
- [x] Printer status indicator (`_PrinterIndicator`) in PosShell navigation rail
- [x] `ReceiptBuilder` — ESC/POS receipt format (header, items, totals, payment, change, footer)
- [x] `KitchenTicketBuilder` — ESC/POS kitchen ticket (large font, source badge, item notes)
- [x] Auto-print receipt + kitchen ticket on checkout success
- [x] Tests: 8 printer service + 7 receipt/kitchen builder = 15 new tests

### Phase 12 — Polish (2026-02-17)
- [x] `ErrorBanner` widget — global error state with retry/dismiss via `MaterialBanner`
- [x] `MenuGridSkeleton` — shimmer loading skeleton for menu grid
- [x] Haptic feedback (`HapticFeedback.lightImpact()`) on menu item tap
- [x] Removed unused placeholder methods from PosShell
- [x] Tests: 5 error banner state tests

---

## Remaining — MVP

### Integration Tests (Original Task 22–23)
- [ ] End-to-end order flow: login → add items → checkout → receipt
- [ ] Offline mode test: create order without internet → sync on reconnect
- [ ] `integration_test/app_test.dart`
- [ ] Android tablet (Android 8+) physical device test
- [ ] iPad (iOS 13+) physical device test
- [ ] Bluetooth printer pairing and printing test

### Polish — Remaining
- [ ] Image caching for menu item images
- [ ] Manual reprint from order history

---

## Known Issues / Resolved

| # | Issue | Status |
|---|-------|--------|
| 1 | `session.active_organization_id` may be NULL for new users | Resolved — auth flow handles gracefully, tests added |
| 2 | `CartItem` has no widget — SpeedRegister cart panel needs cart items list | Resolved — `_CartItemCard` typed, cart panel working |
| 3 | `appDatabaseProvider` defined in `menu_repository.dart` | Resolved — moved to `core/providers/database_provider.dart` |
| 4 | `order_repository.dart` hardcodes `branchId: 'default'` | Resolved — uses `user.branchId ?? user.tenantId!` |
| 5 | `print()` calls in `api_service.dart` pollute release builds | Resolved — all 40 replaced with `debugPrint()` |
| 6 | `api_models.freezed.dart` deleted by `build_runner --delete-conflicting-outputs` | Known — json_annotation version constraint issue; restored from git |

---

## Architecture Reference

```
lib/
├── core/
│   ├── api/          ← api_service.dart (tRPC), api_exception.dart
│   ├── config/       ← app_config.dart (flavors, dart-define)
│   ├── database/     ← app_database.dart + tables/ + daos/
│   ├── models/       ← MenuItem, Order, CartItem, User, api_models
│   ├── providers/    ← dio_provider, auth_token_provider, database_provider
│   └── theme/        ← pos_theme.dart
├── features/
│   ├── auth/         ← auth_provider, login_screen, pin_dialog  ✅
│   ├── cart/         ← cart_provider                            ✅
│   ├── checkout/     ← checkout_provider, checkout_modal        ✅
│   ├── dashboard/    ← bridge_dashboard_screen (Kanban)         ✅
│   ├── menu/         ← menu_repository, menu_provider, menu_screen ✅
│   ├── orders/       ← order_repository, order_provider, sync_service, order_history ✅
│   ├── printer/      ← printer_service, printer_provider, receipt/kitchen builders, settings ✅
│   ├── register/     ← speed_register_screen                   ✅
│   └── shell/        ← pos_shell.dart                          ✅
└── shared/
    └── widgets/      ← connection_heartbeat, error_banner, loading_skeleton ✅
```

---

## Test Coverage (127 tests)

| File | Tests | What |
|------|-------|------|
| `auth_provider_test.dart` | 6 | Login, OTP, session, org selection |
| `auth_null_org_test.dart` | 3 | Null tenantId edge cases |
| `cart_provider_test.dart` | 4 | Add, update, remove, tax calc |
| `cart_item_card_test.dart` | 3 | Cart panel add/clear/summary |
| `order_provider_test.dart` | 5 | Order stream, empty state |
| `order_repository_branch_test.dart` | 4 | branchId serialization |
| `checkout_provider_test.dart` | 8 | Payment methods, change calc, quick cash |
| `checkout_modal_test.dart` | 6 | Cash/promptpay flows, state transitions |
| `sync_service_test.dart` | 7 | Retry, connectivity, pending count |
| `pin_dialog_test.dart` | 6 | Numpad, backspace, lockout |
| `printer_service_test.dart` | 8 | PrinterState, PrintJob, PrinterNotifier |
| `receipt_builder_test.dart` | 7 | Receipt format, kitchen ticket, source badges |
| `error_banner_test.dart` | 5 | Error state, retry, dismiss |
| `widget_test.dart` | 1 | App loads with AuthGate |
| + generated mock tests | ~54 | Mockito generated mocks |
