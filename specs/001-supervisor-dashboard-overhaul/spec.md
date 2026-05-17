# Feature Specification: Supervisor Dashboard Overhaul

**Feature Branch**: `001-supervisor-dashboard-overhaul`

**Created**: 2026-05-17

**Status**: Draft

**Scope**: `lib/modules/supervisor/features/dashboard/`

---

## Context

The supervisor dashboard currently shows all stats and the Live Task Summary with
hardcoded placeholder data (e.g. static "4" counts, fixed 70/20/10% task breakdown).
Quick actions (Report Incident, Assign Task) have no behaviour. This specification
covers replacing every placeholder with real Supabase data, implementing the Assign
Task flow end-to-end, adding supervisor-level report deletion, and elevating the
visual design to a production-quality standard.

The Admin Notification card is **excluded** from this feature — it remains a static
placeholder until a dedicated notification system is built.

---

## User Scenarios & Testing

### User Story 1 — Real-Time Dashboard Stats (Priority: P1)

A supervisor opens the dashboard and immediately sees accurate, live counts for
Active Units, Completed Tasks (today), Delayed Tasks, and Reports filed today —
all sourced from the Supabase backend. Pulling down refreshes every counter.

**Why this priority**: The entire purpose of the dashboard is situational awareness.
Hardcoded numbers actively mislead supervisors making operational decisions.

**Independent Test**: Can be tested in isolation by opening the dashboard tab and
verifying each stat card shows a number that matches a direct Supabase query against
the `units`, `tasks`, and `reports` tables.

**Acceptance Scenarios**:

1. **Given** the supervisor is on the dashboard, **When** the screen loads,
   **Then** the Stats Grid shows live counts: Active Units (units with status =
   `active`), Completed Tasks (tasks with status = `completed`, scheduled today),
   Delayed Tasks (tasks where `scheduled_end` < now and status ≠ `completed` /
   `cancelled`), Reports Today (reports with `created_at` = today).
2. **Given** a new task is completed in the backend, **When** the supervisor
   pulls to refresh, **Then** the Completed Tasks count increments accordingly.
3. **Given** a backend fetch fails (network error), **When** the screen loads,
   **Then** an inline error message is shown with a retry button; stat cards
   display a dash (`—`) instead of stale zeros.

---

### User Story 2 — Live Task Summary with Real Data (Priority: P1)

The stacked progress bar and legend in the Live Task Summary section reflect the
actual percentage breakdown of all tasks for today (Done / In-Progress / Delayed)
calculated from Supabase in real time.

**Why this priority**: Ties directly to US1 — same data load, same cubit. Without
real percentages the "LIVE UPDATES" badge is misleading.

**Independent Test**: Verify that the progress bar segments match the ratios derived
from counting tasks by status in the database.

**Acceptance Scenarios**:

1. **Given** tasks exist in the database for today, **When** the dashboard loads,
   **Then** the progress bar segments and legend percentages reflect the actual
   `completed`, `inProgress` / `assigned` / `paused`, and delayed task ratios.
2. **Given** all tasks are completed, **When** the dashboard loads, **Then** the
   progress bar is fully green (100% Done) and the other segments are absent.
3. **Given** no tasks exist for today, **When** the dashboard loads, **Then** the
   progress bar shows a neutral empty state message instead of a 0/0/0 bar.

---

### User Story 3 — Assign Task Flow (Priority: P2)

A supervisor taps "Assign Task" on the dashboard and is presented with a
step-by-step form to create and assign a task: select a flight, choose a service
type, pick an available unit, set priority and scheduled time window, and optionally
add notes. On submission the task is persisted to Supabase and the dashboard stats
refresh automatically.

**Why this priority**: This is the primary supervisor action. The button currently
does nothing, which means supervisors cannot create tasks from the dashboard at all.

**Independent Test**: Tapping "Assign Task" opens a form; completing it and
submitting creates a new row in the `tasks` table and the stats grid reflects the
change after refresh.

**Acceptance Scenarios**:

1. **Given** the supervisor taps "Assign Task", **When** tapped, **Then** a bottom
   sheet modal slides up containing the Assign Task form; the flight dropdown is
   populated from Supabase (flights scheduled for today), the service-type dropdown
   lists all active service types, and the unit dropdown shows units compatible with
   the selected service type and currently active. A Reset button is visible and
   clears all fields without closing the sheet.
2. **Given** the supervisor fills all required fields (flight, service type, unit,
   priority, start time, end time), **When** they tap Submit, **Then** a new task
   with status `assigned` is created in Supabase and a success toast is shown.
3. **Given** any required field is empty, **When** the supervisor taps Submit,
   **Then** inline validation messages appear on the empty fields and submission
   is blocked.
