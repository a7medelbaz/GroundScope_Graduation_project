---
description: "Task list for Supervisor Dashboard Overhaul"
---
# Tasks: Supervisor Dashboard Overhaul

**Input**: Design documents from `specs/001-supervisor-dashboard-overhaul/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ ✅

**Tests**: Not explicitly requested — test tasks omitted. Run `make test` after each phase.

**Organization**: Tasks are grouped by user story to enable independent implementation
and testing of each story. US1 and US2 share the same cubit and are combined in Phase 3.

---

## Format: `[ID] [P?] [Story?] Description — file path`

- **[P]**: Can run in parallel (different files, no cross-dependency on incomplete tasks)
- **[Story]**: Maps to user story in spec.md (US1–US5)
- File paths are repo-relative from `lib/`

---

## Phase 1: Setup (New Models)

**Purpose**: Create the new data models that all subsequent phases depend on.

- [X] T001 Create `DashboardStatsModel` (activeUnits, completedTasksToday, delayedTasks, reportsToday) and `TaskStatusSummaryModel` (total, done, inProgress, delayed, computed donePct/inProgressPct/delayedPct, isEmpty getter) as a single file — `lib/modules/supervisor/features/dashboard/data/models/dashboard_stats_model.dart`
- [X] T002 [P] Create `TaskAssignmentInput` DTO (flightId, serviceTypeId, unitId, priority, scheduledStart, scheduledEnd, notes) with validation rules from data-model.md — `lib/modules/supervisor/features/dashboard/data/models/task_assignment_input.dart`
- [X] T003 [P] Add all `supervisor_dashboard.*` localization keys to `assets/lang/en.json` (English values — see plan.md §Localization Keys for full key list including: active_units, completed_tasks, delayed_tasks, reports_today, live_task_summary, live_updates, done, in_progress, delayed, no_tasks_today, quick_actions, assign_task, assign_task_title, select_flight, select_service_type, select_unit, priority, start_time, end_time, notes_optional, submit, reset, task_assigned_success, no_upcoming_flights, end_after_start_error, retry, delete_report_confirm, delete_report_confirm_body, delete, cancel, report_deleted_success, delete_failed)
- [X] T004 [P] Add all `supervisor_dashboard.*` localization keys to `assets/lang/ar.json` (Arabic translations matching the same keys as T003)

---

## Phase 2: Foundational (Data Layer — Blocks All User Stories)

**Purpose**: Build the complete data access layer before any cubit or UI work begins.

**⚠️ CRITICAL**: No cubit or UI work can begin until this phase is complete.

- [X] T005 Create `SupervisorDashboardRemoteDs` with all 9 Supabase query methods per `contracts/supervisor-dashboard-api.md`: `fetchActiveUnitsCount()`, `fetchCompletedTasksTodayCount()`, `fetchDelayedTasksCount()`, `fetchReportsTodayCount()`, `fetchTodaysTasksForSummary()`, `fetchUpcomingFlights()`, `fetchAllActiveUnits()`, `fetchAllServiceTypes()`, `assignTask(TaskAssignmentInput, String assignedBy)`. All methods wrap calls in try/catch and throw `ErrorHandler.handle(e)` — `lib/modules/supervisor/features/dashboard/data/remote/supervisor_dashboard_remote_ds.dart`
- [X] T006 [P] Create `SupervisorDashboardRepo` abstract interface declaring all 9 method signatures matching `SupervisorDashboardRemoteDs` — `lib/modules/supervisor/features/dashboard/data/repo/supervisor_dashboard_repo.dart`
- [X] T007 Create `SupervisorDashboardRepoImpl` implementing `SupervisorDashboardRepo`, delegating to `SupervisorDashboardRemoteDs` (depends on T005 and T006) — `lib/modules/supervisor/features/dashboard/data/repo/supervisor_dashboard_repo_impl.dart`
- [X] T008 [P] Add `fetchAllReports()` (returns `List<ReportModel>` ordered by `created_at` DESC) and `deleteReport(String id)` (DELETE where id = eq.id) to the existing `ReportRemoteDs` — `lib/core/shared/data/remote/report_remote_ds.dart`
- [X] T009 [P] Add `fetchAllReports()` and `deleteReport(String id)` method signatures to the existing `ReportRepo` abstract interface — `lib/core/shared/data/repo/report_repo.dart`
- [X] T010 Implement `fetchAllReports()` and `deleteReport(String id)` in `ReportRepoImpl` (depends on T008 and T009) — `lib/core/shared/data/repo/report_repo_impl.dart`
- [X] T011 Register `SupervisorDashboardRemoteDs` (lazySingleton) and `SupervisorDashboardRepo` / `SupervisorDashboardRepoImpl` (lazySingleton) in DI. Add import statements. Note: cubit registrations for `SupervisorDashboardCubit` and `SupervisorReportsCubit` are added in T013 and T021 respectively — `lib/core/di/dependency_injection.dart`

**Checkpoint**: Foundation complete — all data layer classes exist and compile. Cubit work can begin.

---

## Phase 3: User Stories 1 & 2 — Dashboard Stats & Live Task Summary (Priority: P1) 🎯 MVP

**Goal**: Stats Grid and Live Task Summary show real Supabase data with shimmer loading, error state with retry, and functional pull-to-refresh.

**Independent Test**: Open the Supervisor Dashboard tab → verify stat cards show numbers matching Supabase `units`, `tasks`, and `reports` table counts; pull to refresh → counts update; disable network → error card with retry button appears.

### Implementation for US1 + US2

- [X] T012 [US1] Create `SupervisorDashboardCubit` with `loadDashboard()` (fetches stats + task summary via `Future.wait`, emits loading → success/failure) and `refresh()` (alias for loadDashboard). State class declared as `part of` this file: `DashboardStatus` enum (initial, loading, success, failure), `DashboardStatsModel? stats`, `TaskStatusSummaryModel? taskSummary`, `AppError? error` — `lib/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_cubit.dart`
- [X] T013 [P][US1] Update `supervisor_scaffold.dart`: (a) wrap all tab screens in `MultiBlocProvider` adding `BlocProvider<SupervisorDashboardCubit>(create: (_) => getIt<SupervisorDashboardCubit>()..loadDashboard())`; (b) expose `_controller` for child tab-switching by introducing a thin `SupervisorBottomNavCubit` (new file: `lib/modules/supervisor/core/main_navigation/cubit/supervisor_bottom_nav_cubit.dart`, state = `int tabIndex`, method `jumpTo(int)`) — provide it at scaffold level so any child can call `context.read<SupervisorBottomNavCubit>().jumpTo(index)`; (c) **append** `getIt.registerFactory<SupervisorDashboardCubit>(() => SupervisorDashboardCubit(repo: getIt<SupervisorDashboardRepo>()))` to `dependency_injection.dart` — **append only**, do not overwrite T011's DS/Repo registrations — `lib/modules/supervisor/core/main_navigation/supervisor_scaffold.dart`
- [X] T014 [US1] Update `supervisor_dashboard_screen.dart`: wrap `_DashboardBody` in `BlocConsumer<SupervisorDashboardCubit, SupervisorDashboardState>`. On `loading` → render `_DashboardSkeleton` (shimmer list). On `failure` → render inline `_DashboardErrorCard` with retry button calling `cubit.loadDashboard()`. On `success` → render existing `_DashboardBody`. Update `RefreshIndicator.onRefresh` to call `context.read<SupervisorDashboardCubit>().refresh()` and await state change instead of `Future.delayed` — `lib/modules/supervisor/features/dashboard/ui/supervisor_dashboard_screen.dart`
- [X] T015 [US1] Update `supervisor_status_grid.dart`: read `state.stats` from `context.read<SupervisorDashboardCubit>()`. Replace hardcoded `'4'` values with live counts (activeUnits, completedTasksToday, delayedTasks, reportsToday). Show `'—'` when stats is null (error). Add production-quality `_StatCardSkeleton` widget that exactly mirrors `_StatCard` padding, border radius, and icon placeholder shape, animated with `flutter_animate`'s `.shimmer(duration: 1200.ms)` on a `Container` with the same `BoxDecoration` as the real card. Navigation: **"Reports Today" `onTap`** → `context.read<SupervisorBottomNavCubit>().jumpTo(1)` to switch to the Reports tab (index 1 in PersistentTabView — confirmed in `supervisor_scaffold.dart`); **do NOT use `pushNamed`** for this card. **"Active Units" `onTap`** → units tab does not exist yet in the current scaffold — disable tap or show `context.showInfoSnackBar('supervisor_dashboard.active_units_coming_soon'.tr())` (add this key to en.json/ar.json). **Compliance**: all colours via `CustomColors`/`AppColors` tokens — no inline `Color(...)` literals (FR-012 dark mode fidelity); shimmer gradient respects `Directionality` automatically via `flutter_animate` (FR-013 RTL) — `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart`
- [X] T016 [P][US2] Update `supervisor_live_task_summary.dart`: read `state.taskSummary` from `context.read<SupervisorDashboardCubit>()`. Replace static `_donePct`, `_inProgressPct`, `_delayPct` constants with `taskSummary.donePct`, `.inProgressPct`, `.delayedPct`. When `taskSummary.isEmpty` → replace progress bar + legend with a centred empty-state `Text('supervisor_dashboard.no_tasks_today'.tr())` and a calendar icon. During `loading` → show a `ClipRRect` container matching the exact `rh(12)` height and `rr(6)` radius of the real progress bar, animated with `.shimmer(duration: 1200.ms)`. **Compliance**: all colours via `CustomColors`/`AppColors` tokens (FR-012 dark mode); wrap progress bar `Row` children in `Directionality`-aware order so the Done segment starts from the leading edge in both LTR and RTL layouts (FR-013 RTL) — `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_live_task_summary.dart`

**Checkpoint**: US1 and US2 independently functional — real stats + live task bar visible, loading/error/empty states all working.

---

## Phase 4: User Story 3 — Assign Task Flow (Priority: P2)

**Goal**: Tapping "Assign Task" opens a bottom sheet with fully functional flight/service-type/unit dropdowns, priority chip row, time pickers, optional notes field, Reset button, and Submit button. Successful submission creates a task in Supabase and refreshes the dashboard.

**Independent Test**: Tap "Assign Task" → bottom sheet slides up; select flight, service type, unit, priority, start/end time → tap Submit → verify new row in `tasks` table with status `assigned`; tap Reset → all fields clear; leave required field empty → Submit blocked with inline error; close and reopen → form is fresh.

### Implementation for US3

- [X] T017 [US3] Create `AssignTaskCubit` with methods: `loadFormData()` (fetches flights + units + serviceTypes in parallel, emits loadingFormData → formReady/failure), `selectFlight(String id)`, `selectServiceType(String id)` (also recomputes `filteredUnits` by matching `unit.serviceTypeId == selectedServiceType.id`), `selectUnit(String id)`, `setPriority(TaskPriority p)`, `setScheduledStart(DateTime dt)`, `setScheduledEnd(DateTime dt)` (validates end > start), `setNotes(String text)`, `reset()` (emits initial state then calls loadFormData()), `submit()` (validates isFormValid → calls repo.assignTask → emits success/failure). State class as `part of` includes `AssignTaskStatus` enum, dropdown lists, current selections, `filteredUnits`, `isFormValid` getter, error — `lib/modules/supervisor/features/dashboard/logic/cubit/assign_task_cubit.dart`
- [X] T018 [US3] Create `assign_task_bottom_sheet.dart` as a `StatelessWidget` containing a `DraggableScrollableSheet` (minChildSize: 0.6, maxChildSize: 0.95, initialChildSize: 0.75). Structure: drag handle bar at top; title row with "Assign Task" label (`.tr()`); scrollable form body with: Flight `DropdownButtonFormField` (label 'select_flight'.tr(), items from state.flights), ServiceType dropdown (items from state.serviceTypes, onChange calls cubit.selectServiceType), Unit dropdown (items from state.filteredUnits, disabled until service type selected), Priority chip row (4 `ChoiceChip` widgets for Low/Medium/High/Critical, default Medium selected per data-model.md), Start Time `ListTile`-style picker (taps open `showTimePicker`), End Time picker (same, validates end > start inline), Notes `TextFormField` (optional, maxLength 500, maxLines 3, shows character counter). Bottom action row: Reset `OutlinedButton` (calls cubit.reset()) + Submit `ElevatedButton` (disabled when !state.isFormValid or submitting, shows spinner when submitting). `BlocConsumer` listener: on success → `Navigator.pop(context)` then `context.read<SupervisorDashboardCubit>().refresh()`; on failure → `context.showErrorSnackBar(state.error!.messageKey.tr())`. On loadingFormData → shimmer over dropdown fields. **Compliance**: all colours via `CustomColors`/`AppColors` tokens — no inline `Color(...)` literals (FR-012 dark mode); all labels and hint texts via `.tr()` and must render correctly mirrored in RTL (FR-013) — `lib/modules/supervisor/features/dashboard/ui/widgets/assign_task_bottom_sheet.dart`
- [X] T019 [P][US3] Update "Assign Task" button `onTap` in `supervisor_quick_actions_row.dart` to call `showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => BlocProvider(create: (_) => AssignTaskCubit(repo: getIt<SupervisorDashboardRepo>())..loadFormData(), child: const AssignTaskBottomSheet()))` — `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_quick_actions_row.dart`

**Checkpoint**: US3 independently functional — full Assign Task flow works end-to-end.

---

## Phase 5: User Story 4 — Delete Report / Incident (Priority: P2)

**Goal**: Supervisors can swipe-to-delete any report from the Reports screen. A confirmation dialog appears before deletion; optimistic removal happens instantly; rollback occurs on failure.

**Independent Test**: Open Reports tab → swipe a report left → confirm dialog appears → tap Delete → report disappears and is removed from Supabase; tap Cancel → report remains; disable network before confirming → error snack bar shown, report reappears.

### Implementation for US4

- [X] T020 [US4] Create `SupervisorReportsCubit` with `loadReports()` (fetches all reports via `reportRepo.fetchAllReports()`, emits loading → success/failure) and `deleteReport(String id)` (optimistic: immediately emits state with report removed from list, then calls `reportRepo.deleteReport(id)`, on failure rolls back by re-inserting report at original index and emitting failure). State class as `part of` includes `SupervisorReportsStatus` enum (initial, loading, success, failure, deleting), `List<ReportModel> reports`, `String? deletingReportId`, `AppError? error` — `lib/modules/supervisor/features/reports/logic/cubit/supervisor_reports_cubit.dart`
- [X] T021 [US4] **Depends on T013 (sequential — both modify `supervisor_scaffold.dart`).** Add `BlocProvider<SupervisorReportsCubit>(create: (_) => getIt<SupervisorReportsCubit>()..loadReports())` to the `MultiBlocProvider` introduced in T013. **Append** `getIt.registerFactory<SupervisorReportsCubit>(() => SupervisorReportsCubit(reportRepo: getIt<ReportRepo>()))` to `dependency_injection.dart` — do not overwrite T011 or T013 registrations — `lib/modules/supervisor/core/main_navigation/supervisor_scaffold.dart`
- [X] T022 [US4] Update `supervisor_reports_screen.dart` with `BlocConsumer<SupervisorReportsCubit, SupervisorReportsState>`. On loading → show shimmer list skeleton. On success → `ListView.builder` of `Dismissible` widgets (key: `ValueKey(report.id)`, direction: `DismissDirection.endToStart` for LTR — use `DismissDirection.startToEnd` when `context.isArabic` for RTL correctness, background: red container with delete icon and 'delete'.tr() label, `confirmDismiss`: calls `AppDialogs.confirm(context, title: 'delete_report_confirm'.tr(), body: 'delete_report_confirm_body'.tr())` — confirm button styled with destructive color (`AppColors.error` or equivalent), `onDismissed`: calls `cubit.deleteReport(report.id)`). On failure → show `context.showErrorSnackBar(state.error!.messageKey.tr())` and rollback is automatic (cubit re-emits the list with the item restored). On empty list → centred empty state with icon and label. **Compliance**: all colours via `AppColors`/`CustomColors` tokens — no inline `Color(...)` literals (FR-012); swipe direction mirrored for RTL, all labels via `.tr()` (FR-013) — `lib/modules/supervisor/features/reports/ui/supervisor_reports_screen.dart`

**Checkpoint**: US4 independently functional — report deletion with confirmation and rollback works.

---

## Phase 6: User Story 5 — Professional UI/UX Polish (Priority: P3)

**Goal**: Count-up animations on stat values, final dark mode fidelity audit, RTL correctness audit, and no hardcoded values anywhere in modified files. Shimmer skeletons are already production-quality from T015/T016; this phase adds the remaining polish and cross-cutting audits.

**Independent Test**: Dark mode toggle → all cards render correctly; switch language to Arabic → all labels in Arabic, layout mirrored, progress bar and swipe direction correct; load dashboard → shimmer cards visible during fetch; stats update → count-up animation plays.

### Implementation for US5

- [X] T025 [P][US5] Apply `flutter_animate` count-up animation to stat card value `Text` in `supervisor_status_grid.dart`: use `.animate(key: ValueKey(value)).custom(duration: 400.ms, builder: (ctx, v, child) => Text('${(v * value).round()}', style: ...))` so the number animates from 0 to the new count on each successful data load — `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart`
- [X] T026 [P][US5] Audit all modified widget files for dark mode fidelity: confirm all `Color` usage references `cc.surface`, `cc.textPrimary`, `cc.border`, `AppColors.*` constants — replace any remaining hardcoded `Color(0x...)` literals. Affected files: `supervisor_status_grid.dart`, `supervisor_live_task_summary.dart`, `supervisor_quick_actions_row.dart`, `assign_task_bottom_sheet.dart`, `supervisor_reports_screen.dart`
- [X] T027 [P][US5] RTL correctness audit across modified widgets: (a) verify progress bar `Row` children are `Directionality`-aware so Done segment starts from the leading edge in both LTR and RTL (already specified in T016 — confirm implementation); (b) verify `Dismissible.direction` is `startToEnd` when `context.isArabic` (already specified in T022 — confirm implementation); (c) verify shimmer gradient direction is handled correctly by `flutter_animate`'s `Directionality`-awareness
- [X] T028 [P][US5] Final string audit: search all modified Dart files for any string literals that are user-visible (using `grep` / IDE search); convert any remaining to `.tr()` with corresponding en.json/ar.json key added — affects all files in `lib/modules/supervisor/`

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Static analysis, test run, and file clean-up.

- [X] T029 [P] Run `flutter analyze lib/modules/supervisor/ lib/core/shared/data/remote/report_remote_ds.dart lib/core/shared/data/repo/report_repo.dart lib/core/shared/data/repo/report_repo_impl.dart lib/core/di/dependency_injection.dart` and fix all warnings, info-level hints, and errors
- [ ] T030 [P] Run `make test` and confirm all cubit unit tests pass (SupervisorDashboardCubit state transitions: initial→loading→success, initial→loading→failure; AssignTaskCubit: formReady→submitting→success, reset clears state; SupervisorReportsCubit: optimistic delete and rollback)
- [X] T031 Delete commented-out legacy code in `supervisor_status_grid.dart` (lines 163–313 are commented-out duplicate class definitions) — `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately. T001–T004 can all run in parallel.
- **Foundational (Phase 2)**: Depends on Phase 1 completion (models must exist). T005 and T006 parallel, T007 depends on both. T008 and T009 parallel, T010 depends on both. T011 parallel with T005–T010. T003/T004 (localization) parallel with all.
- **US1+US2 (Phase 3)**: Depends on Phase 2 completion. T012→T013→T014→T015/T016 (T015 and T016 parallel).
- **US3 (Phase 4)**: Depends on Phase 2 completion. T017→T018→T019. Can start in parallel with Phase 3.
- **US4 (Phase 5)**: Depends on Phase 2 completion. T020→T021→T022. T021 is **sequential after T013** (same file: `supervisor_scaffold.dart`). US4 can start in parallel with US3, but T021 must wait for T013.
- **US5 (Phase 6)**: Depends on Phases 3, 4, and 5 completion (polishes what they built). T025–T028 all parallel. (T023/T024 shimmer tasks were merged into T015/T016 — no longer separate tasks.)
- **Polish (Phase 7)**: Depends on all prior phases. T029–T031 parallel.

