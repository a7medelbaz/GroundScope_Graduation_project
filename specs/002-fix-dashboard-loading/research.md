# Research: Supervisor Dashboard Loading Failure Recovery

## Root Cause Analysis (from codebase inspection)

### Finding 1 — All-or-Nothing `Future.wait`

**Problem**: `SupervisorDashboardCubit.loadDashboard()` runs all 5 queries via `Future.wait(...)`. If any single query throws, `Future.wait` rethrows immediately and the entire dashboard shows a failure state. One broken RLS policy on `reports` kills all four stat cards.

**Decision**: Replace `Future.wait` with individual settled calls — a private `_safeCall<T>()` helper wraps each query in a try-catch and returns a `(T? value, AppError? error)` record. Each section resolves independently regardless of other sections' outcomes.

**Rationale**: Settled async calls are the standard pattern for independent parallel operations where partial success is preferable to total failure. Dart 3 records (`(T?, AppError?)`) make this concise without a third-party `Result` type.

**Alternatives considered**:
- `Future.wait(eagerError: false)` — still throws at the end if any future fails; returns a `List<dynamic>` where individual errors are lost; rejected.
- Third-party `Result<T, E>` package — unnecessary dependency for this pattern; rejected.

---

### Finding 2 — No Session-Expiry Detection in Data Layer

**Problem**: When a Supabase JWT expires, queries throw `AuthException` with "session/token/expired" in the message. `SupabaseErrorHandler` correctly classifies this as `ErrorType.unauthorized` with key `errors.session_expired`. However, the cubit just emits a `failure` state — the UI shows an error card. The supervisor must manually restart the app.

**Decision**: After `_safeCall()` collects all results, check if any error has `isAuthError == true` (`ErrorType.unauthorized` or `ErrorType.forbidden`). If yes, emit `DashboardStatus.sessionExpired`. The UI's `BlocListener` catches this status, calls `context.read<AuthCubit>().logout()` (which emits `AuthUnauthenticated`), and `UserAuthenticatedCheck` routes to the login screen. The session-expired error message from `AppError.messageKey` (`errors.session_expired`) is passed as a navigation argument so the login screen can display it.

**Rationale**: The existing `AuthCubit.logout()` already clears all auth state and emits `AuthUnauthenticated`, which `UserAuthenticatedCheck` watches to navigate to login. No new logout infrastructure is needed — just detection and delegation.

**Alternatives considered**:
- Listening to Supabase auth stream in the cubit — would create a dependency between the data layer and Supabase auth events; rejected in favor of error-state detection.
- Adding a global interceptor — out of scope; rejected.

---

### Finding 3 — No Concurrency Guard on `loadDashboard()`

**Problem**: If the user taps Retry rapidly or swipes pull-to-refresh during a load already in progress, multiple concurrent `loadDashboard()` calls race. The last one to complete wins, which could be a stale request from earlier.

**Decision**: Guard at the top of `loadDashboard()`: `if (state.status == DashboardStatus.loading) return;`. Simple, zero overhead.

**Rationale**: Cubit state is the single source of truth for load status; checking it is the idiomatic BLoC guard pattern. No debouncer timer needed.

---

### Finding 4 — Pull-to-Refresh Can Hang on `sessionExpired`

**Problem**: `_DashboardBody.onRefresh` awaits `stream.firstWhere((s) => s.status == success || s.status == failure)`. If the cubit emits `sessionExpired` (a new status), `firstWhere` never satisfies its predicate and the refresh indicator hangs indefinitely. Additionally, there is no timeout — a network failure that silently swallows could hang forever.

**Decision**: Broaden the `firstWhere` predicate to `s.status != DashboardStatus.loading`, which catches success, failure, and sessionExpired. Additionally, chain `.timeout(const Duration(seconds: 12), onTimeout: () => state)` so the indicator always dismisses within 12 seconds even if the stream stalls.

**Rationale**: `!= loading` is more robust than listing every terminal status — new statuses won't cause regressions.

---

### Finding 5 — `DashboardStatsModel` Fields Are Non-Nullable

**Problem**: Each stat field (`activeUnits`, `completedTasksToday`, `delayedTasks`, `reportsToday`) is `required int`. With partial failure handling, some fields may be unknown (query failed). The current model cannot represent "this specific count is unavailable."

**Decision**: Change all four fields to `int?`. The stat grid widget already shows `'—'` when `stats == null` — that logic extends to per-field nulls by checking each field individually. `DashboardStatsModel` becomes the natural carrier of partial results.

**Rationale**: Nullable fields on the model propagate cleanly through the state → widget path without adding intermediate wrapper types. The existing `'—'` fallback in `_StatCard` already handles the display.

---

### Finding 6 — Error Message Strings Are Already Complete

**Decision**: No new localization keys are required. The existing `errors.*` namespace covers all failure types:

| Error type | `AppError.type` | `errors.*` key | en.json value |
|------------|----------------|----------------|---------------|
| No internet | `noInternet` | `errors.no_internet` | "You're offline. Check your WiFi or mobile data." |
| Session expired | `unauthorized` | `errors.session_expired` | "Your session expired. Please log in again." |
| Permission denied | `forbidden` | `errors.permission_denied` | "You don't have permission to do this." |
| Server error | `internalServer` | `errors.server_error` | "Something went wrong on our end. Try again in a moment." |
| Unknown | `unknown` | `errors.unknown` | "Something unexpected happened. Please try again." |

The dashboard error widget already uses `state.error?.messageKey` directly. No changes needed to the localization layer.

---

### Finding 7 — Dominant Error for Full-Screen Display

**Problem**: With partial failures, which error does the full-screen error card show when multiple queries fail?

**Decision**: Use the "dominant" error: prefer `noInternet` > `unauthorized` / `forbidden` (triggers redirect) > `internalServer` > `unknown`. In practice, if the device is offline, all queries fail with the same `noInternet` error. When queries fail with mixed errors, show the highest-severity non-auth error. If all errors are auth errors, the session-expired path takes over and no error card is shown at all.

---

## Model Change Summary

`DashboardStatsModel` (`lib/modules/supervisor/features/dashboard/data/models/dashboard_stats_model.dart`):

| Field | Before | After |
|-------|--------|-------|
| `activeUnits` | `required int` | `int?` |
| `completedTasksToday` | `required int` | `int?` |
| `delayedTasks` | `required int` | `int?` |
| `reportsToday` | `required int` | `int?` |

All changes are backward-compatible at the UI layer — the existing `'—'` display path activates on `null`.

---

## Files Affected

| File | Change |
|------|--------|
| `lib/modules/supervisor/features/dashboard/data/models/dashboard_stats_model.dart` | Nullable fields |
| `lib/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_cubit.dart` | `_safeCall`, concurrency guard, session detection |
| `lib/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_state.dart` | Add `sessionExpired` status |
| `lib/modules/supervisor/features/dashboard/ui/supervisor_dashboard_screen.dart` | BlocListener for sessionExpired, pull-to-refresh fix |
| `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart` | Per-field null handling in stat cards |

No new routes, DI registrations, or localization keys are required.
