# Audit Plan: Fix Supervisor Dashboard Loading

**Feature**: `specs/002-fix-dashboard-loading/`
**Constitution**: `specs/002-fix-dashboard-loading/constitution.md`
**Date**: 2026-05-18
**Status**: Implementation complete — awaiting approval review

---

## 1. Repo Call Audit

All calls are inside `SupervisorDashboardCubit.loadDashboard()`.

| # | Method | Return type | Mode |
|---|--------|-------------|------|
| 1 | `repo.fetchActiveUnitsCount()` | `Future<int>` | PARALLEL |
| 2 | `repo.fetchCompletedTasksTodayCount()` | `Future<int>` | PARALLEL |
| 3 | `repo.fetchDelayedTasksCount()` | `Future<int>` | PARALLEL |
| 4 | `repo.fetchReportsTodayCount()` | `Future<int>` | PARALLEL |
| 5 | `repo.fetchTodaysTasksForSummary()` | `Future<List<Map<String,dynamic>>>` | PARALLEL |

All 5 are dispatched simultaneously via `Future.wait<dynamic>([...])`. Each is individually wrapped in `_safeCall<T>()` so a single failure does not abort the others.

No sequential calls exist in the cubit. `_buildSummary()` and `_dominantError()` are pure Dart — no I/O.

---

## 2. Constitution Compliance

| Rule | Pass? | Notes |
|------|-------|-------|
| `_safeCall<T>()` + `Future.wait` for all independent queries | ✅ | All 5 queries |
| State fields nullable per metric | ✅ | `DashboardStatsModel` fields are `int?` |
| `sessionExpired` status → UI redirects via `AuthCubit.logout()` | ✅ | `BlocListener` in screen |
| Never access Supabase directly — always through repo | ✅ | Only `SupervisorDashboardRepo` touched |
| CLAUDE.md error handling pattern exactly | ✅ | `on AppError` first, then `catch (_)` → `AppError.unknown()` |

---

## 3. Findings

### Finding A — All constitution rules satisfied

The current cubit implementation meets every rule in the constitution. No violations.

### Finding B — Pull-to-refresh uses correct terminal predicate

The screen's `onRefresh` awaits:
```dart
stream.firstWhere((s) => s.status != DashboardStatus.loading)
      .timeout(const Duration(seconds: 12), onTimeout: () => state)
```
This terminates on `success`, `failure`, and `sessionExpired` — any non-loading state. The 12-second timeout ensures the indicator never hangs.

### Finding C — Session-expiry redirect path is correct

`BlocConsumer.listener` calls `context.read<AuthCubit>().logout()` when `sessionExpired` is emitted. `AuthCubit.logout()` emits `AuthUnauthenticated` → `UserAuthenticatedCheck` routes to login. No broken dashboard is left on screen.

### Finding D — Partial data path is correct

When only some queries fail, `DashboardStatsModel` is built with `null` for failed fields, `success` status is still emitted, and the stat grid shows `'—'` for null fields via the double null-safe access (`stats?.field?.toString() ?? '—'`). The full-screen error body only appears when ALL 5 queries fail (`errors.length == 5`).

### Finding E — One subtle gap: `hasData` does not distinguish partial data

`SupervisorDashboardState.hasData` returns `stats != null && taskSummary != null`. In the partial-failure path, `stats` is always set (even with all-null fields) and `taskSummary` falls back to `TaskStatusSummaryModel(total:0, ...)` (not null). So `hasData` is always `true` after any successful path — the full-screen error body is never shown alongside partial data. **This is the intended behaviour**, but it means a supervisor with all-null stats sees an empty stat grid with no explicit "some data unavailable" indicator at the grid level.

---

## 4. Exact Changes Needed

Based on the audit, the implementation is **complete and correct** against every constitution rule.

The only optional improvement (not a constitution violation) is Finding E:

### Optional — Per-field unavailable indicator in stat grid

**File**: `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart`

**Current**: Stat cards that have a `null` field value show `'—'` text. No visual distinction from a card that simply loaded `0`.

**Proposed**: Add a subtle warning icon or muted colour to the `'—'` state so supervisors know the value is unavailable rather than genuinely zero.

```dart
// Current _StatCard value branch:
value == '—'
    ? Text('—', style: ...)
    : Text(value, ...).animate(...)

// Proposed addition — icon alongside '—':
value == '—'
    ? Row(children: [
        Text('—', style: ...),
        horizontalSpacing(4),
        Icon(Icons.info_outline_rounded, size: rf(12), color: cc.textHint),
      ])
    : Text(value, ...).animate(...)
```

**Priority**: Low — not required by constitution; purely a UX improvement.
**Requires approval before implementation.**

---

## 5. Files Affected by Optional Change

| File | Change |
|------|--------|
| `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart` | Add info icon alongside `'—'` in `_StatCard` |

No other files need changes. All constitution rules are already satisfied by the current implementation.