### User Story Dependencies

- **US1 + US2 (P1)**: Can start after Phase 2 — no dependency on US3/US4/US5.
- **US3 (P2)**: Can start after Phase 2 — no dependency on US1/US2.
- **US4 (P2)**: Can start after Phase 2 — no dependency on US1/US2/US3.
- **US5 (P3)**: Depends on US1+US2, US3, and US4 being complete.

### Within Each User Story

- Models/DS/Repo before Cubit.
- Cubit before Screen/Widget.
- Scaffold provider update before screen BlocConsumer.
- Localization keys before any `.tr()` usage in widgets.

### Parallel Opportunities

All Phase 1 tasks (T001–T004): fully parallel.
Phase 2: T005+T006 parallel, T008+T009 parallel, T010+T011 parallel with everything.
Phase 3+: US1 (T012–T016) and US3 (T017–T019) can run fully in parallel after Phase 2. US4 (T020–T022) can start in parallel for T020, but T021 must wait for T013 (sequential on `supervisor_scaffold.dart`).
Phase 6: All polish tasks (T025–T028) parallel. (T023/T024 merged into T015/T016.)
Phase 7: T029+T030+T031 parallel.

---

## Parallel Example: Phase 2

```text
# Start all foundational tasks in parallel (different files):
Task T005: Create SupervisorDashboardRemoteDs
Task T006: Create SupervisorDashboardRepo interface
Task T008: Extend ReportRemoteDs
Task T009: Extend ReportRepo interface
Task T011: Add DI registrations (DS + Repo only)
Task T003: en.json localization keys
Task T004: ar.json localization keys

# After T005 + T006:
Task T007: Create SupervisorDashboardRepoImpl

# After T008 + T009:
Task T010: Implement new methods in ReportRepoImpl
```

