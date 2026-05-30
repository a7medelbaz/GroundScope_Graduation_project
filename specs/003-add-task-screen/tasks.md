# Tasks: Assign Task — Full-Page Screen

**Input**: Design documents from `specs/003-add-task-screen/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅

**Tests**: Not requested — `flutter analyze` only per spec.

**Organization**: Tasks grouped by user story. US1 (navigation + loading) and US2 (form + validation + submission) are both P1. US3 (error state + retry) is P2.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no incomplete dependencies)
- **[Story]**: Maps to user story in spec.md
- All paths relative to project root

---

## Phase 1: Setup

**Purpose**: No new project initialization needed — this is a modification of an existing Flutter project. Verify import resolvability before writing code.

- [X] T001 Read `lib/core/di/dependency_injection.dart`, `lib/core/router/app_routers.dart`, `lib/modules/supervisor/features/dashboard/ui/widgets/assign_task_bottom_sheet.dart`, and `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_quick_actions_row.dart` to confirm `AssignTaskCubit`, `SupervisorDashboardRepo`, `UserService`, and existing route registration patterns

---

## Phase 2: Foundational (Route Wiring — Blocking)

**Purpose**: Register the named route constant, DI factory, and router case so the new screen is reachable. MUST complete before any UI work begins.

**⚠️ CRITICAL**: T002 and T003 are independent (different files) and run in parallel. T004 depends on both.

- [X] T002 [P] Add route constant `static const String supervisorAssignTaskScreen = '/supervisorAssignTaskScreen';` to the `Routes` class in `lib/core/router/routes.dart`
- [X] T003 [P] Register `AssignTaskCubit` as a factory in `lib/core/di/dependency_injection.dart`: `getIt.registerFactory<AssignTaskCubit>(() => AssignTaskCubit(repo: getIt<SupervisorDashboardRepo>(), userService: getIt<UserService>()));` — add required imports for `AssignTaskCubit`, `SupervisorDashboardRepo`, and `UserService`
- [X] T004 Add `supervisorAssignTaskScreen` route case to the `generateRoute` switch in `lib/core/router/app_routers.dart` (depends on T002 + T003): `case Routes.supervisorAssignTaskScreen: return _buildRoute(BlocProvider(create: (_) => getIt<AssignTaskCubit>()..loadFormData(), child: const AssignTaskScreen()), settings);` — add import `'../../modules/supervisor/features/dashboard/ui/assign_task_screen.dart'`

**Checkpoint**: `flutter analyze` passes on routes.dart, dependency_injection.dart, app_routers.dart.

---

## Phase 3: User Story 1 — Screen Scaffold & Navigation Entry (Priority: P1) 🎯 MVP

**Goal**: Supervisor taps "Assign Task" and lands on a full-page screen that immediately shows a centered loading indicator — no bottom sheet, no skeleton.

**Independent Test**: Tap "Assign Task" on supervisor dashboard → new screen pushes (full-page, not modal sheet) → `CircularProgressIndicator(color: AppColors.primary200)` appears centered while data loads.

### Implementation

- [X] T005 [US1] Create `lib/modules/supervisor/features/dashboard/ui/assign_task_screen.dart` with the following structure: `class AssignTaskScreen extends StatelessWidget` — `Scaffold(backgroundColor: cc.background)` body is `SafeArea(top: false)` wrapping a `Column` with `CustomAppBar(title: 'supervisor_dashboard.assign_task_title'.tr())` and an `Expanded(child: BlocConsumer<AssignTaskCubit, AssignTaskState>(listener: _listener, builder: _builder))`; `_builder` returns `Center(child: CircularProgressIndicator(color: AppColors.primary200))` for `AssignTaskStatus.loadingFormData` and `AssignTaskStatus.initial`; stub remaining builder branches as `const SizedBox.shrink()`; stub `_listener` as empty; add all necessary imports (AssignTaskCubit, AssignTaskState, AssignTaskStatus, AppColors, CustomAppBar, context_ext, easy_localization)
- [X] T006 [US1] Update `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_quick_actions_row.dart`: replace the `_openAssignTask` method body — remove `showModalBottomSheet(...)` call and any inline `BlocProvider`; replace with `context.pushNamed(Routes.supervisorAssignTaskScreen, rootNavigator: true)`; remove import of `assign_task_bottom_sheet.dart` and `get_it`; add import of `lib/core/router/routes.dart`

**Checkpoint**: App builds and navigates to new full-page screen. Loading spinner visible on entry.

---

## Phase 4: User Story 1+2 — Form Body, Validation & Submission (Priority: P1)

**Goal**: Once data loads, all 7 form fields render correctly. Submit button enables only when all required fields are set and end > start. Reset clears form without refetch. Submission shows button spinner and triggers cubit.

**Independent Test**: Data loads → all fields appear → fill required fields → submit enables → tap submit → button shows spinner → success snackbar on dashboard → screen closes → dashboard refreshes. Also: empty required field → submit disabled; set end ≤ start → submit disabled.

### Implementation (T007–T011 all modify `assign_task_screen.dart`; execute sequentially)

- [X] T007 [US1] Add private `_SectionLabel` StatelessWidget at the bottom of `assign_task_screen.dart`: constructor `const _SectionLabel(this.label)`; `build` returns `Text(label, style: AppTextStyles.font14SemiBold.copyWith(color: cc.textSecondary))` where `cc = context.customColors`
- [X] T008 [US1] Add private `_PriorityChipRow` StatelessWidget to `assign_task_screen.dart`: constructor takes `TaskPriority selected` and `ValueChanged<TaskPriority> onChanged`; build returns `Row(children: TaskPriority.values.map((p) => _buildChip(p)).toList())`; selected chip style: `BoxDecoration(color: priorityColor.withOpacity(0.15), border: Border.all(color: priorityColor), borderRadius: rr(8))`; unselected style: `BoxDecoration(color: cc.surface, border: Border.all(color: cc.border.withOpacity(0.5)), borderRadius: rr(8))`; chip text: `AppTextStyles.font12SemiBold` in priority color when selected, `cc.textHint` when unselected; calls `onChanged(p)` on tap; use `TaskUiHelpers.priorityColor(p)` for color; add `HorizontalSpacing(rw(8))` between chips
- [X] T009 [US1] Add private `_TimePicker` StatelessWidget to `assign_task_screen.dart`: constructor takes `String label`, `DateTime? value`, `ValueChanged<DateTime> onPicked`; build returns a `GestureDetector` wrapping a `Container(height: rh(52), padding: EdgeInsets.symmetric(horizontal: rw(12)), decoration: BoxDecoration(color: cc.surface, borderRadius: rr(12), border: Border.all(color: cc.border.withOpacity(0.5))))`; Row contents: `Icon(Icons.access_time_rounded, size: rf(18), color: cc.textHint)`, `horizontalSpacing(rw(8))`, `Text(value != null ? value.formattedTime : label, style: AppTextStyles.font14Light.copyWith(color: value != null ? cc.textPrimary : cc.textHint))`; on tap: `showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()))` then combine with today's date: `final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute); onPicked(dt);`
- [X] T010 [US2] Add private `_FormBody` StatelessWidget to `assign_task_screen.dart`: constructor takes `AssignTaskState state`; build returns `SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: EdgeInsets.fromLTRB(rw(20), rh(8), rw(20), rh(32)))` with a `Column` containing in order: (1) `_SectionLabel('supervisor_dashboard.flight_label'.tr())`, flight `DropdownButtonFormField<FlightModel>` with items from `state.flights`, display `'${f.flightNumber} · ${f.origin} → ${f.destination}'`, calls `cubit.selectFlight(f)` on change; (2) `_SectionLabel('supervisor_dashboard.service_type_label'.tr())`, service type `DropdownButtonFormField<ServiceTypeModel>` with items from `state.serviceTypes`; (3) `_SectionLabel('supervisor_dashboard.unit_label'.tr())`, unit `DropdownButtonFormField<UnitModel>` with items from `state.filteredUnits`, disabled when `state.filteredUnits.isEmpty`; (4) `_SectionLabel('supervisor_dashboard.priority_label'.tr())`, `_PriorityChipRow(selected: state.priority, onChanged: cubit.setPriority)`; (5) `_SectionLabel('supervisor_dashboard.start_time_label'.tr())`, `_TimePicker(label: '...select...'.tr(), value: state.scheduledStart, onPicked: cubit.setScheduledStart)`; (6) `_SectionLabel('supervisor_dashboard.end_time_label'.tr())`, `_TimePicker(label: '...select...'.tr(), value: state.scheduledEnd, onPicked: cubit.setScheduledEnd)`; (7) `_SectionLabel('supervisor_dashboard.notes_label'.tr())`, `TextFormField(maxLines: 3, maxLength: 500, onChanged: cubit.setNotes, decoration: _inputDecoration(cc))`; all dropdowns use `_inputDecoration(cc)` helper; add `InputDecoration _inputDecoration(CustomColors cc) => InputDecoration(filled: true, fillColor: cc.surface, border: OutlineInputBorder(borderRadius: rr(12), borderSide: BorderSide(color: cc.border.withOpacity(0.5))), enabledBorder: OutlineInputBorder(borderRadius: rr(12), borderSide: BorderSide(color: cc.border.withOpacity(0.5))), contentPadding: EdgeInsets.symmetric(horizontal: rw(12), vertical: rh(14)))` as a top-level private function in the file
- [X] T011 [US2] Append reset and submit buttons to the `Column` in `_FormBody` in `assign_task_screen.dart`: `verticalSpacing(rh(24))`; `Row(children: [Expanded(resetBtn), horizontalSpacing(rw(12)), Expanded(submitBtn)])`; reset = `OutlinedButton(onPressed: () => cubit.reset(), style: OutlinedButton.styleFrom(side: BorderSide(color: cc.border), shape: RoundedRectangleBorder(borderRadius: rr(12))), child: Text('supervisor_dashboard.reset_label'.tr(), style: AppTextStyles.font16SemiBold.copyWith(color: cc.textSecondary)))`; submit = `FilledButton(onPressed: state.isFormValid && state.status != AssignTaskStatus.submitting ? () => cubit.submit() : null, style: FilledButton.styleFrom(backgroundColor: state.isFormValid ? AppColors.primary200 : AppColors.primary200.withOpacity(0.4), shape: RoundedRectangleBorder(borderRadius: rr(12))), child: state.status == AssignTaskStatus.submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('supervisor_dashboard.assign_task_title'.tr(), style: AppTextStyles.font16SemiBold.copyWith(color: Colors.white)))`; update `BlocConsumer` builder to return `_FormBody(state: state)` for `formReady`, `submitting`, and `success` statuses

**Checkpoint**: Full form visible. Submit disabled when fields empty. Spinner on button while submitting.

---

## Phase 5: User Story 1 — BlocConsumer Listener (Priority: P1)

**Goal**: Success navigates back to dashboard with snackbar and triggers refresh. Failure shows error snackbar while keeping the form open.

**Independent Test**: Submit valid form → `task_assigned_success` snackbar on dashboard → dashboard task count updates → screen closed. Submit with simulated server error → error snackbar shown → form stays open with all values intact.

### Implementation

- [X] T012 [US1] Replace the empty `_listener` stub in `assign_task_screen.dart` with the full listener: `if (state.status == AssignTaskStatus.success) { context.read<SupervisorDashboardCubit>().refresh(); context.showSuccessSnackBar('supervisor_dashboard.task_assigned_success'.tr()); if (Navigator.canPop(context)) context.pop(); } else if (state.status == AssignTaskStatus.failure && state.error != null) { context.showErrorSnackBar(state.error!.messageKey.tr()); }` — add import for `SupervisorDashboardCubit` from `lib/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_cubit.dart`

**Checkpoint**: Submit → success → snackbar appears on dashboard and screen closes. Failure → snackbar, form stays open.

---

## Phase 6: User Story 3 — Error State & Retry (Priority: P2)

**Goal**: If `loadFormData()` fails, show a `cloud_off` error state with a retry button instead of an empty screen.

**Independent Test**: Simulate network failure before opening screen → loading indicator → error state with descriptive message and retry button; tap Retry → loading reappears → form loads (if network restored).

### Implementation

- [X] T013 [US3] Add private `_ErrorBody` StatelessWidget to `assign_task_screen.dart`: constructor takes `VoidCallback onRetry`; build returns `Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_off_rounded, size: rf(48), color: cc.textDisabled), verticalSpacing(rh(12)), Text('supervisor_dashboard.error_loading_form'.tr(), style: AppTextStyles.font14Light.copyWith(color: cc.textSecondary), textAlign: TextAlign.center), verticalSpacing(rh(8)), TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: Text('supervisor_dashboard.retry'.tr()))]))` 
- [X] T014 [US3] Update `BlocConsumer` builder in `assign_task_screen.dart`: add branch `if (state.status == AssignTaskStatus.failure && state.flights.isEmpty) return _ErrorBody(onRetry: () => context.read<AssignTaskCubit>().loadFormData());` before the default form branch; ensure all `AssignTaskStatus` values are handled without `default` so the compiler catches future additions

**Checkpoint**: Error state renders with retry button. Retry re-triggers `loadFormData()`.

---

## Phase 7: Polish & Cleanup

**Purpose**: Remove dead code, verify clean analyze output, confirm localization completeness.

- [X] T015 Delete `lib/modules/supervisor/features/dashboard/ui/widgets/assign_task_bottom_sheet.dart` — confirm zero remaining imports of this file before deleting (T006 must be complete)
- [X] T016 [P] Run `flutter analyze` from project root and fix all errors and warnings in the 6 touched files: `routes.dart`, `dependency_injection.dart`, `app_routers.dart`, `assign_task_screen.dart`, `supervisor_quick_actions_row.dart`, and any new file
- [X] T017 [P] Verify `assets/lang/en.json` and `assets/lang/ar.json` contain all keys referenced via `.tr()` in `assign_task_screen.dart` (at minimum: `supervisor_dashboard.assign_task_title`, `supervisor_dashboard.task_assigned_success`, `supervisor_dashboard.error_loading_form`, `supervisor_dashboard.retry`, `supervisor_dashboard.flight_label`, `supervisor_dashboard.service_type_label`, `supervisor_dashboard.unit_label`, `supervisor_dashboard.priority_label`, `supervisor_dashboard.start_time_label`, `supervisor_dashboard.end_time_label`, `supervisor_dashboard.notes_label`, `supervisor_dashboard.reset_label`); add any missing keys with appropriate translations to both files

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: No external dependencies; T002 ∥ T003, then T004
- **Phase 3 (US1 navigation)**: Depends on Phase 2 complete (route constant must exist for T006; router case for the screen to be reachable)
- **Phase 4 (US1+US2 form)**: Depends on Phase 3 (T005 scaffold must exist before adding private widgets)
- **Phase 5 (US1 listener)**: Depends on Phase 4 (full form must exist before wiring the listener referencing `_FormBody`)
- **Phase 6 (US3 error)**: Depends on Phase 3 (T005 scaffold must exist; can run in parallel with Phase 4)
- **Phase 7 (Polish)**: Depends on Phases 3–6 all complete

### User Story Dependencies

- **US1 (P1)**: T005 → T006 → T007 → T008 → T009 → T010 → T011 → T012
- **US2 (P1)**: Shares `_FormBody` with US1 — T010 and T011 implement US2 within the same widget; no additional files
- **US3 (P2)**: T013 → T014; can begin after T005 exists

### Parallel Opportunities

| Tasks | Why parallel |
|-------|-------------|
| T002 + T003 | Different files (routes.dart vs dependency_injection.dart) |
| T013 + T007–T010 | Different concerns in same file but sequential edits — only truly parallel if two developers |
| T016 + T017 | Phase 7 — analyze vs localization check |

---

## Parallel Example: Phase 2 (Route Wiring)

```text
Start: T002 (routes.dart) ∥ T003 (dependency_injection.dart)
Then:  T004 (app_routers.dart — waits for both)
```

## Parallel Example: US1 + US3 After Scaffold Exists

```text
After T005 (scaffold created):
  Track A: T006 → T007 → T008 → T009 → T010 → T011 (form body, US1+US2)
  Track B: T013 → T014 (error state, US3) — can start immediately after T005
  Join at: T012 (listener — references _FormBody and _ErrorBody, waits for both tracks)
