# Tasks: Supervisor Dashboard Loading Failure Recovery

**Input**: Design documents from `specs/002-fix-dashboard-loading/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅

**Tests**: Not requested — validation is done via `flutter analyze` and manual smoke-test checklist.

**Organization**: Tasks are grouped by user story. Phases 1–2 are foundational and block all user-story phases.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1–US4 maps to spec.md user story priorities
- All tasks include exact file paths

---

## Phase 1: Foundational — Type & State Changes

**Purpose**: Data model and state enum changes that MUST exist before any cubit or UI work can compile.

**⚠️ CRITICAL**: Both tasks are independent of each other ([P]) but BLOCK all subsequent phases.

- [X] T001 [P] Change all four stat fields in `DashboardStatsModel` from `required int` to `int?` in `lib/modules/supervisor/features/dashboard/data/models/dashboard_stats_model.dart`
- [X] T002 [P] Add `sessionExpired` value to the `DashboardStatus` enum in `lib/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_state.dart`

**Checkpoint**: T001 and T002 complete → model and state compile; proceed to cubit overhaul.

---

## Phase 2: Foundational — Cubit Overhaul

**Purpose**: Replace `Future.wait` with settled parallel calls and add concurrency guard. MUST be complete before any UI story can be tested end-to-end.

**⚠️ CRITICAL**: No UI story is testable until this phase is complete.

- [X] T003 Add private `_safeCall<T>()` helper method to `SupervisorDashboardCubit` in `lib/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_cubit.dart` — method signature: `Future<(T?, AppError?)> _safeCall<T>(Future<T> Function() fn)` wrapping the call in try-catch (catch AppError, then catch all → AppError.unknown())
- [X] T004 Add concurrency guard at the top of `loadDashboard()` in `lib/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_cubit.dart` — add `if (state.status == DashboardStatus.loading) return;` as the first line of the method body
- [X] T005 Rewrite `loadDashboard()` body in `lib/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_cubit.dart` — replace the single `Future.wait([...])` try-catch block with: (1) run all 5 queries via `await Future.wait([_safeCall(...), ...])` collecting `(T?, AppError?)` records; (2) after settlement, if any error has `type == ErrorType.unauthorized || type == ErrorType.forbidden`, emit `DashboardStatus.sessionExpired` and return; (3) build `DashboardStatsModel` with nullable field values from the settled results (null where that query failed); (4) build `TaskStatusSummaryModel` from settled task-summary result (null result → `TaskStatusSummaryModel(total:0, done:0, inProgress:0, delayed:0)`); (5) if at least one query succeeded, emit `DashboardStatus.success` with partial model; (6) if all queries failed, emit `DashboardStatus.failure` with dominant error (noInternet > internalServer > unknown priority)

**Checkpoint**: T003–T005 complete → cubit resolves independently per query, emits sessionExpired for auth errors, emits success with partial data, emits failure only on total failure.

---

## Phase 3: User Story 1 — Reliable Dashboard Load (Priority: P1) 🎯 MVP

**Goal**: Dashboard always resolves to a terminal state (data or error) within 15 seconds; retry is available on failure; pull-to-refresh always dismisses.

**Independent Test**: Kill network before opening dashboard → error card with Retry button appears (no indefinite spinner). Pull-to-refresh while offline → indicator dismisses within 15 seconds.

### Implementation for User Story 1

- [X] T006 [US1] Fix `onRefresh` callback in `lib/modules/supervisor/features/dashboard/ui/supervisor_dashboard_screen.dart` — inside `_DashboardBody.build`, update the `RefreshIndicator.onRefresh` lambda to: (1) call `context.read<SupervisorDashboardCubit>().refresh()` (no await), (2) await `context.read<SupervisorDashboardCubit>().stream.firstWhere((s) => s.status != DashboardStatus.loading).timeout(const Duration(seconds: 12), onTimeout: () => state)` where `state` is the current `SupervisorDashboardState` from the builder closure

**Checkpoint**: US1 complete — pull-to-refresh always terminates; no indefinite spinner.

---

## Phase 4: User Story 2 — Session Expiry Redirect (Priority: P1)

**Goal**: When any dashboard query fails with an auth/session error, the app navigates to login with a session-expired explanation — never leaves supervisor on a broken dashboard.

**Independent Test**: Expire the session token manually → open or refresh dashboard → app navigates to login screen (no broken error card, no spinner).

### Implementation for User Story 2

- [X] T007 [US2] Update the `BlocConsumer<SupervisorDashboardCubit>` listener in `lib/modules/supervisor/features/dashboard/ui/supervisor_dashboard_screen.dart` — in the `listener` callback (currently empty `(context, state) {}`), add: `if (state.status == DashboardStatus.sessionExpired) { context.read<AuthCubit>().logout(); }`

**Checkpoint**: US2 complete — session expiry triggers `AuthCubit.logout()` which emits `AuthUnauthenticated` → `UserAuthenticatedCheck` routes to login.

---

## Phase 5: User Story 3 — Partial Data Display (Priority: P2)

**Goal**: When some queries succeed and others fail, the dashboard shows live data for successful sections and a neutral `'—'` placeholder for failed ones — not a full-screen error.

**Independent Test**: Restrict read access on the `reports` table via Supabase RLS → open dashboard → three stat cards show numbers, "Reports Today" card shows `'—'`, task progress bar shows data (or empty state if that query also failed). No full-screen error card.

### Implementation for User Story 3

- [X] T008 [US3] Update `SupervisorStatsGrid` in `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart` — change all four stat card `value:` expressions from `stats?.field.toString() ?? '—'` to `stats?.field?.toString() ?? '—'` (double null-safe access is required because the fields are now `int?` — `stats` can be null during loading AND individual fields can be null on partial failure)

**Checkpoint**: US3 complete — partial failure shows per-field `'—'` without full-screen error regression.

---

## Phase 6: User Story 4 — Informative Error Messages (Priority: P3)

**Goal**: The full-screen error card shows a human-readable, localized message matching the failure type (network, permission, server, unknown) — not a raw key string or empty text.

**Independent Test**: Simulate no-internet → error card reads "You're offline. Check your WiFi or mobile data." Simulate permission error → reads "You don't have permission to do this." Both in English and Arabic.

### Implementation for User Story 4

- [X] T009 [US4] Verify and fix error message display in `lib/modules/supervisor/features/dashboard/ui/supervisor_dashboard_screen.dart` — in `_DashboardErrorBody.build`, check the `Text` widget displaying `message`: if it uses `message` directly (without `.tr()`), change to `Text(message.isNotEmpty ? message.tr() : 'errors.unknown'.tr())` so the `messageKey` from `AppError` is translated to the current app locale before display

**Checkpoint**: US4 complete — all four error types show distinct, localized, human-readable messages.

---

## Phase 7: Polish & Validation

**Purpose**: Static analysis and end-to-end smoke verification across all user stories.

- [X] T010 Run `flutter analyze` from the project root and confirm zero issues — fix any type errors introduced by the `int?` field change (e.g., callers that pass `int` to a now-nullable field)
- [ ] T011 [P] MANUAL — Smoke-test US1: launch app with valid session as supervisor → all four stat cards display numbers within 5 seconds
- [ ] T012 [P] MANUAL — Smoke-test US1 error path: disable network → open dashboard → error card with "Retry" button appears; no spinner persists; tap Retry → same error card (no crash)
- [ ] T013 [P] MANUAL — Smoke-test US1 pull-to-refresh: pull-to-refresh while offline → `RefreshIndicator` dismisses cleanly
- [ ] T014 [P] MANUAL — Smoke-test US2: expire session token (e.g., clear Supabase auth storage) → open dashboard → app navigates to login screen
- [ ] T015 [P] MANUAL — Smoke-test US3: if possible to test partial failure (RLS restriction on one table) → verify stat card shows `'—'` while others show data
- [ ] T016 [P] MANUAL — Smoke-test US4: verify each error message is human-readable and matches the `errors.*` localization values in both `en.json` and `ar.json`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** (T001, T002): No dependencies — can start immediately; run in parallel
- **Phase 2** (T003–T005): Depends on Phase 1 completion (needs `int?` fields and `sessionExpired` enum value)
- **Phase 3** (T006): Depends on Phase 2 (cubit must emit `sessionExpired` for predicate to matter; `!= loading` predicate is safe before Phase 2 but meaningless)
- **Phase 4** (T007): Depends on T002 (`sessionExpired` enum) and Phase 2 (cubit emits it)
- **Phase 5** (T008): Depends on T001 (`int?` fields) and Phase 2 (cubit builds partial model)
- **Phase 6** (T009): Depends on Phase 2 (cubit sets correct error types)
- **Phase 7** (T010–T016): Depends on all prior phases complete

### Within-Phase Dependencies

- T003 → T004 → T005 (sequential — all in same method of same file)
- T006 and T007 touch the same file (`supervisor_dashboard_screen.dart`) — run sequentially
- T011–T016 are independent smoke tests — all [P]

### Parallel Opportunities

- T001 ‖ T002 (different files)
- T006 → T007 sequential (same file — `supervisor_dashboard_screen.dart`)
- T008 is independent of T006/T007 (different file — `supervisor_status_grid.dart`)
- T009 must come after T007 (same file — complete T007 edits first)
- T011–T016 all [P]

---

## Parallel Example: Phase 1

```
Run simultaneously (different files, no shared dependencies):
  T001 — dashboard_stats_model.dart  (int → int?)
  T002 — supervisor_dashboard_state.dart  (add sessionExpired)