4. **Given** the scheduled end time is before or equal to the start time, **When**
   the supervisor taps Submit, **Then** a validation error is shown on the end
   time field.
5. **Given** submission fails (network error), **When** the error occurs, **Then**
   an error snack bar is shown and the form remains open with data intact.

---

### User Story 4 — Delete Report / Incident (Priority: P2)

A supervisor can permanently delete a report/incident record. The delete action is
accessible wherever reports are listed and requires a confirmation dialog before
proceeding.

**Why this priority**: Supervisors need the ability to remove erroneous or duplicate
reports to keep the records clean. Without it, bad reports accumulate indefinitely.

**Independent Test**: Long-press or swipe a report to reveal "Delete"; confirm the
dialog; verify the report disappears from the list and is removed from Supabase.

**Acceptance Scenarios**:

1. **Given** a supervisor views a report, **When** they initiate delete (swipe or
   button), **Then** a confirmation dialog appears with "Delete" and "Cancel"
   options.
2. **Given** the confirmation dialog is shown, **When** the supervisor taps
   "Delete", **Then** the report is removed from Supabase and disappears from the
   list without a full reload.
3. **Given** the supervisor taps "Cancel" in the dialog, **When** dismissed,
   **Then** the report remains and the list is unchanged.
4. **Given** the delete call fails (network error), **When** the error occurs,
   **Then** an error snack bar is shown and the report remains visible.

---

### User Story 5 — Professional UI/UX Polish (Priority: P3)

The entire supervisor dashboard is visually elevated: improved card hierarchy,
consistent spacing, status-colour semantics, smooth loading states (shimmer
skeletons instead of spinners), subtle micro-animations on number updates, and
full dark-mode and RTL (Arabic) fidelity.

**Why this priority**: Enhances perceived quality and usability but does not block
functional delivery of P1/P2 stories.

**Independent Test**: Visual inspection against design guidelines; RTL layout
verified by switching device language to Arabic; dark mode verified by toggling
theme; no hardcoded colours or sizes remain.

**Acceptance Scenarios**:

1. **Given** the dashboard is loading data, **When** the fetch is in-flight,
   **Then** shimmer skeleton cards replace the stat cards and summary widget
   (no raw `CircularProgressIndicator` at dashboard level).
2. **Given** the app is in dark mode, **When** the dashboard is viewed, **Then**
   all cards, text, and borders use `CustomColors` semantic tokens and render
   correctly without light-mode colour leakage.
3. **Given** the device language is Arabic, **When** the dashboard is viewed,
   **Then** all labels are in Arabic (via `.tr()`), layout is mirrored correctly
   (RTL), and the progress bar direction is preserved logically.
4. **Given** the stats refresh with new values, **When** the numbers change,
   **Then** a brief count-up animation plays on the updated stat cards.

---

### Edge Cases

- What if a supervisor has no units assigned? Stats should show `0` gracefully.
- What if there are no flights in the next 24 hours? The flight dropdown shows an
  empty-state message: "No upcoming flights in the next 24 hours."
- What if a task's `scheduled_end` equals `now` exactly? It must be classified
  as delayed.
- What if the Supabase session expires mid-session? The auth cubit handles
  re-authentication; dashboard shows appropriate error state.

---

## Requirements

### Functional Requirements

- **FR-001**: The system MUST fetch Active Units count, Completed Tasks (today),
  Delayed Tasks, and Reports Today from Supabase on dashboard load and pull-to-refresh.
  All counts are **airport-wide** (global); per-supervisor scoping is out of scope
  for this iteration.
- **FR-002**: The system MUST calculate Live Task Summary percentages from real task
  data (Done = `completed`; In-Progress = `inProgress` + `assigned` + `paused`;
  Delayed = past `scheduled_end` and not `completed`/`cancelled`).
- **FR-003**: The dashboard MUST display shimmer skeleton placeholders while data
  is loading (no raw spinner at widget level).
- **FR-003a**: Data MUST refresh only on initial load and on explicit pull-to-refresh.
  No background polling or Supabase Realtime subscriptions are used in this iteration.
- **FR-004**: The dashboard MUST show an inline error state with a retry action
  when any Supabase fetch fails.
- **FR-005**: The "Assign Task" quick action MUST open the Assign Task form as a
  **bottom sheet modal** (slides up over the dashboard; no new route required).
- **FR-005a**: The Assign Task bottom sheet MUST include a **Reset button** that
  clears all form fields back to their initial empty/default state without closing
  the sheet.
- **FR-006**: The Assign Task form flight dropdown MUST fetch flights scheduled
  within the **next 24 hours from now** (today + overnight/early-morning) from
  Supabase, ordered by scheduled departure time ascending.
- **FR-006a**: The Assign Task form MUST filter available units by compatibility
  with the selected service type.
