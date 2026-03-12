# Mobile Branch Selection — Design Document

**Feature:** Branch Selection After Login
**Related Specs:** F-002 (Floor Plan), F-003 (Enhanced Order Creation), F-009 (Roles)
**Created:** 2026-03-12
**Status:** Design Complete

---

## Problem

Floor plan doesn't reflect on mobile because `user.branchId` is unreliable:
- Current flow auto-selects `branches.first` with no user input
- If the auto-select fails or picks wrong branch, floor plan shows "No tables configured"
- Users with multiple branches have no way to choose which one to operate
- Web had the same bug (fixed with `useBranchAutoSelect` hook in 4 commits)

## Solution

Add a **branch selection screen** between login and POS Shell when the user has multiple branches.

---

## Flow

```
Email + OTP → Auth Success → Fetch branches
  ├─ 1 branch  → auto-select → POS Shell (no change)
  └─ 2+ branches → BranchSelectionScreen → user picks → POS Shell
```

### Auth State Machine

```
┌──────────────────┐
│  unauthenticated │ ← initial / logout / token expired
└────────┬─────────┘
         │ verifyOtp() success
         ▼
┌──────────────────┐
│  branchPending   │ ← NEW: user verified, 2+ branches, no selection yet
│  (user, branches)│
└────────┬─────────┘
         │ selectBranch(branchId)
         ▼
┌──────────────────┐
│  authenticated   │ ← user + branchId set, POS ready
│  (user, attempts)│
└──────────────────┘
```

Single-branch users skip `branchPending` entirely — `verifyOtp()` auto-selects and goes straight to `authenticated`.

---

## BranchSelectionScreen UI

- **Full screen, no back button** — selection is mandatory
- **Top:** NexusPoint logo + "Select your branch" heading
- **Body:** Scrollable list of branch cards
- **Each card:** branch name (bold), address (subtitle, muted), green active dot
- **Tap card** → sets branch → transitions to POS Shell
- **Dark theme** matching existing `PosTheme`
- **Staggered fade-in** animation per card
- **Scale + check** animation on selection before transition

---

## Navigation Rail Branch Badge

- **Location:** top of `PosShell` nav rail, above first tab icon
- **Display:** branch name in a subtle background pill (truncated ~12 chars)
- **Read-only** — tapping does nothing
- **Purpose:** staff always know which branch they're operating on

---

## Branch Switching (Settings)

- "Branch" row in profile/settings showing current branch name
- Tap → confirmation dialog: "Switch branch? This will reload your data."
- On confirm:
  - Clear cart, active order draft, floor plan cache
  - Re-fetch branches
  - Set state to `branchPending`
  - User picks new branch

---

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Cached login with `branchId` | Straight to `authenticated`, no API call |
| Cached login without `branchId` (migration) | Fetch branches → auto-select or `branchPending` |
| Offline at login | OTP requires network; branches fetch at same time |
| Branch fetch fails after OTP | Error toast + retry button on loading screen |
| Branch deleted after selection | Floor plan returns error → reset to `branchPending` |
| Cart data on branch switch | Clear with confirmation dialog |

---

## Files

### New

| File | Purpose |
|------|---------|
| `lib/features/auth/widgets/branch_selection_screen.dart` | Branch picker screen |
| `lib/core/providers/current_branch_provider.dart` | Derives branch name from branchId |
| `test/features/auth/branch_selection_test.dart` | Widget tests |

### Modified

| File | Change |
|------|--------|
| `lib/features/auth/providers/auth_provider.dart` | Add `branchPending` state, `selectBranch()`, `switchBranch()`, update `_loadCachedAuth()` |
| `lib/main.dart` | `AuthGate` handles `branchPending` → `BranchSelectionScreen` |
| `lib/features/shell/pos_shell.dart` | Branch name badge in nav rail header |
| `lib/features/floor_plan/providers/floor_plan_provider.dart` | Remove `?? orgId` fallback (branchId now guaranteed) |

### Unchanged

| File | Reason |
|------|--------|
| `lib/core/api/api_service.dart` | `getBranches()` already exists |
| `lib/core/models/branch_dto.dart` | Model already has name, address, isActive |
| `lib/core/models/user.dart` | `branchId` field already exists |
| Floor plan repo/screen/canvas | Already use `user.branchId` correctly |
| Drift schema | No new tables needed |

---

## Spec Kit Alignment

- **F-002:** Directly fixes "floor plan not reflecting" — guarantees `branchId` before any screen loads
- **F-003:** Orders need `branchId` for dine-in table linking — unblocked by this change
- **F-009:** Branch selection screen is future home for role display when expanding to 5 roles
- **Web parity:** Mirrors web's `useBranchAutoSelect` but cleaner — explicit state eliminates race conditions
