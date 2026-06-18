# Supervisor Module — Status

> Audited: 2026-06-18 · 55 Dart files read

---

## What's Built

| Tab | Feature | Status |
|---|---|---|
| 0 | Dashboard | ✅ Full |
| 1 | Tasks | ✅ Full |
| 2 | Units | ✅ Full |
| 3 | Reports | ✅ Full |
| 4 | Profile | ✅ Full (with caveats — see below) |
| — | Notifications | ❌ Empty file, no tab |

### Navigation
`SupervisorScaffold` — `IndexedStack` + `BottomNavigationBar`, 5 tabs. `SupervisorNavCubit` handles index. All 5 cubits provided via `MultiBlocProvider` in `UserAuthenticatedCheck`.

### Dashboard (Tab 0)
- Stats grid: active tasks, pending requests, available units, open reports
- Service requests list (top 5): flight info, status badge, assign/details buttons
- Units preview (top 3): name, shift, status
- `AssignUnitBottomSheet`: 2-step flow — schedule/priority/checklist → unit picker with search
- `RefreshIndicator` for manual reload
- `onServiceRequestAssigned` removes request from list optimistically

### Tasks (Tab 1)
- Full task list fetched with flight/unit/service-type joins
- `FilterPills` (all · pending · in_progress · completed · cancelled) + `SearchWithCounter`
- `SupervisorTaskCard`: left accent bar (4px, status color), wrapped in `IntrinsicHeight`
- `RefreshIndicator`

### Units (Tab 2)
- Realtime stream via Supabase `.stream()` (status updates only)
- Initial fetch includes `unit_members` join; cubit merges member data on each stream event
- `FilterPills` (all · available · busy · offline) + `SearchWithCounter`
- `UnitStatusCard` → `UnitDetailBottomSheet` (InfoCard + crew list with initials)
- **No `RefreshIndicator`** — realtime handles updates
- `_subscription?.cancel()` in `cubit.close()`

### Reports (Tab 3)
- Full report list with flights/reporter/tasks inner-join filtered by `service_type_id`
- `FilterPills` (all · open · acknowledged · resolved) + `SearchWithCounter`
- `SupervisorReportCard`: top accent bar (4px, severity color), per-card loading spinner
- Optimistic acknowledge/resolve: state updated immediately, network call follows
- `actionReportId` uses sentinel-object pattern for nullable `copyWith` clearing
- `AppDialogs.showConfirm` before every action
- `BlocListener` for error snackbar

### Profile (Tab 4)
- Reads from `UserService.getUser()` — no network call
- `ProfileHeader`: gradient avatar with initials (max 2), name, role tag
- `ProfileInfoCard`: email, phone, service type, units managed (via shared `InfoCard`)
- `SupervisorSettingsTiles`:
  - Language → `switchLanguage(context)`
  - Dark Mode → `switchTheme(context)`
  - Notifications → no-op (Phase 8)
  - Logout → `AppDialogs.showConfirm` → `AuthCubit.logout()`

---

## Deviations from Spec

| # | Where | Spec | Actual | Severity |
|---|---|---|---|---|
| 1 | `profile_info_card.dart` | Show `user.serviceTypeName` | Shows `user.serviceTypeId` (raw UUID) | Medium — readable but ugly |
| 2 | `supervisor_tasks_screen.dart` header | Show service type name | Shows `user.serviceTypeId` | Low — header subtitle only |
| 3 | `supervisor_units_screen.dart` header | Show service type name | Shows `user.serviceTypeId` | Low — header subtitle only |
| 4 | `dashboard_remote_ds.dart` | Pending requests = tasks with `unit_id IS NULL` | Queries `flight_service_requests` table | **Critical** — this table does not exist in the DB; will throw at runtime |
| 5 | `assign_unit_cubit.dart` | `assignUnit()` updates `tasks.unit_id` | `createTask()` inserts a new task row + updates `flight_service_requests` | **Critical** — tied to #4; wrong table |
| 6 | `profile_header.dart` | Gradient `[primary200, primary300, primary400]` | Uses `AppColors.primaryGradient` = `[primary100, primary200, primary300]` | Visual only — slightly lighter |
| 7 | `unitCount` / `memberCount` | "Enrich later" | Hardcoded `0` | Acceptable — per spec intent |

> **Items 4 & 5 are the highest-risk deviations.** The dashboard will throw a Postgrest 404/42P01 error at runtime because `flight_service_requests` does not exist. The fix was designed in a prior session (query `tasks` where `status='pending'` and `unit_id IS NULL`) but the dashboard remote DS was never updated to use it.

---

## Not Built Yet

| Feature | Notes |
|---|---|
| Notifications tab | `supervisor_notifications_screen.dart` exists but is an empty file; no tab in scaffold for it |
| Profile unit/member count enrichment | `unitCount` and `memberCount` always show `0`; needs a Supabase query to count units/members by `service_type_id` |
| Task detail view | No pushed screen for tapping a task card — cards are non-interactive beyond display |
| Report detail view | No full-screen report detail; only inline card actions |
| Supervisor → Worker realtime status | Dashboard units preview shows current status but no push updates (only dashboard refresh) |

---

## Dead Code (safe to delete)

These files exist in `features/dashboard/ui/widgets/` but are **not imported anywhere** in the supervisor dashboard screen:

- `supervisor_status_grid.dart` — placeholder with hard-coded data and TODO comments
- `supervisor_live_task_summary.dart` — hard-coded 70%/20%/10% progress bar
- `supervisor_quick_actions_row.dart` — two buttons with TODO navigate calls
- `supervisor_app_bar.dart` — alternate app bar, hard-coded English greeting
- `supervisor_admin_notification_card.dart` — static example card, not wired
