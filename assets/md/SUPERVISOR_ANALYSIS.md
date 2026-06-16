# SUPERVISOR_ANALYSIS.md
## GroundScope — Supervisor Module: Complete Technical Analysis & Implementation Roadmap

---

## 1. Module Overview

The Supervisor module lives in `lib/modules/supervisor/` and is accessed via `UserAuthenticatedCheck` when `userModel.role == 'supervisor'`. It currently wraps `SupervisorScaffold` in a `MultiBlocProvider` providing `DashboardCubit` only.

**Scaffold entry point:** `lib/modules/supervisor/core/main_navigation/supervisor_scaffold.dart`
**Tab layout (NavBarStyle.style15, 5 tabs):**

| Index | Icon | Screen Class | Status |
|---|---|---|---|
| 0 | `dashboard_outlined` | `SupervisorDashboardScreen` | ✅ Mostly complete |
| 1 | `analytics_outlined` | `SupervisorReportsScreen` | ❌ Crashes — missing BlocProvider |
| 2 | `add` (FAB-style) | `SupervisorAddReportScreen` | ❌ Placeholder |
| 3 | `assignment_outlined` | `SupervisorTasksScreen` | ❌ Placeholder |
| 4 | `person_outline` | `SupervisorProfileScreen` | ⚠️ Logout/theme only |

---

## 2. Feature-by-Feature Analysis

---

### 2.1 Dashboard

**Path:** `lib/modules/supervisor/features/dashboard/`

#### Data Layer
| File | Status | Notes |
|---|---|---|
| `data/models/dashboard_stats_model.dart` | ✅ Complete | 4 int fields |
| `data/remote/dashboard_remote_ds.dart` | ✅ Complete | `Future.wait` of 4 Supabase count queries |
| `data/repo/dashboard_repo.dart` | ✅ Complete | Abstract interface |
| `data/repo/dashboard_repo_impl.dart` | ✅ Complete | Delegates + rethrows `AppError` |

**Supabase queries:**
- `units` WHERE `status != 'offline'` → Active Units count
- `tasks` WHERE `status = 'completed'` → Completed Tasks count
- `tasks` WHERE `scheduled_end < now()` AND `status != completed/cancelled` → Delayed count
- `reports` WHERE `created_at >= start_of_today_utc` → Reports Today count

#### Logic Layer
| File | Status | Notes |
|---|---|---|
| `logic/cubit/dashboard_cubit.dart` | ✅ Complete | `loadDashboardStats()` |
| `logic/cubit/dashboard_state.dart` | ✅ Complete | Sealed: Initial/Loading/Loaded/Failure |

#### UI Layer
| File | Status | Notes |
|---|---|---|
| `ui/supervisor_dashboard_screen.dart` | ✅ Complete | `BlocBuilder<AuthCubit>` → `_DashboardBody` |
| `ui/widgets/supervisor_app_bar.dart` | ⚠️ Partial | Greeting, avatar, date — notification button is a TODO stub |
| `ui/widgets/supervisor_status_grid.dart` | ✅ Complete | All 4 cards connected to `DashboardCubit`, navigation wired |
| `ui/widgets/supervisor_live_task_summary.dart` | ❌ Hardcoded | Static constants (`_donePct = 0.70`, etc.) — not connected to real data |
| `ui/widgets/supervisor_admin_notification_card.dart` | ❌ Hardcoded | Dummy text, "VIEW REPORT" onTap is a TODO |
| `ui/widgets/supervisor_quick_actions_row.dart` | ❌ Stub | "Report Incident" and "Assign Task" buttons have empty TODO handlers |

#### Missing Functionality
- `SupervisorLiveTaskSummary` needs a new query: count tasks by status globally, compute ratios
- `SupervisorAdminNotificationCard` needs a real notification system or admin-to-supervisor message model
- Quick Actions need route handlers
- Notification bell in app bar needs a destination screen

---

### 2.2 Tasks (Tab 3)

**Path:** `lib/modules/supervisor/features/tasks/`

#### Data Layer
None in this feature directory. Uses shared `TaskRepo.fetchTasksByStatus(TaskStatus)` added during development.

| Shared Method | Status | Notes |
|---|---|---|
| `TaskRemoteDs.fetchTasksByStatus(status)` | ✅ Complete | Full join with flights+stands+service_types |
| `TaskRepo.fetchTasksByStatus(status)` | ✅ Complete | Added to abstract + impl |