- **FR-007**: Successful task assignment MUST write a row to the `tasks` table
  with status `assigned` and trigger a dashboard data refresh.
- **FR-008**: The system MUST validate all required Assign Task fields before
  submission and display field-level error messages.
- **FR-009**: The supervisor MUST be able to delete **any** report with a confirmation
  dialog; deletion MUST remove the row from the `reports` table. Per-unit scoping
  of deletion rights is out of scope for this iteration.
- **FR-010**: Report deletion MUST optimistically remove the item from the list
  and roll back on failure.
- **FR-011**: All user-facing strings introduced by this feature MUST use
  `easy_localization` keys present in both `en.json` and `ar.json`.
- **FR-012**: All sizes MUST use `flutter_screenutil` extensions; no raw pixel
  values are permitted.
- **FR-013**: All colours MUST reference `AppColors` or `CustomColors`; no inline
  `Color(...)` literals.
- **FR-014**: The Admin Notification card MUST remain unchanged (static placeholder).

### Key Entities

- **DashboardStats**: Aggregated counts — activeUnits, completedTasksToday,
  delayedTasks, reportsToday, taskDonePct, taskInProgressPct, taskDelayedPct.
- **TaskAssignment**: Input DTO — flightId, serviceTypeId, unitId, priority,
  scheduledStart, scheduledEnd, notes (optional).
- **TaskModel**: Existing shared model (reused, no changes).
- **ReportModel**: Existing shared model; deletion via `id`.
- **UnitModel**: Existing shared model; reused for unit selection in Assign Task.
- **FlightModel**: Existing shared model; reused for flight selection.
- **ServiceTypeModel**: Existing shared model; reused for service type selection.

---

## Success Criteria

- **SC-001**: Dashboard stats load within 2 seconds on a standard mobile network;
  skeleton UI is visible during the load window.
- **SC-002**: 100% of stat card values match the corresponding Supabase query
  results at the time of load.
- **SC-003**: Supervisors can complete an Assign Task submission in under 90 seconds
  from tapping the button to seeing the success toast.
- **SC-004**: Assign Task form blocks submission on missing required fields 100%
  of the time (zero false-positive submissions).
- **SC-005**: Report deletion completes (optimistic removal + Supabase confirmation)
  within 1 second on a standard connection.
- **SC-006**: Dashboard passes visual QA in both light and dark modes and in both
  English (LTR) and Arabic (RTL) locales.
- **SC-007**: No hardcoded pixel values, colour literals, or untranslated strings
  remain in the modified files.

---

## Clarifications

### Session 2026-05-17

- Q: How does the Assign Task form open (navigation pattern)? → A: Bottom sheet modal — slides up over the dashboard, no new route needed. Includes a Reset button to clear all fields without closing the sheet.
- Q: Should dashboard stats (Active Units, Tasks, Reports) be scoped to the supervisor's units or airport-wide? → A: Global / airport-wide for now; per-supervisor scoping deferred to a future iteration.
- Q: Which flights should the Assign Task form's flight dropdown include? → A: Today + next 24 hours — covers overnight and early-morning pre-assignment scenarios.
- Q: How should dashboard stats refresh after initial load? → A: Pull-to-refresh only — no polling or Realtime subscriptions in this iteration.
- Q: Which reports can a supervisor delete? → A: Any report in the system for now; per-unit scoping deferred to a future iteration.

## Assumptions

- The `tasks` table Supabase schema and the existing `TaskModel` / `TaskRemoteDs`
  are sufficient; no schema migrations are needed for stats queries.
- "Active Units" counts units where `status = 'active'` in the `units` table.
  Stats are airport-wide (global) — no supervisor-to-unit scoping in this iteration.
- "Delayed Tasks" are tasks where `scheduled_end < now()` AND `status` is not
  `completed` or `cancelled`.
- "Reports Today" counts rows in `reports` where `created_at::date = today`.
- The Assign Task form uses existing `FlightsRemoteDs`, `UnitRemoteDs`, and a new
  `ServiceTypeRemoteDs` (or extends `TaskRemoteDs`) to populate dropdowns.
- The "Report Incident" quick action button is out of scope for this feature (it
  remains a placeholder, same as Admin Notification). Only "Assign Task" is
  implemented.
- The `service_types` table exists in Supabase and `ServiceTypeModel` is already
  available in `lib/core/shared/data/models/service_type_model.dart`.
- The shimmer animation will use the existing `flutter_animate` package (already
  in pubspec) rather than a separate shimmer library.
- Dashboard data (stats + task summary) is served by a single new
  `SupervisorDashboardCubit` registered at route level in `supervisor_scaffold.dart`
  or provided at the tab level depending on Scaffold architecture review.
- Report deletion is surfaced in the supervisor Reports screen (Tab) via swipe-to-
  delete; the dashboard itself does not embed a report list.