```

## Parallel Example: Phase 7 Smoke Tests

```
After T010 passes (flutter analyze clean), run simultaneously:
  T011 — valid session load
  T012 — no-internet error path
  T013 — pull-to-refresh dismissal
  T014 — session expiry redirect
  T015 — partial failure display
  T016 — localized error messages
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 — both P1)

1. Complete Phase 1: T001, T002 in parallel
2. Complete Phase 2: T003 → T004 → T005 sequentially
3. Complete Phase 3: T006 (pull-to-refresh fix)
4. Complete Phase 4: T007 (session expiry redirect)
5. **STOP and VALIDATE**: Run `flutter analyze` → smoke-test US1 and US2
6. Ship fix — supervisors no longer get stuck on broken dashboard

### Full Delivery (All 4 User Stories)

1. MVP scope (Phases 1–4) — validates independently
2. Add Phase 5 (T008) → partial data display → test US3
3. Add Phase 6 (T009) → error message localization → test US4
4. Phase 7 full smoke test → release

---

## Notes

- 5 files changed total; no new routes, DI registrations, or localization keys
- `DashboardStatsModel` field change (`int → int?`) may produce analyzer warnings in callers that expect non-null — T010 catches these
- The `_safeCall<T>()` return type uses a Dart 3 record `(T?, AppError?)` — requires Dart 3.x (already in use)
- `AuthCubit.logout()` in T007 already handles clearing auth state and emitting `AuthUnauthenticated`; no new logout infrastructure needed
- `context.read<AuthCubit>()` in `_DashboardBody` is safe because `AuthCubit` is provided at app root via `MultiBlocProvider` in `UserAuthenticatedCheck`