#### Logic Layer
| File | Status | Notes |
|---|---|---|
| `logic/cubit/supervisor_task_list_cubit.dart` | ✅ Complete | `loadTasks(TaskStatus)` + `search(String)` |
| `logic/cubit/supervisor_task_list_state.dart` | ✅ Complete | Sealed with `allTasks/filteredTasks/searchQuery` |

#### UI Layer
| File | Status | Notes |
|---|---|---|
| `ui/supervisor_tasks_screen.dart` | ❌ Placeholder | `Center(child: Text('SupervisorTasksScreen'))` |
| `ui/supervisor_task_list_screen.dart` | ✅ Complete | Pushed route — search bar + `TaskCard` list + states |

#### Missing Functionality
- `SupervisorTasksScreen` (Tab 3) is a full placeholder — the main task management hub is entirely unbuilt
- **Delayed Tasks card** uses `TaskStatus.completed` as `filterStatus` — this is a **known placeholder**. Delayed tasks require a different query (not a simple status filter) — needs a dedicated cubit method or a new `TaskFilter` enum
- No task creation flow
- No task assignment to unit flow
- No individual task detail view for supervisors (worker's `TaskDetailsScreen` is role-specific with start/pause/complete actions)
- No "all tasks" view with status filter strip

---

### 2.3 Units (Pushed Route Only)

**Path:** `lib/modules/supervisor/features/units/`

#### Data Layer
Uses shared `UnitRepo.fetchAllUnits()` added during development.

| Shared Method | Status | Notes |
|---|---|---|
| `UnitRemoteDs.fetchAllUnits()` | ✅ Complete | Selects `*, service_types(name)` ordered by name |
| `UnitRepo.fetchAllUnits()` | ✅ Complete | Added to abstract + impl |

#### Logic Layer
| File | Status | Notes |
|---|---|---|
| `logic/cubit/units_list_cubit.dart` | ✅ Complete | `loadUnits()` + `search(String)` |
| `logic/cubit/units_list_state.dart` | ✅ Complete | Sealed with `allUnits/filteredUnits/searchQuery` |

#### UI Layer
| File | Status | Notes |
|---|---|---|
| `ui/units_screen.dart` | ✅ Complete | Search bar + `_UnitCard` list + `_UnitStatusBadge` + empty/error states |

#### Route
`Routes.supervisorUnitsScreen` → `app_routers.dart` provides `UnitsListCubit` + calls `loadUnits()`.

#### Missing Functionality
- Unit detail screen (tap a unit → see members, shift info, active tasks)
- No unit status management (set unit online/offline)
- No member roster per unit from this screen

---

### 2.4 Reports (Tab 1 + Pushed Route)

**Path:** `lib/modules/supervisor/features/reports/`

#### Critical Bug — Tab 1 Will Crash
`SupervisorScaffold._buildScreens()` places `const SupervisorReportsScreen()` at index 1. This screen uses `BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>`. But `SupervisorReportsCubit` is **only provided in the router case** for the pushed route (`supervisorReportsScreen`). When the user taps Tab 1 directly, Flutter will throw `ProviderNotFoundException`. **This must be fixed before any release build.**

#### Data Layer
| Shared Method | Status | Notes |
|---|---|---|
| `ReportRemoteDs.fetchReportsToday()` | ✅ Complete | `created_at >= start_of_today_utc` DESC |
| `ReportRepo.fetchReportsToday()` | ✅ Complete | Added to abstract + impl |

#### Logic Layer
| File | Status | Notes |
|---|---|---|
| `logic/cubit/supervisor_reports_cubit.dart` | ✅ Complete | `loadReportsToday()` + `search(String)` |
| `logic/cubit/supervisor_reports_state.dart` | ✅ Complete | Sealed with allReports/filteredReports/searchQuery |

#### UI Layer
| File | Status | Notes |
|---|---|---|
| `ui/supervisor_reports_screen.dart` | ✅ Complete | Today banner + search bar + `ReportCard` list + states |

#### Missing Functionality
- Tab 1 is missing a cubit provision — crashes at runtime
- No "All Reports" view (supervisor may need to see historical reports)
- No report status update (acknowledge, mark in-progress, resolve) — supervisor action
- No report detail screen for supervisor
- `SupervisorAdminNotificationCard` on the dashboard is not connected to the reports system

---

### 2.5 Add Report (Tab 2)

**Path:** `lib/modules/supervisor/features/add_report/`

| File | Status | Notes |
|---|---|---|
| `supervisor_add_report_screen.dart` | ❌ Placeholder | `Center(child: Text('AddR'))` |

The worker's `AddReportCubit` is tied to `userService.getUser()` and `user.unitId` — it fetches tasks only for the supervisor's assigned unit. Supervisors don't have `unitId` in their `UserModel`. A supervisor's add-report flow requires fetching **all tasks** (or tasks from any unit) as the source list.

#### Missing Functionality
- Entire add-report form for supervisor role
- A new `SupervisorAddReportCubit` that fetches all tasks (using `TaskRemoteDs.fetchTasksByStatus` or a new `fetchAllTasks` method)
- Or: reuse `AddReportCubit` but replace `fetchWorkerTasks(unitId)` with a global task fetch

---

### 2.6 Notifications

**Path:** `lib/modules/supervisor/features/notifications/`

| File | Status | Notes |
|---|---|---|
| `ui/widgets/supervisor_notifications_screen.dart` | ❌ Empty | File has 1 blank line — no class defined |

The notification bell in `SupervisorAppBar` calls an empty lambda. No route, no screen, no data model for notifications exists anywhere in the project.

#### Missing Functionality
- `SupervisorNotificationsScreen` class (currently not even defined)
- Route `supervisorNotificationsScreen`
- Notification data model (push notifications or Supabase real-time subscriptions)
- Bell badge showing unread count

---

### 2.7 Profile (Tab 4)

**Path:** `lib/modules/supervisor/features/profile/`

| File | Status | Notes |
|---|---|---|
| `ui/supervisor_profile_screen.dart` | ⚠️ Stub | Logout, switch language, switch theme — no profile data |

The worker's `ProfileCubit` uses `UnitRepo.fetchUnitById(unitId)` and `UnitMemberRepo.fetchUnitMembers(unitId)` — both require `unitId`, which supervisors don't have. A supervisor profile screen would show supervisor-specific info from `UserModel` (name, role, email, phone).

#### Missing Functionality
- Supervisor profile info display (name, role, contact)
- Settings section (theme, language, logout) — partially exists
- No `AuthCubit`-derived user info displayed
- No profile image support

---

## 3. Shared Component Reuse Audit

### Models available for Supervisor use (no changes needed)
| Model | Used by Supervisor? | Notes |
|---|---|---|
| `TaskModel` + `TaskStatus` + `TaskPriority` | ✅ Yes | TaskListScreen, Dashboard |
| `ReportModel` + `ReportType` + `ReportSeverity` + `ReportStatus` | ✅ Yes | ReportsScreen |
| `UnitModel` / `UnitProfileModel` + `UnitStatus` | ✅ Yes | UnitsScreen |
| `UnitMemberModel` | ❌ Not yet | Could be used in unit detail screen |
| `FlightModel` | ❌ Not yet | Could be used in task detail/creation |

### Shared widgets immediately reusable
| Widget | Supervisor use case |
|---|---|
| `CustomAppBar` | All pushed screens ✅ |
| `ErrorScreen` | All pushed screens ✅ |
| `TaskCard` | `SupervisorTaskListScreen` ✅ |
| `TaskListEmptyState` | `SupervisorTaskListScreen` ✅ |
| `ReportCard` | `SupervisorReportsScreen` ✅ |
| `ReportsEmptyState` | `SupervisorReportsScreen` ✅ |
| `InfoCard` + `InfoRowData` | Profile screen, unit detail |
| `CustomTextFormField` | Add report form |
| `AppDialogs` | Confirm dialogs for task assignment |
| `OverlayLoader` | Submission states |

### Shared repos with methods already covering supervisor needs
| Repo | Supervisor method | Status |
|---|---|---|
| `TaskRepo` | `fetchTasksByStatus(TaskStatus)` | ✅ Added |
| `UnitRepo` | `fetchAllUnits()` | ✅ Added |
| `ReportRepo` | `fetchReportsToday()` | ✅ Added |
| `ReportRepo` | `submitReport(...)` | ✅ Exists — reusable for supervisor add-report |
| `UnitMemberRepo` | `fetchUnitMembers(unitId)` | ✅ Exists — usable in unit detail screen |

### Worker cubits NOT reusable for supervisor
| Cubit | Why not |
|---|---|
| `AddReportCubit` | Uses `user.unitId` → supervisor has no unitId; fetches per-unit tasks |
| `ProfileCubit` | Uses `unitId` for unit + member lookup — supervisor has no unit |
| `ReportsCubit` | Calls `getMyReports(user.id)` — per-worker view only |
| `HomeCubit` | Per-unit task list — not applicable |

---

## 4. Feature Completion Matrix

| Feature | Status | Missing Requirements | Priority | Effort |
|---|---|---|---|---|
| Dashboard — Stats Grid | ✅ Complete | — | — | — |
| Dashboard — App Bar | ⚠️ Partial | Notification navigation | High | S |
| Dashboard — Live Task Summary | ❌ Missing | Real data connection, new aggregate query | High | M |
| Dashboard — Admin Notification Card | ❌ Hardcoded | Notification model, Supabase query | Medium | L |
| Dashboard — Quick Actions | ❌ Stub | Route handlers for Report + Assign Task | High | S |
| Reports Tab (Tab 1) | ❌ Crash | BlocProvider missing in scaffold | **Critical** | S |
| Reports — Today view (pushed) | ✅ Complete | — | — | — |
| Reports — Historical / All reports | ❌ Missing | New query, new cubit method | Medium | M |
| Reports — Status update (ack/resolve) | ❌ Missing | `report_remote_ds` update method, cubit action | High | M |
| Tasks Tab (Tab 3) | ❌ Placeholder | Entire task management screen | High | XL |
| Tasks — Completed list (pushed) | ✅ Complete | — | — | — |
| Tasks — Delayed list (pushed) | ❌ Wrong filter | Uses completed as placeholder; needs custom query | High | M |
| Tasks — Task detail view | ❌ Missing | Supervisor-scoped detail (read + assign) | High | L |
| Tasks — Task creation | ❌ Missing | Full form: flight, unit, service type, time | Low | XL |
| Units — List screen (pushed) | ✅ Complete | — | — | — |
| Units — Unit detail screen | ❌ Missing | Members roster, active tasks for unit | Medium | L |
| Add Report Tab (Tab 2) | ❌ Placeholder | Full form, supervisor-scoped task list | High | L |
| Notifications Tab (implied) | ❌ Empty | Screen class doesn't exist | Medium | L |
| Notifications — Bell navigation | ❌ Stub | Route + screen | Medium | M |
| Profile Tab (Tab 4) | ⚠️ Stub | Profile data display from `UserModel` | Medium | M |

**Effort scale:** S = < 2h, M = 2–4h, L = 4–8h, XL = 8h+

---

## 5. Recommended Implementation Roadmap

---

### Phase 1 — Critical Foundation (blockers + crashes)

These items prevent the app from being demo-able or cause runtime exceptions.

#### 1.1 Fix Reports Tab crash — provide `SupervisorReportsCubit` in scaffold

**Files to modify:**
- `lib/core/auth/ui/user_authenticated_check.dart`

**Change:** Add `SupervisorReportsCubit` to the supervisor `MultiBlocProvider`, calling `loadReportsToday()` on create — same pattern as `DashboardCubit`.

```dart
'supervisor' => MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => getIt<DashboardCubit>()..loadDashboardStats()),
    BlocProvider(create: (_) => getIt<SupervisorReportsCubit>()..loadReportsToday()),
  ],
  child: const SupervisorScaffold(),
),
```

**Risk:** None — identical pattern to worker tab cubits.

---

#### 1.2 Fix Delayed Tasks card — implement correct query

**Files to modify:**
- `lib/core/shared/data/remote/task_remote_ds.dart` — add `fetchDelayedTasks()`
- `lib/core/shared/data/repo/task_repo.dart` — add abstract method
- `lib/core/shared/data/repo/task_repo_impl.dart` — implement
- `lib/modules/supervisor/features/tasks/logic/cubit/supervisor_task_list_cubit.dart` — add `loadDelayedTasks()`
- `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart` — change Delayed Tasks `filterStatus` arg

**New query in `TaskRemoteDs`:**
```dart
Future<List<TaskModel>> fetchDelayedTasks() async {
  final now = DateTime.now().toUtc().toIso8601String();
  final response = await client.from('tasks')
    .select('*, service_types(*), flights(*, stands(*))')
    .lt('scheduled_end', now)
    .neq('status', 'completed')
    .neq('status', 'cancelled')
    .order('scheduled_end', ascending: true);
  return (response as List).map(TaskModel.fromMap).toList();
}
```

**New route arg approach:** Add a `TaskFilterType` enum (`completed`, `delayed`) and pass it as a route argument. The cubit dispatches to the correct method based on it.

**Risk:** Low — isolated to the task feature.

---

#### 1.3 Wire Quick Actions buttons

**Files to modify:**
- `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_quick_actions_row.dart`
- `lib/core/router/routes.dart` (if new routes needed)
- `lib/core/router/app_routers.dart`

**Change:** "Report Incident" → push `supervisorAddReportScreen`. "Assign Task" → push `supervisorTasksScreen` or a task creation flow.

**Risk:** Low for navigation wiring. Dependent on Phase 2 for the destination screens to be real.

---

### Phase 2 — Core Supervisor Workflows

The primary supervisor job is managing tasks and units.

#### 2.1 SupervisorTasksScreen (Tab 3) — Task management hub

**New files to create:**
```
supervisor/features/tasks/
├── data/
│   └── (reuse shared TaskRepo — no new files)
└── logic/cubit/
    ├── supervisor_tasks_cubit.dart   # loads all tasks, supports status filter strip
    └── supervisor_tasks_state.dart
ui/
    ├── supervisor_tasks_screen.dart  # full screen (replaces placeholder)
    └── widgets/
        └── supervisor_task_filter_strip.dart  # status filter (pending/inProgress/completed/delayed)
```

**Files to modify:**
- `lib/core/di/dependency_injection.dart` — register `SupervisorTasksCubit`
- `lib/core/auth/ui/user_authenticated_check.dart` — add `SupervisorTasksCubit` to MultiBlocProvider (tab-level cubit)
- `lib/core/shared/data/remote/task_remote_ds.dart` — add `fetchAllTasks()` (no status filter, all tasks for supervisor)
- `lib/core/shared/data/repo/task_repo.dart` + `task_repo_impl.dart` — expose `fetchAllTasks()`

**Reusable components:**
- `TaskCard` — already used in `SupervisorTaskListScreen`, use directly
- `TaskListEmptyState` — reuse directly
- `ErrorScreen` — reuse directly

**State structure:**
```dart
class SupervisorTasksLoaded extends SupervisorTasksState {
  final List<TaskModel> allTasks;
  final List<TaskModel> filteredTasks;
  final TaskStatus? selectedFilter;  // null = show all
  final String searchQuery;
}
```

**Risk:** Supabase RLS — supervisor must have SELECT on all tasks. If RLS is per-unit, the query will return empty or partial results.

---

#### 2.2 SupervisorAddReportScreen (Tab 2) — Report submission

**New files to create:**
```
supervisor/features/add_report/
└── logic/cubit/
    ├── supervisor_add_report_cubit.dart
    └── supervisor_add_report_state.dart
ui/
    └── supervisor_add_report_screen.dart   # replaces placeholder
```

**Strategy:** Nearly identical to worker's `AddReportCubit` and `AddReportScreen`. Key difference: fetch all tasks (not per-unit). Reuse `ReportRepo.submitReport(...)` directly — no new data layer needed.

**Files to modify:**
- `lib/core/di/dependency_injection.dart` — register `SupervisorAddReportCubit`
- `lib/core/auth/ui/user_authenticated_check.dart` — add to MultiBlocProvider

**Reusable components from worker:**
- Worker's `AddReportScreen` UI widgets can be studied and replicated (form fields, image picker, type/severity selectors)
- `ReportRepo.submitReport(...)` — used directly

**Risk:** `image_picker` permissions must be configured per platform. Already done for worker, so no additional setup needed.

---

#### 2.3 SupervisorProfileScreen (Tab 4) — Profile display

**Files to modify:**
- `lib/modules/supervisor/features/profile/ui/supervisor_profile_screen.dart` — replace stub with real UI

**New files to create:**
- None — no new data layer needed. User info comes from `AuthCubit`'s `AuthSuccess` state which holds `UserModel`.

**Strategy:** Use `context.watch<AuthCubit>().state` (already available globally) to get `UserModel`. Display name, role, email. Reuse `InfoCard` + `InfoRowData` for the data rows.

**Reusable components:**
- `InfoCard` + `InfoRowData` — display supervisor metadata
- `CustomTextButton` — already used for logout/language/theme

**Risk:** None — purely UI, uses existing state.

---

### Phase 3 — Reporting and Monitoring

#### 3.1 Live Task Summary — connect to real data

**Files to modify:**
- `lib/modules/supervisor/features/dashboard/logic/cubit/dashboard_cubit.dart` — add task ratio calculation
- `lib/modules/supervisor/features/dashboard/data/models/dashboard_stats_model.dart` — add `taskRatios` fields
- `lib/modules/supervisor/features/dashboard/data/remote/dashboard_remote_ds.dart` — add counts per status
- `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_live_task_summary.dart` — remove hardcoded constants, use `DashboardCubit`

**New query approach:** Add status-grouped counts to `DashboardRemoteDs.fetchDashboardStats()`. Fetch counts for `completed`, `inProgress`, `pending` in `Future.wait`. Compute ratios in the model.

**Risk:** One more round-trip or additional parallel query — negligible performance impact.

---

#### 3.2 Report status updates (acknowledge / resolve)

**New files to create:**
```
supervisor/features/reports/
└── logic/cubit/ (add method to existing supervisor_reports_cubit.dart)
```

**Files to modify:**
- `lib/core/shared/data/remote/report_remote_ds.dart` — add `updateReportStatus(id, ReportStatus)`
- `lib/core/shared/data/repo/report_repo.dart` + `report_repo_impl.dart` — expose method
- `lib/modules/supervisor/features/reports/logic/cubit/supervisor_reports_cubit.dart` — add `updateStatus(String id, ReportStatus)`
- `lib/modules/supervisor/features/reports/ui/supervisor_reports_screen.dart` — add tap handler on `ReportCard`

**Risk:** RLS — supervisor must have UPDATE permission on `reports`.

---

#### 3.3 Unit detail screen

**New files to create:**
```
supervisor/features/units/
└── ui/
    └── unit_detail_screen.dart   # shows UnitProfileModel + members + active tasks
```

**Files to modify:**
- `lib/core/router/routes.dart` — add `supervisorUnitDetailScreen`
- `lib/core/router/app_routers.dart` — add case
- `lib/modules/supervisor/features/units/ui/units_screen.dart` — add `onTap` to `_UnitCard`

**Reusable components:**
- `ProfileUnitInfoSection` from worker profile — shows unit avatar, name, service type, status badge, shifts, aircraft. Import directly.
- `UnitMemberRepo.fetchUnitMembers(unitId)` — already registered in DI

**Risk:** Low — all data layer exists.

---

#### 3.4 Notifications screen

**New files to create:**
```
supervisor/features/notifications/
└── ui/
    └── supervisor_notifications_screen.dart  # replaces empty file
```

**Files to modify:**
- `lib/core/router/routes.dart` — add `supervisorNotificationsScreen`
- `lib/core/router/app_routers.dart` — add case
- `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_app_bar.dart` — wire notification bell

**Notification strategy (two options):**
- **Option A (Simple):** Show recent reports (critical/high severity) as notification items. Reuse `ReportRepo.fetchReportsToday()`. No new backend model needed.
- **Option B (Full):** Supabase real-time subscription on `reports` table with INSERT listener. Requires `supabase.channel()` setup. Higher complexity.

**Recommendation:** Start with Option A to unblock the UI. Upgrade to Option B in Phase 4.

**Risk:** Option B requires real-time Supabase configuration and platform-level notification setup.

---

### Phase 4 — UX Improvements and Polish

#### 4.1 Localization — all supervisor strings

**Current state:** All supervisor UI strings are hardcoded English literals (`'Active Units'`, `'Reports Today'`, `'Search units...'`, etc.). CLAUDE.md requires `.tr()` on all user-facing strings.

**Files to modify:** Every supervisor UI file.

**Files to create:**
- `assets/lang/en.json` — add `supervisor.*` key namespace
- `assets/lang/ar.json` — add Arabic translations for all keys

**Key namespaces needed:**
```json
"supervisor": {
  "dashboard": { "active_units": "...", "completed_tasks": "...", ... },
  "units": { "search_hint": "...", "available": "...", "busy": "...", ... },
  "tasks": { "search_hint": "...", "filter_all": "...", ... },
  "reports": { "search_hint": "...", "reports_today": "...", ... },
  "profile": { ... }
}
```

**Risk:** Requires Arabic RTL verification for all supervisor screens.

---

#### 4.2 Supervisor Task Detail Screen

**New files to create:**
```
supervisor/features/task_detail/
├── ui/
│   └── supervisor_task_detail_screen.dart
└── (reuse TaskDetailsRepo + TaskRepo from shared)
```

Supervisor task detail is read-only (no start/pause/complete actions). Shows task metadata, flight, checklist progress, assigned unit, pause history.

**Reusable components:**
- `TaskDetailsRepo` + `TaskDetailsCubit` — already exist; supervisor can reuse the cubit but the screen shows different actions (assign unit, only supervisor can change priority/status)
- Worker's `task_details_header.dart`, `task_details_task_meta_section.dart` — can be imported directly

---

#### 4.3 Pull-to-refresh on Dashboard

**Files to modify:**
- `lib/modules/supervisor/features/dashboard/ui/supervisor_dashboard_screen.dart`

**Change:** The `RefreshIndicator` currently has `Future.delayed(Duration(seconds: 1))` as a placeholder. Wire it to `context.read<DashboardCubit>().loadDashboardStats()` and `context.read<SupervisorReportsCubit>().loadReportsToday()`.

---

#### 4.4 Admin Notification Card — real data

**Files to modify:**
- `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_admin_notification_card.dart`

This widget should show the most recent critical/high-severity open report. Reuse `SupervisorReportsCubit` (already provided) — add a getter `latestCriticalReport` to `SupervisorReportsLoaded`.

---

## 6. Architecture Compliance Audit

### MVVM + Cubit ✅
All implemented cubits follow the pattern correctly: sealed state, `part of` state file, `AppError` in failure states.

### Repository Pattern ✅
No UI/cubit directly touches `supabase.client`. All new queries go through `RemoteDs → Repo → Cubit`.

### Dependency Injection ✅
All cubits registered as `factory`, all data sources and repos as `lazySingleton`. Pattern consistent.

### Feature Folder Structure ✅
All new supervisor features follow `data/logic/ui` layout as specified in CLAUDE.md.

### ScreenUtil Sizing ✅
All new widgets use `rw/rh/rr/rf`. No raw pixel values introduced.

### Localization ❌
All supervisor strings are hardcoded English. Phase 4 must address this before production.

### Design System ✅
All new widgets use `AppTextStyles`, `AppColors`, `CustomColors` from theme tokens. No inline `TextStyle(...)` or raw `Color(0x...)`.

### Cross-module Isolation ✅
Supervisor UI imports from worker are limited to generic widgets (`TaskCard`, `ReportCard`, `TaskListEmptyState`, `ReportsEmptyState`) — not cubits or screens.

---

## 7. Known Bugs and Technical Debt

| ID | Severity | Location | Description | Fix |
|---|---|---|---|---|
| BUG-01 | **Critical** | `supervisor_scaffold.dart` + `user_authenticated_check.dart` | Reports Tab (Tab 1) crashes: `SupervisorReportsScreen` uses `BlocBuilder<SupervisorReportsCubit>` but cubit is not provided for tab context | Add to `MultiBlocProvider` in `UserAuthenticatedCheck` |
| BUG-02 | **High** | `supervisor_status_grid.dart` L75 | Delayed Tasks card passes `filterStatus: TaskStatus.completed` — shows completed tasks, not delayed | Implement `fetchDelayedTasks()` and new `TaskFilterType` enum |
| BUG-03 | **Medium** | `supervisor_live_task_summary.dart` | Static constants `_donePct`, `_inProgressPct`, `_delayPct` — never reflect real data | Connect to `DashboardCubit` with real status counts |
| BUG-04 | **Medium** | `supervisor_admin_notification_card.dart` | Hardcoded text "New safety report submitted for Stand 4B", "VIEW REPORT" is a dead TODO | Connect to latest critical report from `SupervisorReportsCubit` |
| BUG-05 | **Medium** | `supervisor_quick_actions_row.dart` | Both action buttons have empty `onTap` handlers | Wire to supervisor add-report and tasks screens |
| BUG-06 | **Medium** | `supervisor_app_bar.dart` | Notification bell `onTap: () {}` — dead | Wire to `supervisorNotificationsScreen` route |
| BUG-07 | **Low** | `supervisor_dashboard_screen.dart` | `RefreshIndicator.onRefresh` uses `Future.delayed(1s)` placeholder | Wire to `DashboardCubit.loadDashboardStats()` |
| DEBT-01 | **Medium** | All supervisor UI files | All user-facing strings are hardcoded English literals — violates CLAUDE.md localization rule | Add `supervisor.*` keys to `en.json`/`ar.json` and apply `.tr()` |
| DEBT-02 | **Low** | `unit_repo_impl.dart` | `getUnitData` and `fetchUnitById` use `ErrorHandler.handle(e)` without `throw` keyword — return type is `UnitModel` but returns `void` on error path | Add `throw` before `ErrorHandler.handle(e)` |

---

## 8. File Index — Current State

```
lib/modules/supervisor/
├── core/main_navigation/
│   └── supervisor_scaffold.dart              ✅ Complete (5-tab nav)
│
└── features/
    ├── dashboard/
    │   ├── data/
    │   │   ├── models/dashboard_stats_model.dart     ✅ Complete
    │   │   ├── remote/dashboard_remote_ds.dart       ✅ Complete
    │   │   └── repo/
    │   │       ├── dashboard_repo.dart               ✅ Complete
    │   │       └── dashboard_repo_impl.dart          ✅ Complete
    │   ├── logic/cubit/
    │   │   ├── dashboard_cubit.dart                  ✅ Complete
    │   │   └── dashboard_state.dart                  ✅ Complete
    │   └── ui/
    │       ├── supervisor_dashboard_screen.dart       ✅ Complete
    │       └── widgets/
    │           ├── supervisor_app_bar.dart            ⚠️ Bell stub
    │           ├── supervisor_status_grid.dart        ✅ Complete
    │           ├── supervisor_live_task_summary.dart  ❌ Hardcoded
    │           ├── supervisor_admin_notification_card ❌ Hardcoded
    │           └── supervisor_quick_actions_row.dart  ❌ Empty handlers
    │
    ├── tasks/
    │   ├── logic/cubit/
    │   │   ├── supervisor_task_list_cubit.dart        ✅ Complete
    │   │   └── supervisor_task_list_state.dart        ✅ Complete
    │   └── ui/
    │       ├── supervisor_tasks_screen.dart           ❌ Placeholder
    │       └── supervisor_task_list_screen.dart       ✅ Complete (pushed)
    │
    ├── units/
    │   ├── logic/cubit/
    │   │   ├── units_list_cubit.dart                  ✅ Complete
    │   │   └── units_list_state.dart                  ✅ Complete
    │   └── ui/
    │       └── units_screen.dart                      ✅ Complete (pushed)
    │
    ├── reports/
    │   ├── logic/cubit/
    │   │   ├── supervisor_reports_cubit.dart           ✅ Complete
    │   │   └── supervisor_reports_state.dart           ✅ Complete
    │   └── ui/
    │       └── supervisor_reports_screen.dart          ✅ Complete (crashes as tab)
    │
    ├── add_report/
    │   └── supervisor_add_report_screen.dart           ❌ Placeholder
    │
    ├── notifications/
    │   └── ui/widgets/
    │       └── supervisor_notifications_screen.dart    ❌ Empty file (no class)
    │
    └── profile/
        └── ui/
            └── supervisor_profile_screen.dart          ⚠️ Logout/theme only
```

---

## 9. Implementation Priority Queue

Execute in this order to maximize stability and unblock further development:

```
[P0 — Fix crashes]
  BUG-01: Add SupervisorReportsCubit to UserAuthenticatedCheck MultiBlocProvider
  BUG-02: Implement fetchDelayedTasks() and wire Delayed Tasks card correctly

[P1 — Make tabs functional]
  2.1: SupervisorTasksScreen (Tab 3) — full task list with filter strip
  2.2: SupervisorAddReportScreen (Tab 2) — report submission form
  2.3: SupervisorProfileScreen (Tab 4) — display UserModel data
  1.3: Quick Actions route wiring

[P2 — Supervisor core workflows]
  3.3: Unit detail screen (tap unit → members + tasks)
  3.2: Report status update (acknowledge / resolve)
  3.4: Notifications screen (Option A: recent critical reports)

[P3 — Data completeness]
  3.1: Live Task Summary real data
  BUG-03/04: Dashboard widgets connected to live state
  4.4: Admin notification card — real latest report

[P4 — Polish]
  4.1: Localization — all supervisor strings
  4.2: Supervisor Task Detail Screen
  4.3: Pull-to-refresh on Dashboard
  DEBT-02: Fix UnitRepoImpl error handling
```
