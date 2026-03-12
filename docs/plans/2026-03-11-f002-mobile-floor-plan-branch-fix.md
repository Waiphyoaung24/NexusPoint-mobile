# F-002 Mobile Floor Plan — Branch Auto-Selection Fix

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix the "No tables configured" issue on the Flutter mobile floor plan by adding branch auto-selection — the mobile app never fetches `branchId`, so `table.list` returns empty.

**Architecture:** Add a `getBranches()` API call to `PosApiService`, fetch branches during auth login flow (after org is set), persist the first branch's ID on the `User` model, and update `floor_plan_provider.dart` to use the real `branchId`. No web API changes needed — `branch.list` tRPC endpoint already exists and works.

**Tech Stack:** Flutter 3.19+, Riverpod 2.4, Drift 2.14, Dio 5.4, tRPC over HTTP

**Root Cause:** `floor_plan_provider.dart:19` uses `user.branchId ?? orgId`. Auth flow in `auth_provider.dart` sets `tenantId` (org ID) but NEVER sets `branchId`. Fallback `orgId` doesn't match any branch → `table.list` returns `[]` → "No tables configured."

---

## Task 1: Add `getBranches()` to API Service

**Files:**
- Modify: `lib/core/api/api_service.dart`

**Step 1: Add the API method**

Add this method to `PosApiService` class (after the existing floor plan methods around line 850):

```dart
// Branch list for branch auto-selection
Future<List<Map<String, dynamic>>> getBranches() async {
  try {
    debugPrint('🏪 Fetching branches via tRPC: branch.list');
    final data = await _trpcQuery('branch.list');
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  } catch (e) {
    debugPrint('❌ Failed to fetch branches: $e');
    return [];
  }
}
```

**Step 2: Run the app to verify no compilation errors**

Run: `cd /Users/waiphyoaung/Desktop/NexusPoint/NexusPoint-mobile && flutter build ios --no-codesign --debug 2>&1 | tail -5`
Expected: Build succeeds

**Step 3: Commit**

```bash
cd /Users/waiphyoaung/Desktop/NexusPoint/NexusPoint-mobile
git add lib/core/api/api_service.dart
git commit -m "feat(F-002): add getBranches() API method for branch auto-selection"
```

---

## Task 2: Fetch Branch on Login and Persist `branchId`

**Files:**
- Modify: `lib/features/auth/providers/auth_provider.dart`

**Context:** The auth flow has 3 paths where `tenantId` gets set (lines 101, 161, 184). After EACH path sets `tenantId`, we need to also fetch branches and set `branchId`.

**Step 1: Add a `_fetchAndSetBranch` helper method**

Add this private method to `AuthNotifier` class (after the `_hashPin` method, around line 230):

```dart
/// Fetch branches for the active org and set the first branch on the user.
/// Returns the updated user with branchId populated.
Future<User> _fetchAndSetBranch(User user) async {
  try {
    final api = ref.read(posApiServiceProvider);
    final branches = await api.getBranches();
    if (branches.isNotEmpty) {
      final firstBranch = branches.first;
      final branchId = firstBranch['id'] as String?;
      final branchName = firstBranch['name'] as String?;
      if (branchId != null && branchId.isNotEmpty) {
        print('🏪 Auto-selected branch: $branchName ($branchId)');
        return user.copyWith(branchId: branchId);
      }
    }
    print('⚠️ No branches found for org ${user.tenantId}');
  } catch (e) {
    print('⚠️ Branch fetch failed (will retry on next sync): $e');
  }
  return user;
}
```

**Step 2: Wire it into auth path 1 — session already has activeOrgId (line ~101)**

Find this block (around line 99-107):
```dart
if (activeOrgId != null && activeOrgId.isNotEmpty) {
  print('✅ Found activeOrganizationId in session: $activeOrgId');
  final userWithOrg = response.user.copyWith(tenantId: activeOrgId);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));

  state = AuthState.authenticated(user: userWithOrg);
  return true;
}
```

Replace with:
```dart
if (activeOrgId != null && activeOrgId.isNotEmpty) {
  print('✅ Found activeOrganizationId in session: $activeOrgId');
  var userWithOrg = response.user.copyWith(tenantId: activeOrgId);
  userWithOrg = await _fetchAndSetBranch(userWithOrg);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));

  state = AuthState.authenticated(user: userWithOrg);
  return true;
}
```

**Step 3: Wire it into auth path 2 — single org auto-selected (line ~159)**

Find this block (around line 157-168):
```dart
if (activeOrgId != null && activeOrgId.isNotEmpty) {
  print('✅ Active Organization ID set: $activeOrgId');
  final userWithOrg = response.user.copyWith(tenantId: activeOrgId);

  // Save user with organization
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));

  state = AuthState.authenticated(user: userWithOrg);
  return true;
}
```

