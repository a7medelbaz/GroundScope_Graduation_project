# Research: Assign Task Full-Page Screen

**Feature**: `specs/003-add-task-screen`
**Date**: 2026-05-18
**Status**: Complete — no unknowns

---

## Decision 1 — Loading State Pattern

**Decision**: Use `Center(child: CircularProgressIndicator(color: AppColors.primary200))` for the full-screen loading state.

**Rationale**: Design system §8 Pattern A specifies this exact pattern for `loading/initial` status. The existing bottom sheet skeleton is the problem the user is solving — it appears inside a sliding panel. A centered spinner on a full page feels like a proper page load.

**Alternatives considered**: Skeleton list (current bottom sheet approach) — rejected because it's the anti-pattern being replaced.

---

## Decision 2 — Error State Pattern

**Decision**: `cloud_off_rounded` icon (`rf(48)`, `cc.textDisabled`) + `font14Light` message (`cc.textSecondary`) + `TextButton.icon(Icons.refresh_rounded)` retry button.

**Rationale**: Design system §8 Pattern A specifies this exact error layout. Matches the worker reports screen and supervisor reports screen for consistency.

**Alternatives considered**: `ErrorScreen` widget — rejected because it's oversized (`rf(80)` icon) and uses `red100` which is inconsistent with the network-error pattern used elsewhere.

---

## Decision 3 — App Bar

**Decision**: `CustomAppBar(title: 'supervisor_dashboard.assign_task_title'.tr())` placed as the first child of a `Column` in the `Scaffold` body (not as `Scaffold.appBar`).

**Rationale**: `CustomAppBar` is a `StatelessWidget` (not `PreferredSizeWidget`). All supervisor/worker pushed screens that use it (e.g., `SupervisorTaskListScreen`, `SupervisorActiveUnitsScreen`) use it in the body. Its built-in `context.pop()` back button works correctly for pushed named routes.

**Alternatives considered**: Using `AppBar(...)` directly in `Scaffold.appBar` — rejected because it diverges from the `CustomAppBar` standard and requires manual styling.

---

## Decision 4 — BlocConsumer Listener (Success Path)

**Decision**: On `AssignTaskStatus.success`, the listener executes in this order:
1. `context.read<SupervisorDashboardCubit>().refresh()` — triggers async dashboard reload
2. `context.showSuccessSnackBar(...)` — shows on `ScaffoldMessenger` (survives route pop)
3. `context.pop()` — returns to dashboard

**Rationale**: `ScaffoldMessenger` is registered above the `Navigator` in the widget tree, so calling `showSuccessSnackBar` before `pop()` ensures the snack bar appears on the dashboard screen after the assign-task screen is removed. The dashboard refresh is async and doesn't block the pop.

**Alternatives considered**: Passing a result via `Navigator.pop(context, true)` and handling it in the calling widget — rejected because the calling widget (`SupervisorQuickActionsRow`) is not a stateful widget and doesn't have a natural place to await the result.

---

## Decision 5 — DI Registration

**Decision**: Register `AssignTaskCubit` as a `registerFactory` in `dependency_injection.dart`. Use `getIt<AssignTaskCubit>()..loadFormData()` in `app_routers.dart`.

**Rationale**: Constitution §III requires route-scoped cubits to be provided at route level in `app_routers.dart`. Constitution Development Standards require all new cubits to be registered in `dependency_injection.dart`. The factory registration ensures a fresh instance on each navigation (matching current fresh-state-on-open behaviour).

**Alternatives considered**: Inline cubit creation in `app_routers.dart` — technically works but bypasses DI and violates the constitution's DI requirement.

---

## Decision 6 — Localization

**Decision**: No new localization keys needed. All strings required by the new screen already exist under `supervisor_dashboard.*` in both `en.json` and `ar.json`.

**Rationale**: The new screen contains the same form fields and messages as the existing bottom sheet. All keys were already added when the bottom sheet was built.

---

## Decision 7 — Bottom Sheet Disposal

**Decision**: Delete `lib/modules/supervisor/features/dashboard/ui/widgets/assign_task_bottom_sheet.dart`. All reusable sub-widgets (`_SectionLabel`, `_PriorityChipRow`, `_TimePicker`) are moved into the new screen file.

**Rationale**: The bottom sheet file will have zero references after the quick actions row is updated. Leaving dead code creates confusion about which file is canonical.
