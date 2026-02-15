# NexusPoint POS — Progress Tracker

> Last updated: 2026-02-15
> Branch: `feature/flutter-pos-mvp`
> Next action: `/superpowers:write-plan` for remaining MVP tasks

---

## ✅ Completed

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
- [x] `PosApiService` (Retrofit) — login, orders, menu endpoints
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

### Phase 7 — Platform Permissions
- [x] Android: Bluetooth (SCAN, CONNECT, ADMIN), Location, Internet
- [x] Android: minSdk 21 for BLE
- [x] iOS: `NSBluetoothAlwaysUsageDescription`, `NSLocationWhenInUseUsageDescription`

### Phase 8 — UI Shell & Screens (Beyond Original Plan)
- [x] `PosShell` — NavigationRail (extended ≥1024px) with 4 destinations
  - Bridge, Register, Menu, Orders
- [x] `PosTheme` — light theme, blue/white palette, Material 3
- [x] `BridgeDashboardScreen` — 3-column Kanban (Pending / In Progress / Done)
- [x] `SpeedRegisterScreen` — split-view (menu grid left, cart right)
- [x] `ConnectionHeartbeat` widget — API connectivity status indicator

---

## ❌ Remaining — MVP Critical Path

### Task 16 — Bluetooth Printer Service
- [ ] `PrinterService` in `lib/features/printer/services/`
- [ ] `flutter_blue_plus` scan, connect, disconnect
- [ ] ESC/POS receipt builder (`esc_pos_utils`)
- [ ] Kitchen ticket builder (different format from receipt)
- [ ] Print job queue

### Task 17 — Printer Discovery & Pairing UI
- [ ] `PrinterSettingsScreen` — scan list, pair/unpair
- [ ] Saved printer persistence (SharedPreferences)
- [ ] Printer status indicator in PosShell

### Task 18 — Checkout Flow
- [ ] `CheckoutScreen` / checkout modal from SpeedRegister
- [ ] Payment method selector: cash / PromptPay / card
- [ ] Cash: enter tendered amount → change calculation
- [ ] PromptPay: QR code display
- [ ] Order submission via `OrderRepository.createOrder()`
- [ ] Success confirmation with order number
- [ ] Cart clear on success

### Task 19 — Receipt & Kitchen Ticket Printing
- [ ] Auto-print receipt on checkout success
- [ ] Auto-print kitchen ticket
- [ ] Manual reprint from order history
- [ ] Print preview (optional)

### Task 20 — Background Sync Service ✅ (2026-02-15)
- [x] `SyncServiceNotifier` in `lib/features/orders/services/sync_service.dart`
- [x] Retry logic (max 3 attempts, `markFailed` after limit)
- [x] `connectivity_plus` listener — trigger sync on reconnect
- [x] `SyncState` with `idle / syncing / error` + `pendingCount`
- [x] `syncServiceProvider` (Riverpod StateNotifier)
- [x] Tests: `test/unit/sync_service_test.dart` (7 tests)

### Task 21 — Order History UI ✅ (2026-02-15)
- [x] `OrderHistoryScreen` in `lib/features/orders/widgets/`
- [x] Orders grouped by day with time display
- [x] Order detail bottom sheet (items, total, payment, table)
- [x] `_SyncBadge` (local / synced), `_StatusChip` (pending/confirmed/done/cancelled)
- [x] Wired into `PosShell` case 4 (replaced placeholder)
- [x] Tests: `test/unit/order_provider_test.dart` (5 tests)

### Task 22 — PIN Dialog ✅ (2026-02-15)
- [x] `lib/features/auth/widgets/pin_dialog.dart` — `showPinDialog()` helper
- [x] 4-digit numpad with backspace, PIN dots, error message, lockout handling
- [x] Calls `authProvider.verifyManagerPin()` — existing lockout logic preserved
- [x] Tests: `test/widget/pin_dialog_test.dart` (6 tests)

### Task 23 — Integration Tests
- [ ] End-to-end order flow: login → add items → checkout → receipt
- [ ] Offline mode test: create order without internet → sync on reconnect
- [ ] `integration_test/app_test.dart`

### Task 24 — Physical Device Testing
- [ ] Android tablet (Android 8+)
- [ ] iPad (iOS 13+)
- [ ] Bluetooth printer pairing and printing test

### Task 25 — Polish & Performance
- [ ] Error banner widget (`lib/shared/widgets/error_banner.dart`)
- [ ] Loading skeletons for menu grid
- [ ] Haptic feedback on cart actions
- [ ] Image caching for menu item images

---

## Known Issues / Blockers

| # | Issue | Status |
|---|-------|--------|
| 1 | `session.active_organization_id` may be NULL for new users | Workaround in `FIX_SUMMARY.md` |
| 2 | `CartItem` has no widget — SpeedRegister cart panel needs cart items list | Needed for Task 18 |
| 3 | `appDatabaseProvider` defined in `menu_repository.dart` — should move to `core/providers/` | Tech debt |
| 4 | `order_repository.dart` hardcodes `branchId: 'default'` | Needs settings/config |

---

## Architecture Reference

```
lib/
├── core/
│   ├── api/          ← api_service.dart (Retrofit), api_exception.dart
│   ├── config/       ← app_config.dart (flavors, dart-define)
│   ├── database/     ← app_database.dart + tables/ + daos/
│   ├── models/       ← MenuItem, Order, CartItem, User, api_models
│   ├── providers/    ← dio_provider, auth_token_provider
│   └── theme/        ← pos_theme.dart
├── features/
│   ├── auth/         ← auth_provider, login_screen       ✅
│   ├── cart/         ← cart_provider                     ✅ (no UI yet)
│   ├── dashboard/    ← bridge_dashboard_screen            ✅
│   ├── menu/         ← menu_repository, menu_provider, menu_screen ✅
│   ├── orders/       ← order_repository, order_provider  ✅ (no UI yet)
│   ├── printer/      ← EMPTY                             ❌
│   ├── register/     ← speed_register_screen             ✅ (no checkout)
│   └── shell/        ← pos_shell.dart                    ✅
└── shared/
    └── widgets/      ← connection_heartbeat               ✅
```

---

## Next Session Plan Scope

For `/superpowers:write-plan`, focus on these in priority order:

1. **Checkout Flow** (Task 18) — highest business value, unblocks everything
2. **Cart UI in SpeedRegister** — complete the register screen
3. **PIN Dialog** (Task 22) — needed for manager overrides
4. **Order History UI** (Task 21) — complete the Orders nav destination
5. **Background Sync** (Task 20) — offline reliability
6. **Bluetooth Printer** (Tasks 16–19) — receipt printing