Replace with:
```dart
if (activeOrgId != null && activeOrgId.isNotEmpty) {
  print('✅ Active Organization ID set: $activeOrgId');
  var userWithOrg = response.user.copyWith(tenantId: activeOrgId);
  userWithOrg = await _fetchAndSetBranch(userWithOrg);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));

  state = AuthState.authenticated(user: userWithOrg);
  return true;
}
```

**Step 4: Wire it into auth path 3 — response already has activeOrgId (line ~184)**

Find this block (around line 182-193):
```dart
// ✅ User already has active organization
print('✅ Active Organization ID: ${response.activeOrganizationId}');
final userWithOrg = response.user.copyWith(
  tenantId: response.activeOrganizationId,
);

// Save user with organization
final prefs = await SharedPreferences.getInstance();
await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));

state = AuthState.authenticated(user: userWithOrg);
return true;
```

Replace with:
```dart
// ✅ User already has active organization
print('✅ Active Organization ID: ${response.activeOrganizationId}');
var userWithOrg = response.user.copyWith(
  tenantId: response.activeOrganizationId,
);
userWithOrg = await _fetchAndSetBranch(userWithOrg);

// Save user with organization
final prefs = await SharedPreferences.getInstance();
await prefs.setString('current_user', jsonEncode(userWithOrg.toJson()));

state = AuthState.authenticated(user: userWithOrg);
return true;
```

**Step 5: Verify build**

Run: `cd /Users/waiphyoaung/Desktop/NexusPoint/NexusPoint-mobile && flutter build ios --no-codesign --debug 2>&1 | tail -5`
Expected: Build succeeds

**Step 6: Commit**

```bash
cd /Users/waiphyoaung/Desktop/NexusPoint/NexusPoint-mobile
git add lib/features/auth/providers/auth_provider.dart
git commit -m "feat(F-002): fetch and persist branchId during auth login flow"
```

---

## Task 3: Verify Floor Plan Provider Uses Correct branchId

**Files:**
- Verify (no changes needed): `lib/features/floor_plan/providers/floor_plan_provider.dart`

**Context:** The provider at line 19 already does:
```dart
final branchId = user.branchId ?? orgId;
```

With Task 2 complete, `user.branchId` will now be populated with the real branch ID from the API. The floor plan provider will automatically use it — no code change needed here.

**Step 1: Verify by reading the file**

Confirm `floor_plan_provider.dart` line 19 reads `user.branchId ?? orgId`.

**Step 2: Verify the API service passes branchId correctly**

Confirm `api_service.dart` `getFloorPlanTables()` sends `{'branchId': branchId}` to `table.list` tRPC.

**Step 3: Trace data flow end-to-end**

```
Auth login
  → verifyOtp() sets user.tenantId (orgId) ✓
  → _fetchAndSetBranch() sets user.branchId ✓ (NEW)
  → SharedPreferences stores user with branchId ✓

Floor plan opens
  → floorPlanProvider reads user.branchId → "82363b42-..." ✓ (was null before)
  → repo.syncFromApi(orgId, branchId) ✓
  → api.getFloorPlanTables(orgId, "82363b42-...") ✓
  → table.list tRPC returns 10 tables ✓
  → Drift upsertTables() stores locally ✓
  → floorPlanStreamProvider emits tables ✓
  → FloorPlanCanvas renders tables ✓
```

No commit needed — this is verification only.

---

## Task 4: Handle Cached Auth (App Restart Without Re-Login)

**Files:**
- Modify: `lib/features/auth/providers/auth_provider.dart`

**Context:** When the app restarts, `_loadCachedAuth()` loads the user from SharedPreferences. If the user was cached BEFORE this fix (branchId = null), floor plan will still fail. We need to lazily fetch the branch on first floor plan access if branchId is missing.

**Step 1: Add branch-fetch to `_loadCachedAuth` when branchId is null**

Find this method (around line 53-64):
```dart
Future<void> _loadCachedAuth() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('current_user');
  final token = prefs.getString('auth_token');

  if (userJson != null && token != null) {
    final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    state = AuthState.authenticated(user: user);
  }
}
```

Replace with:
```dart
Future<void> _loadCachedAuth() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('current_user');
  final token = prefs.getString('auth_token');

  if (userJson != null && token != null) {
    var user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    state = AuthState.authenticated(user: user);

    // Lazy branch fetch for cached users missing branchId
    if (user.branchId == null && user.tenantId != null) {
      try {
        // Ensure token is available for API calls
        ref.read(authTokenProvider.notifier).setToken(token);
        user = await _fetchAndSetBranch(user);
        if (user.branchId != null) {
          await prefs.setString('current_user', jsonEncode(user.toJson()));
          state = AuthState.authenticated(user: user);
        }
      } catch (e) {
        debugPrint('⚠️ Lazy branch fetch on startup failed: $e');
        // Non-fatal — will retry when floor plan opens
      }
    }
  }
}
```