```

---

## Implementation Strategy

### MVP First (Navigation + Loading Only)

1. Complete Phase 2 (T002–T004): route wired
2. Complete Phase 3 (T005–T006): screen opens, spinner visible
3. **STOP and validate**: tap "Assign Task" → full-page screen with spinner — bottom sheet gone
4. Continue: Phases 4–6 add the form + error state

### Incremental Delivery

1. Phases 2–3 → navigation works, loading shows (US1 partial) ✓
2. Phase 4 → form body visible (US1+US2 form) ✓
3. Phase 5 → submission + success navigation (US1+US2 complete) ✓
4. Phase 6 → error state + retry (US3 complete) ✓
5. Phase 7 → cleanup ✓

### Single-Developer Execution Order

`T001 → T002 ∥ T003 → T004 → T005 → T006 → T007 → T008 → T009 → T010 → T011 → T012 → T013 → T014 → T015 → T016 ∥ T017`

---

## Notes

- No test tasks — spec requires `flutter analyze` only (no unit/widget tests requested)
- T005 creates the file skeleton; T007–T011 add private widgets to it; always read the current file state before editing
- `_inputDecoration` is a top-level private function in `assign_task_screen.dart`, not a method on a class
- `_FormBody` takes `AssignTaskState state` as a parameter so it can read all fields without a `BlocBuilder` wrapper
- `_TimePicker.onPicked` receives a full `DateTime` (today's date + picked `TimeOfDay`) — use `DateTime.now()` for the date part
- T006 must remove ALL references to `assign_task_bottom_sheet.dart` before T015 can safely delete it
- Research Decision 6: all localization keys should already exist under `supervisor_dashboard.*`; T017 confirms this
- `Navigator.canPop(context)` guard in T012 prevents crash if screen is ever the root route