---

## Implementation Strategy

### MVP First (US1 + US2 Only)

1. Complete Phase 1 (models)
2. Complete Phase 2 (data layer)
3. Complete Phase 3 (dashboard cubit + widgets)
4. **STOP and VALIDATE**: Real stats and live task bar visible, error/empty/loading states working
5. Demo to stakeholders

### Incremental Delivery

1. Phase 1 + 2 → Data layer complete (no visible change yet)
2. Phase 3 → Dashboard shows real data (MVP: situational awareness restored)
3. Phase 4 → Assign Task works (MVP: supervisors can create tasks)
4. Phase 5 → Report deletion works (MVP: record hygiene)
5. Phase 6 → Full polish (production quality)
6. Phase 7 → Clean compile + tests green

### Parallel Team Strategy

With 3 developers, after Phase 2:

- Developer A: Phase 3 (Dashboard cubit + UI)
- Developer B: Phase 4 (Assign Task cubit + bottom sheet)
- Developer C: Phase 5 (Reports cubit + delete UI)

All merge before Phase 6 polish.

---

## Notes

- [P] tasks = different files, no incomplete dependencies → safe to run in parallel
- [Story] label maps each task to its user story for traceability
- `AssignTaskCubit` is **NOT registered in DI** — instantiated inline in `showModalBottomSheet` builder
- `SupervisorDashboardRepo` is registered as lazySingleton (reused by both `SupervisorDashboardCubit` and `AssignTaskCubit`)
- **Stat card navigation** (confirmed from `supervisor_scaffold.dart`): Reports is tab index 1 — use `SupervisorBottomNavCubit.jumpTo(1)` introduced in T013, NOT `pushNamed`. Active Units has no tab yet — disable tap with a toast until the units tab is added in a future feature.
- `SupervisorBottomNavCubit` is a **new lightweight cubit** introduced in T013 (`lib/modules/supervisor/core/main_navigation/cubit/supervisor_bottom_nav_cubit.dart`) to expose tab switching to child widgets without leaking `_controller` state outside the scaffold
- Delete the 150 lines of commented-out duplicate code in `supervisor_status_grid.dart` (T031) before final PR review
- All checklist items from `checklists/ux.md` that are marked `[Gap]` should be resolved by the implementer before starting the relevant task — consult the spec author if unclear
