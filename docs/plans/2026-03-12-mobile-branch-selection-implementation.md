# Mobile Branch Selection Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add branch selection screen after login to fix floor plan not reflecting on mobile when branchId is missing or wrong.

**Architecture:** Extend `AuthState` freezed sealed union with `branchPending(user, branches)` variant. AuthGate pattern-matches all three states. BranchSelectionScreen renders as mandatory picker. Branch name badge in nav rail. Switch branch from settings trailing section.

**Tech Stack:** Flutter 3.19+, Riverpod 2.4+ (StateNotifierProvider), Freezed (sealed unions), SharedPreferences (cache), Drift (floor plan clear on switch)

**Design doc:** `docs/plans/2026-03-12-mobile-branch-selection-design.md`
**Spec kit:** `.specify/specs/002-branch-selection-mobile/`

---

## Pre-Implementation Checklist

- [x] Design validated with user (A: branch picker after login, auto-skip single branch, card list, switchable from settings, badge in nav rail)
- [x] Backend API verified — `branch.list` tRPC endpoint already exists, returns `BranchDto[]`
- [x] No backend changes needed
- [x] Spec written (`.specify/specs/002-branch-selection-mobile/spec.md`)
- [x] Plan written (`.specify/specs/002-branch-selection-mobile/plan.md`)
- [x] Tasks written (`.specify/specs/002-branch-selection-mobile/tasks.md`)

---

## Tasks Summary

Full task details with step-by-step code in `.specify/specs/002-branch-selection-mobile/tasks.md`.

| # | Task | Files | Key Change |
|---|------|-------|------------|
| 1 | Add `branchPending` to AuthState | `auth_provider.dart` | New freezed variant + build_runner |
| 2 | Update AuthNotifier | `auth_provider.dart` | `selectBranch()`, `switchBranch()`, refactor `_fetchAndSetBranch` |
| 3 | Create BranchSelectionScreen | `branch_selection_screen.dart` (new) | Card list UI with staggered animations |
| 4 | Update AuthGate | `main.dart` | Handle 3 states in `.when()` |
| 5 | Branch name badge | `pos_shell.dart`, `current_branch_provider.dart` (new) | Badge in nav rail header |
| 6 | Switch branch button | `pos_shell.dart` | Confirmation dialog + switchBranch() |
| 7 | Remove branchId fallback | `floor_plan_provider.dart` | Error instead of `?? orgId` |
| 8 | Cache branch list | `auth_provider.dart` | Persist to SharedPreferences |
| 9 | Tests | `auth_state_test.dart`, `branch_selection_screen_test.dart` (new) | Unit + widget tests |
| 10 | Cleanup | `auth_provider.dart` | print → debugPrint, final verify |

**10 tasks, ~51 minutes, 10 commits**

---

## Execution Options

**1. Subagent-Driven (this session)** — Dispatch fresh subagent per task, review between tasks, fast iteration.

**2. Parallel Session (separate)** — Open new session in worktree with `superpowers:executing-plans`, batch execution with checkpoints.
