# Research: Supervisor Dashboard Overhaul

## Decision 1 — Dashboard Cubit Scope

**Decision**: `SupervisorDashboardCubit` is provided at the **supervisor scaffold level**
(tab-scoped, via `MultiBlocProvider` in `supervisor_scaffold.dart`), not at route level.

**Rationale**: The dashboard is Tab 0 of the supervisor scaffold. Stats need to load
immediately when the scaffold mounts, and persist while the supervisor switches tabs
and returns. Route-level provision would destroy and recreate the cubit on every tab
switch.

**Alternatives considered**: Route-level `BlocProvider` in `app_routers.dart` — rejected
because `SupervisorScaffold` is a persistent tab shell, not a pushed route.

---

## Decision 2 — Assign Task State Management

**Decision**: A dedicated `AssignTaskCubit` handles the bottom sheet form state
(loading dropdowns, validation, submission). It is instantiated fresh each time the
bottom sheet opens (`BlocProvider` inside `showModalBottomSheet`'s builder, not in DI).

**Rationale**: The form has its own distinct loading/error/success lifecycle that
should not leak into the dashboard stats cubit. A fresh cubit per sheet opening ensures
clean state (no stale flight list from a previous session).

**Alternatives considered**: Embedding form state in `SupervisorDashboardCubit` — rejected
because it mixes two unrelated state lifecycles in one class, violating SRP.

---

## Decision 3 — Stats Queries Strategy

**Decision**: All four dashboard stats are fetched with **four separate Supabase queries**
inside `SupervisorDashboardRemoteDs.fetchDashboardStats()`. The results are aggregated
client-side into `DashboardStatsModel`.

Queries:
1. `units` → `count()` where `status = 'active'`
2. `tasks` → `count()` where `status = 'completed'` AND `scheduled_start` date = today
3. `tasks` → `count()` where `scheduled_end < now()` AND `status NOT IN (completed, cancelled)`
4. `reports` → `count()` where `created_at` date = today

**Rationale**: Supabase's PostgREST does not support multi-table aggregation in a single
request without a custom RPC/view. Four lightweight count queries run fast enough
(<300ms each on indexed columns) and are independently readable.

**Alternatives considered**: A single Supabase RPC function — rejected because it
requires a DB migration and tight coupling to a specific DB implementation; four queries
keep the approach migration-free.

---

## Decision 4 — Task Status Summary (Live Bar)

**Decision**: Task summary percentages are computed **client-side** from a single
`tasks` list query filtered to today's scheduled tasks. Done = `completed`; In-Progress
= `inProgress | assigned | paused`; Delayed = `scheduled_end < now() AND status not
completed/cancelled`.

**Rationale**: Combining with the stats fetch avoids a separate network round-trip.
The list is small (airport has a limited number of tasks per day) so client-side
grouping is negligible cost.

---

## Decision 5 — Flight Dropdown Query

**Decision**: Fetch flights where `scheduled_arrival BETWEEN now() AND now() + 24h`
AND `status NOT IN ('cancelled', 'departed')`, joined with `stands(*)`, ordered by
`scheduled_arrival ASC`. Displayed as `"{flightNumber} — {airline} ({scheduledArrival})"`.

**Rationale**: Covers overnight pre-assignment (Q3 clarification). Cancelled/departed
flights are excluded because assigning tasks to them is nonsensical.

---

## Decision 6 — Unit Filtering in Assign Task

**Decision**: After a service type is selected, the unit dropdown filters to units
where the `service_type_id` matches the selected service type AND `status = 'active'`.
This filter runs **client-side** on the already-fetched full unit list (no re-fetch).

**Rationale**: The unit list is small (<50 rows typically). Fetching once and filtering
locally avoids a round-trip on every service type selection change, keeping the form
responsive.

---

## Decision 7 — Report Deletion

**Decision**: `deleteReport(String id)` is added to the **shared** `ReportRemoteDs`
and `ReportRepo` (not a supervisor-specific DS) because deletion is a general
operation that could be reused if admin role also needs it.

**Rationale**: Keeps the operation co-located with other report operations. Supervisor-
specific access control is enforced by Supabase RLS (supervisor role policy), not the app.

**Alternatives considered**: Supervisor-specific report remote DS — rejected as
premature duplication; `ReportRemoteDs` already has submit/fetch methods.

---

## Decision 8 — Supervisor Reports Cubit (New)

**Decision**: A new `SupervisorReportsCubit` is created in
`lib/modules/supervisor/features/reports/logic/cubit/` to manage the reports list
for the supervisor (fetch all reports, delete with optimistic removal). It is provided
at the supervisor scaffold level alongside `SupervisorDashboardCubit`.

**Rationale**: The supervisor reports screen currently has no cubit at all — it cannot
be made interactive without one. Scaffold-level provision keeps the list alive across
tab switches.

---

## Decision 9 — Shimmer Loading Pattern

**Decision**: Shimmer placeholders are built using `flutter_animate`'s `.shimmer()`
extension (already in pubspec). Skeleton widgets mirror the real card shape. No
additional shimmer package is added.

**Rationale**: `flutter_animate` is already a dependency (CLAUDE.md). Adding a separate
`shimmer` package for the same effect violates the "no extra dependencies for what
existing packages cover" principle.

---

## Decision 10 — Localization Keys Namespace

**Decision**: All new localization keys are prefixed `supervisor_dashboard.*` in both
`en.json` and `ar.json`. Example: `supervisor_dashboard.assign_task`,
`supervisor_dashboard.active_units`, `supervisor_dashboard.reset`.

**Rationale**: Namespacing prevents key collisions with worker or admin modules and
makes it clear which module owns each string.