**Step 2: Verify build**

Run: `cd /Users/waiphyoaung/Desktop/NexusPoint/NexusPoint-mobile && flutter build ios --no-codesign --debug 2>&1 | tail -5`
Expected: Build succeeds

**Step 3: Commit**

```bash
cd /Users/waiphyoaung/Desktop/NexusPoint/NexusPoint-mobile
git add lib/features/auth/providers/auth_provider.dart
git commit -m "fix(F-002): lazy-fetch branchId for cached auth sessions missing branch"
```

---

## Task 5: Deploy API and Verify End-to-End

**Files:**
- No code changes

**Step 1: Ensure the web API has the `table.list` and `branch.list` endpoints deployed**

The API was pushed to main in the web repo. Verify the production API has these tRPC procedures:
- `branch.list` — returns branches for active org (no input needed)
- `table.list` — returns tables for a branch (input: `{branchId}`)
- `table.listWithStatus` — returns lightweight status for polling (input: `{branchId}`)

**Step 2: Ensure seed data exists**

The database should have tables seeded for the `burma-food-house` org, branch `82363b42-6263-4ce1-80f3-d853ed76765e`. If not:

```bash
cd /Users/waiphyoaung/Desktop/NexusPoint/NexusPoint\(web\)
psql "$DATABASE_URL" -f db/scripts/seed-full-demo.sql
```

**Step 3: Run Flutter app on iOS simulator**

```bash
cd /Users/waiphyoaung/Desktop/NexusPoint/NexusPoint-mobile
flutter run
```

**Step 4: Test all 5 acceptance criteria**

| # | Criterion | How to Verify |
|---|-----------|---------------|
| 1 | Visual floor plan with 16 tables | Open Tables tab → see grid with table cards |
| 2 | Real-time status color coding | Green=available, Blue=occupied, Amber=reserved, Gray=cleaning |
| 3 | Tap table → action | Tap available table → "New Dine-In Order" sheet. Tap occupied → "Open Order" sheet |
| 4 | Status sync < 2 seconds | Change table status via web admin → mobile updates within 2 poll cycles |
| 5 | Works offline | Enable airplane mode → tables still visible from Drift cache |

**Step 5: Check console logs for correct branchId**

Expected log output on login:
```
✅ Active Organization ID: cffaeb8c-...
🏪 Fetching branches via tRPC: branch.list
🏪 Auto-selected branch: Main Branch (82363b42-...)
```

Expected log output when floor plan opens:
```
🪑 Fetching floor plan tables via tRPC: table.list
```
(Should NOT see "Floor plan API sync failed" or return 0 tables)

---

## Task 6: Update Spec Tracker

**Files:**
- Modify: `/Users/waiphyoaung/Desktop/NexusPoint/.specify/SPEC-KIT-NEXUSPOINT.md`

**Step 1: Update F-002 acceptance criteria**

Mark the mobile items as verified:
```markdown
**Acceptance criteria (from PRD):**
- [x] 16 tables in configurable grid/layout
- [x] Admin arranges tables via drag-and-drop
- [x] Tables support different shapes
- [x] Real-time status color coding
- [x] Tapping table opens appropriate action
- [x] Status updates sync < 2 seconds online
- [x] Works offline with last-known state
```

**Step 2: Update spec lifecycle**

```markdown
**Spec lifecycle:**
- [x] SPECIFY
- [x] CLARIFY
- [x] PLAN
- [x] TASKS
- [x] IMPLEMENT
- [ ] VERIFY (pending E2E testing)
```

**Step 3: Commit**

```bash
cd /Users/waiphyoaung/Desktop/NexusPoint
git add .specify/SPEC-KIT-NEXUSPOINT.md
git commit -m "docs(F-002): update spec tracker with mobile floor plan completion"
```

---

## Summary

| Task | What | Files | Risk |
|------|------|-------|------|
| 1 | Add `getBranches()` API method | `api_service.dart` | Low — follows existing tRPC pattern |
| 2 | Wire branch fetch into 3 auth paths | `auth_provider.dart` | Medium — touches login flow |
| 3 | Verify data flow (no code change) | `floor_plan_provider.dart` | None — read-only verification |
| 4 | Handle cached auth without branchId | `auth_provider.dart` | Low — non-fatal fallback |
| 5 | Deploy + E2E verification | None | Low — manual testing |
| 6 | Update spec tracker | `SPEC-KIT-NEXUSPOINT.md` | None |

**Total files modified:** 2 (mobile) + 1 (spec tracker)
**Total new files:** 0
**Estimated effort:** 4 tasks × 2-5 min each = ~15 minutes implementation
