# Supervisor Module Reference
> GroundScope · Role: Supervisor · Version 1.0  
> This document is the single source of truth for rebuilding the Supervisor module from scratch.  
> All design tokens, naming conventions, and architecture rules are inherited from `CLAUDE.md` and `design_system.md`.

---

## Table of Contents

1. [Role Overview](#1-role-overview)
2. [Folder Structure](#2-folder-structure)
3. [Shared Dependencies](#3-shared-dependencies)
4. [Feature Breakdown](#4-feature-breakdown)
   - [4.1 Dashboard (Tab 0)](#41-dashboard-tab-0)
   - [4.2 Tasks (Tab 1)](#42-tasks-tab-1)
   - [4.3 Units (Tab 2)](#43-units-tab-2)
   - [4.4 Reports (Tab 3)](#44-reports-tab-3)
   - [4.5 Profile (Tab 4)](#45-profile-tab-4)
5. [Background Services](#5-background-services)
6. [State Management Contracts](#6-state-management-contracts)
7. [Navigation & Routing](#7-navigation--routing)
8. [UI/UX Design Specifications](#8-uiux-design-specifications)
9. [Global Filtering UI Standard](#9-global-filtering-ui-standard)
10. [DI Registration Checklist](#10-di-registration-checklist)

---

## 1. Role Overview

A Supervisor is scoped to **one service type** (e.g. Fueling). Every piece of data they see — flights, units, tasks, reports — is filtered by `users.service_type_id`. This scoping is enforced at the database level via Supabase RLS and must never be bypassed in the app layer.

**Core job:** Bridge between Admin (who sends service requests) and Workers (who execute tasks).

| Capability | Details |
|---|---|
| View service requests | Incoming from Admin per flight, filtered to their service type |
| Assign units to tasks | Pick an available unit → create a `tasks` record |
| Monitor live task status | Real-time updates from all units under their service type |
| Acknowledge / resolve reports | Reports submitted by their workers |
| View unit status board | Current availability of each unit |
| Profile & settings | Language, theme, logout |

**Data access rule:** Every Supabase query in this module must use the authenticated user's `service_type_id`. Never query without this filter.

---

## 2. Folder Structure

```
lib/modules/supervisor/
├── core/
│   └── main_navigation/
│       ├── cubit/
│       │   ├── supervisor_nav_cubit.dart
│       │   └── supervisor_nav_state.dart
│       ├── model/
│       │   └── supervisor_nav_item.dart
│       └── ui/
│           └── supervisor_scaffold.dart
│
└── features/
    ├── dashboard/
    │   ├── data/
    │   │   ├── remote/dashboard_remote_ds.dart
    │   │   └── repo/
    │   │       ├── dashboard_repo.dart
    │   │       └── dashboard_repo_impl.dart
    │   ├── logic/
    │   │   └── cubit/
    │   │       ├── dashboard_cubit.dart
    │   │       └── dashboard_state.dart
    │   └── ui/
    │       ├── dashboard_screen.dart
    │       └── widgets/
    │           ├── supervisor_header.dart
    │           ├── stats_row.dart
    │           ├── service_request_card.dart
    │           └── unit_status_mini_card.dart
    │
    ├── tasks/
    │   ├── data/
    │   │   ├── remote/supervisor_task_remote_ds.dart
    │   │   └── repo/
    │   │       ├── supervisor_task_repo.dart
    │   │       └── supervisor_task_repo_impl.dart
    │   ├── logic/
    │   │   └── cubit/
    │   │       ├── supervisor_tasks_cubit.dart
    │   │       └── supervisor_tasks_state.dart
    │   └── ui/
    │       ├── supervisor_tasks_screen.dart
    │       └── widgets/
    │           ├── supervisor_task_card.dart
    │           └── assign_unit_bottom_sheet.dart
    │
    ├── units/
    │   ├── data/
    │   │   ├── remote/supervisor_units_remote_ds.dart
    │   │   └── repo/
    │   │       ├── supervisor_units_repo.dart
    │   │       └── supervisor_units_repo_impl.dart
    │   ├── logic/
    │   │   └── cubit/
    │   │       ├── supervisor_units_cubit.dart
    │   │       └── supervisor_units_state.dart
    │   └── ui/
    │       ├── supervisor_units_screen.dart
    │       └── widgets/
    │           ├── unit_status_card.dart
    │           └── unit_detail_bottom_sheet.dart
    │
    ├── reports/
    │   ├── data/
    │   │   ├── remote/supervisor_reports_remote_ds.dart
    │   │   └── repo/
    │   │       ├── supervisor_reports_repo.dart
    │   │       └── supervisor_reports_repo_impl.dart
    │   ├── logic/
    │   │   └── cubit/
    │   │       ├── supervisor_reports_cubit.dart
    │   │       └── supervisor_reports_state.dart
    │   └── ui/
    │       ├── supervisor_reports_screen.dart
    │       └── widgets/
    │           └── supervisor_report_card.dart
    │
    └── profile/
        ├── logic/
        │   └── cubit/
        │       ├── supervisor_profile_cubit.dart
        │       └── supervisor_profile_state.dart
        └── ui/
            ├── supervisor_profile_screen.dart
            └── widgets/
                └── supervisor_settings_tile.dart
```

**Rules:**
- Every feature follows the exact `data/logic/ui` layout from `CLAUDE.md`.
- State files are always `part of` the cubit file — not standalone.
- No feature-specific logic in global cubits (`AuthCubit`, `AppSettingsCubit`).

---

## 3. Shared Dependencies

The Supervisor module reuses the following from `lib/core/shared/`:

| Model | Path |
|---|---|
| `TaskModel` | `lib/core/shared/data/models/task_model.dart` |
| `UnitModel` | `lib/core/shared/data/models/unit_model.dart` |
| `ReportModel` | `lib/core/shared/data/models/report_model.dart` |
| `FlightModel` | `lib/core/shared/data/models/flight_model.dart` |
| `ServiceTypeModel` | `lib/core/shared/data/models/service_type_model.dart` |

The module does **not** create new models for these — always import from shared.

### New model required

```dart
// lib/modules/supervisor/features/dashboard/data/models/service_request_model.dart
class ServiceRequestModel {
  final String id;
  final String flightId;
  final String serviceTypeId;
  final String requestedBy;
  final String? assignedSupervisorId;
  final String status;       // 'pending' | 'assigned' | 'completed'
  final String? notes;
  final DateTime createdAt;
  final FlightModel? flight; // joined
}
```

---

## 4. Feature Breakdown

---

### 4.1 Dashboard (Tab 0)

**Purpose:** At-a-glance operational overview. Entry point for assigning units to incoming service requests.

#### Data Sources

```dart
// dashboard_remote_ds.dart
class DashboardRemoteDs {
  // Stat: count of tasks by status for this supervisor's service type
  Future<Map<String, int>> fetchTaskStats(String serviceTypeId);

  // Stat: count of units by status
  Future<Map<String, int>> fetchUnitStats(String serviceTypeId);

  // Stat: count of open reports
  Future<int> fetchOpenReportCount(String serviceTypeId);

  // List: pending service requests for this supervisor
  Future<List<ServiceRequestModel>> fetchPendingServiceRequests(String serviceTypeId);

  // List: live unit statuses (top N for dashboard preview)
  Future<List<UnitModel>> fetchUnitsPreview(String serviceTypeId, {int limit = 3});
}
```

#### Supabase Queries

```dart
// Pending service requests — joined with flights
supabase
  .from('flight_service_requests')
  .select('*, flights(*)')
  .eq('service_type_id', serviceTypeId)
  .eq('status', 'pending')
  .order('created_at', ascending: true);

// Task stats
supabase
  .from('tasks')
  .select('status')
  .eq('service_type_id', serviceTypeId);

// Unit stats
supabase
  .from('units')
  .select('status')
  .eq('service_type_id', serviceTypeId);
```

#### State

```dart
enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final int activeTaskCount;
  final int pendingRequestCount;
  final int availableUnitCount;
  final int totalUnitCount;
  final int openReportCount;
  final List<ServiceRequestModel> pendingRequests;
  final List<UnitModel> unitsPreview;
  final AppError? error;
}
```

#### Cubit Methods

```dart
class DashboardCubit extends Cubit<DashboardState> {
  Future<void> loadDashboard();
  Future<void> refresh();
  // Called after unit is assigned from bottom sheet
  void onServiceRequestAssigned(String requestId);
}
```

#### UI Layout

```
SupervisorHeader (gradient, name, service type tag, notification button)
  └── stats row: 2×2 grid (Active Tasks / Pending Requests / Units Available / Open Reports)
Section: "Service Requests"
  └── ServiceRequestCard list (pending only, max 5, "View all" → Tab 1)
Section: "Live Unit Status"
  └── UnitStatusMiniCard list (top 3, "View all" → Tab 2)
```

#### `ServiceRequestCard` spec

```
Container
  ├── left accent bar: rw(4), color primary200 (pending) / amber200 (delayed)
  ├── body padding: all rw(14)
  ├── row 1: flight number + stand · Badge (status)
  ├── row 2: meta chips — arrival time · aircraft type · pax count
  └── action row (border top divider):
        [outlined "Details"] [filled "Assign Unit"]
```

- "Assign Unit" opens `AssignUnitBottomSheet` — does NOT navigate away.
- Card tap → `AppDialogs.showConfirm` is NOT used here; sheet opens directly.

#### `AssignUnitBottomSheet`

- Shows available units for this service type (status = `available`).
- Each unit row: name · shift time · member count · `[Assign]` button.
- On assign: creates task record in `tasks`, updates `flight_service_requests.status` → `assigned`.
- On success: `context.showSuccessSnackBar('task_assigned'.tr())` + dismiss sheet + refresh dashboard.
- On failure: `context.showErrorSnackBar(state.error!.messageKey.tr())`.
- Includes the **Global Filtering UI** (search + counter) — see Section 9.

---

### 4.2 Tasks (Tab 1)

**Purpose:** Full task list for the supervisor's service type. View, filter, and monitor task progress. Create tasks from service requests.

#### Data Sources

```dart
class SupervisorTaskRemoteDs {
  Future<List<TaskModel>> fetchTasks({
    required String serviceTypeId,
    String? statusFilter,       // null = all
    String? searchQuery,        // matches flight number or unit name
  });

  // Create task after unit assignment
  Future<TaskModel> createTask({
    required String flightId,
    required String serviceTypeId,
    required String unitId,
    required String assignedBy,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? notes,
    String priority,
  });
}
```

#### Supabase Query

```dart
supabase
  .from('tasks')
  .select('*, flights(*), units(*), service_types(*)')
  .eq('service_type_id', serviceTypeId)
  .order('created_at', ascending: false);
```

#### State

```dart
enum SupervisorTasksStatus { initial, loading, loaded, failure }

class SupervisorTasksState extends Equatable {
  final SupervisorTasksStatus status;
  final List<TaskModel> allTasks;
  final List<TaskModel> filteredTasks;
  final String activeFilter;    // 'all' | 'pending' | 'in_progress' | 'completed' | 'cancelled'
  final String searchQuery;
  final AppError? error;

  int get resultCount => filteredTasks.length;
}
```

#### Cubit Methods

```dart
class SupervisorTasksCubit extends Cubit<SupervisorTasksState> {
  Future<void> loadTasks();
  Future<void> refresh();
  void setFilter(String status);
  void setSearch(String query);
  Future<void> createTask({...});
}
```

**Filter logic (client-side after initial fetch):**

```dart
List<TaskModel> _applyFilters(List<TaskModel> all, String filter, String query) {
  return all.where((t) {
    final matchesFilter = filter == 'all' || t.status.name == filter;
    final matchesSearch = query.isEmpty ||
      t.flight?.flightNumber.toLowerCase().contains(query.toLowerCase()) == true ||
      t.unit?.name.toLowerCase().contains(query.toLowerCase()) == true;
    return matchesFilter && matchesSearch;
  }).toList();
}
```

#### UI Layout

```
AppBar (gradient header): "Tasks" · service type subtitle
Global Filter UI (search field + counter)
Filter Pills row: All · In Progress · Pending · Completed · Cancelled
ListView:
  └── SupervisorTaskCard per task
```

#### `SupervisorTaskCard` spec

Follows the global Card Spec from `design_system.md`:

```
Container (surface, rr(16), border cc.border@0.6, shadow 0.04)
  ├── left accent bar rw(4): TaskUiHelpers.statusColor(task.status)
  ├── body padding all rw(14)
  ├── row 1: task title (unit name + flight number) · status Badge
  ├── row 2 (font14Light, textSecondary): stand · aircraft type · pax count
  └── row 3 (font12Light, textHint): clock icon · scheduled_start – scheduled_end · priority Badge
```

Priority badge colors from `design_system.md`:
- `critical` → `red200`, `high` → `secondary200`, `medium` → `amber200`, `low` → `green200`

---

### 4.3 Units (Tab 2)

**Purpose:** Real-time status board of all units under this supervisor's service type.

#### Data Sources

```dart
class SupervisorUnitsRemoteDs {
  Future<List<UnitModel>> fetchUnits(String serviceTypeId);

  // Real-time subscription
  Stream<List<UnitModel>> watchUnits(String serviceTypeId);
}
```

#### Supabase Query + Realtime

```dart
// One-time fetch
supabase
  .from('units')
  .select('*, unit_members(*), tasks(status)')
  .eq('service_type_id', serviceTypeId);

// Realtime subscription (subscribe on cubit init, cancel on close)
supabase
  .from('units')
  .stream(primaryKey: ['id'])
  .eq('service_type_id', serviceTypeId)
  .listen((data) => /* emit updated state */);
```

#### State

```dart
enum SupervisorUnitsStatus { initial, loading, loaded, failure }

class SupervisorUnitsState extends Equatable {
  final SupervisorUnitsStatus status;
  final List<UnitModel> allUnits;
  final List<UnitModel> filteredUnits;
  final String activeFilter;    // 'all' | 'available' | 'busy' | 'offline'
  final String searchQuery;
  final AppError? error;

  int get resultCount => filteredUnits.length;
}
```

#### Cubit Methods

```dart
class SupervisorUnitsCubit extends Cubit<SupervisorUnitsState> {
  Future<void> loadUnits();
  void setFilter(String status);
  void setSearch(String query);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

#### UI Layout

```
Header (gradient): "Units" · "X units · service type"
Global Filter UI (search + counter)
Filter Pills: All · Available · Busy · Offline
ListView:
  └── UnitStatusCard per unit
```

#### `UnitStatusCard` spec

```
Container (surface, rr(14), border cc.border@0.6)
  padding: rw(14) h, rh(12) v
  Row:
    ├── icon container rw(42)×rw(42), rr(12), bg statusColor@0.1
    │     icon: ti-truck, color = statusColor
    ├── Column:
    │     ├── unit name (font14ExtraBold, textPrimary)
    │     ├── shift time (font12Light, textHint)
    │     └── current task or "No active task" (font12Light, color by status)
    └── status Badge (right-aligned)
```

Status colors:
- `available` → `green200`, `busy` → `primary200`, `offline` → `textDisabled`

Card tap → `UnitDetailBottomSheet`:
- Unit name + status badge
- Shift start / end
- Compatible aircraft list
- Member count + list (full_name · position)

---

### 4.4 Reports (Tab 3)

**Purpose:** View and act on incident reports submitted by workers under this supervisor.

#### Data Sources

```dart
class SupervisorReportsRemoteDs {
  Future<List<ReportModel>> fetchReports({
    required String serviceTypeId,
    String? statusFilter,
    String? searchQuery,
  });

  Future<void> acknowledgeReport(String reportId, String supervisorId);
  Future<void> resolveReport(String reportId, String supervisorId);
}
```

#### Supabase Queries

```dart
// Fetch reports via tasks → service_type join
supabase
  .from('reports')
  .select('*, tasks!inner(service_type_id), flights(*), users!reported_by(*)')
  .eq('tasks.service_type_id', serviceTypeId)
  .order('created_at', ascending: false);

// Acknowledge
supabase
  .from('reports')
  .update({
    'status': 'acknowledged',
    'acknowledged_by': supervisorId,
    'acknowledged_at': DateTime.now().toIso8601String(),
  })
  .eq('id', reportId);

// Resolve
supabase
  .from('reports')
  .update({
    'status': 'resolved',
    'resolved_by': supervisorId,
    'resolved_at': DateTime.now().toIso8601String(),
  })
  .eq('id', reportId);
```

#### State

```dart
enum SupervisorReportsStatus { initial, loading, loaded, actionLoading, failure }

class SupervisorReportsState extends Equatable {
  final SupervisorReportsStatus status;
  final List<ReportModel> allReports;
  final List<ReportModel> filteredReports;
  final String activeFilter;    // 'all' | 'open' | 'acknowledged' | 'resolved'
  final String searchQuery;
  final String? actionReportId; // ID of report currently being acted on
  final AppError? error;

  int get resultCount => filteredReports.length;
}
```

#### Cubit Methods

```dart
class SupervisorReportsCubit extends Cubit<SupervisorReportsState> {
  Future<void> loadReports();
  Future<void> refresh();
  void setFilter(String status);
  void setSearch(String query);
  Future<void> acknowledgeReport(String reportId);
  Future<void> resolveReport(String reportId);
}
```

#### UI Layout

```
Header (gradient): "Reports" · "From your units"
Global Filter UI (search + counter)
Filter Pills: All · Open · Acknowledged · Resolved
ListView:
  └── SupervisorReportCard per report
```

#### `SupervisorReportCard` spec

```
Container (surface, rr(16), border cc.border@0.6)
  ├── top accent bar h(4): ReportSeverity color
  ├── header row (padding rw(14)):
  │     ├── title (font14ExtraBold) + timestamp (font12Light, textHint)
  │     └── severity Badge (right)
  ├── body (font12Light, textSecondary, padding rw(14)): description, maxLines 3
  └── action row (border-top divider, padding rw(14)):
        status = open:         [outlined "Details"] [filled "Acknowledge"]
        status = acknowledged: [outlined "Details"] [filled "Resolve"]
        status = resolved:     [outlined "View"]
```

Severity colors from `design_system.md`:
- `low` → `green200`, `medium` → `amber200`, `high` → `secondary200`, `critical` → `red200`

**Acknowledge/Resolve flow:**
1. Show `AppDialogs.showConfirm` before action.
2. On confirm: set `actionReportId`, call repo, refresh list.
3. On success: `context.showSuccessSnackBar('report_updated'.tr())`.
4. On failure: `context.showErrorSnackBar(state.error!.messageKey.tr())`.

---

### 4.5 Profile (Tab 4)

**Purpose:** Supervisor identity, service type info, and app settings.

#### Data Sources

No dedicated remote DS. Uses `UserService` (reads cached `UserModel` from `SecureStorage`).

#### State

```dart
enum SupervisorProfileStatus { initial, loading, loaded, failure }

class SupervisorProfileState extends Equatable {
  final SupervisorProfileStatus status;
  final UserModel? user;
  final AppError? error;
}
```

#### Cubit Methods

```dart
class SupervisorProfileCubit extends Cubit<SupervisorProfileState> {
  Future<void> loadProfile();
  // Delegates to AppSettingsCubit — not handled here
  // Logout delegates to AuthCubit
}
```

#### UI Layout

```
Gradient header (same as dashboard):
  └── avatar circle (initials, rw(72), semi-transparent border)
  └── full_name (font18ExtraBold, white)
  └── role tag (font12SemiBold, white@0.7)

InfoCard:
  ├── Email row
  ├── Phone row
  ├── Service Type row
  └── Units Managed row (count of units + crew)

Settings list:
  ├── Language → calls switchLanguage() from app_setting_method.dart
  ├── Dark Mode → calls switchTheme()
  ├── Notifications → placeholder (future)
  └── Log Out → AppDialogs.showConfirm → AuthCubit.signOut()
```

Each settings row:
```
Row (padding rh(14) v, rw(16) h, border-bottom divider):
  ├── icon (ti-*, color iconSecondary, rf(18))
  ├── label (font14Light, textPrimary) — red for logout
  └── ti-chevron-right (right, iconSecondary)
```

---

## 5. Background Services

### 5.1 Realtime Unit Status (Tab 2)

- Subscribe to `units` table changes via `supabase.from('units').stream(...)` in `SupervisorUnitsCubit.loadUnits()`.
- Cancel subscription in `close()`.
- Emit new state on every change event.

### 5.2 FCM Push Notifications

Notifications arrive via Firebase FCM. The `NotificationButton` in the dashboard header shows an unread dot when `notifications` table has unread rows for this user.

Notification types relevant to supervisor:
- `task_assigned` — confirmation after supervisor creates a task
- `report_submitted` — new report from a worker
- `task_completed` — worker completed a task

Handle in `NotificationsCubit` (shared, global). Do not handle FCM in supervisor-specific cubits.

### 5.3 Service Request Polling

No realtime subscription needed for `flight_service_requests` — pull-to-refresh on Dashboard is sufficient. Supabase realtime can be added in a future iteration.

---

## 6. State Management Contracts

### Cubit Lifecycle

| Cubit | Scope | Where Provided |
|---|---|---|
| `SupervisorNavCubit` | Global (tab state) | `supervisor_scaffold.dart` via `BlocProvider` |
| `DashboardCubit` | Tab-level | `UserAuthenticatedCheck` `MultiBlocProvider` |
| `SupervisorTasksCubit` | Tab-level | `UserAuthenticatedCheck` `MultiBlocProvider` |
| `SupervisorUnitsCubit` | Tab-level | `UserAuthenticatedCheck` `MultiBlocProvider` |
| `SupervisorReportsCubit` | Tab-level | `UserAuthenticatedCheck` `MultiBlocProvider` |
| `SupervisorProfileCubit` | Tab-level | `UserAuthenticatedCheck` `MultiBlocProvider` |

Tab-level cubits are provided at root so they persist across tab switches (persistent state pattern).

### Error Handling Pattern

```dart
// In every cubit method:
try {
  emit(state.copyWith(status: XStatus.loading));
  final result = await repo.someCall();
  emit(state.copyWith(status: XStatus.loaded, data: result));
} on AppError catch (e) {
  emit(state.copyWith(status: XStatus.failure, error: e));
} catch (_) {
  emit(state.copyWith(status: XStatus.failure, error: AppError.unknown()));
}
```

Display error text as `state.error!.messageKey.tr()` — never hardcode error strings.

### State Pattern (per feature)

All features follow **Pattern A** from `design_system.md`:

```
loading/initial → CircularProgressIndicator(color: AppColors.primary200)
failure         → cloud_off icon + error message (font14Light, red) + retry TextButton
empty           → EmptyState widget (icon + font14Light message)
loaded          → RefreshIndicator(color: primary200) + ListView
```

---

## 7. Navigation & Routing

### Bottom Navigation

`SupervisorScaffold` uses Flutter's standard `BottomNavigationBar` (not `PersistentTabView`) with `IndexedStack` to preserve tab state.

```dart
// supervisor_scaffold.dart
IndexedStack(
  index: state.currentIndex,
  children: [
    DashboardScreen(),
    SupervisorTasksScreen(),
    SupervisorUnitsScreen(),
    SupervisorReportsScreen(),
    SupervisorProfileScreen(),
  ],
)
```

### New Routes Required

Add to `lib/core/router/routes.dart`:

```dart
static const String supervisorScaffold         = '/supervisorScaffold';       // exists
static const String supervisorTasksScreen       = '/supervisorTasksScreen';    // confirm or add
static const String supervisorTaskDetailScreen  = '/supervisorTaskDetailScreen'; // new
```

Add to `app_routers.dart`:

```dart
case Routes.supervisorTaskDetailScreen:
  final args = settings.arguments as Map<String, dynamic>;
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => BlocProvider(
      create: (_) => getIt<SupervisorTaskDetailCubit>()..loadTask(args['taskId']),
      child: SupervisorTaskDetailScreen(),
    ),
  );
```

### Navigation Rules

- Always use `context.pushNamed(Routes.x, arguments: {...})`.
- Always guard `context.pop()` with `Navigator.canPop(context)`.
- Bottom sheets open via `showModalBottomSheet` — not named routes.
- Dialogs open via `AppDialogs.*` — never raw `showDialog()`.

---

## 8. UI/UX Design Specifications

All tokens are inherited from `design_system.md`. This section only documents supervisor-specific applications.

### 8.1 Gradient Header (Dashboard & screen headers)

```dart
BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary200, AppColors.primary300, AppColors.primary400],
  ),
)
// padding: rh(20) top, rw(16) horizontal, rh(28) bottom (dashboard)
// padding: rh(20) top, rw(16) horizontal, rh(16) bottom (tab screens)
```

Non-dashboard tab screens (Tasks, Units, Reports) use a **compact gradient header**:
- Title: `font18ExtraBold`, white
- Subtitle: `font12Light`, `white @ 0.7` — shows service type name

### 8.2 Stats Row (Dashboard only)

2×2 grid of stat cards:

```dart
GridView(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: rw(10),
    mainAxisSpacing: rh(10),
    childAspectRatio: 1.6,
  ),
)
```

Each stat card:
```
Container (surface, rr(14), border cc.border@0.5)
  padding: rw(14), rh(12)
  ├── label: font11Light (use font12Light), textHint
  ├── value: font22ExtraBold (use font20ExtraBold), status-specific color
  └── sub: font11Light (use font12Light), textHint
```

Stat colors:
- Active Tasks → `primary200`
- Pending Requests → `amber200`
- Units Available → `green200`
- Open Reports → `red200`

### 8.3 Notification Button

Use the global `NotificationButton` widget from `lib/core/widgets/notification_button.dart`.

Place in dashboard header trailing position.

### 8.4 Bottom Navigation Bar

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: cc.surface,
  selectedItemColor: AppColors.primary200,
  unselectedItemColor: AppColors.grey400,
  selectedLabelStyle: AppTextStyles.font10ExtraBold, // use font12SemiBold
  unselectedLabelStyle: AppTextStyles.font12Light,
  elevation: 0,
  // Top border:
  // DecoratedBox → BoxDecoration(border: Border(top: BorderSide(color: cc.border, width: 0.5)))
)
```

Icons (Tabler / Material outline only):
- Dashboard → `Icons.dashboard_outlined`
- Tasks → `Icons.check_box_outlined`
- Units → `Icons.local_shipping_outlined`
- Reports → `Icons.flag_outlined`
- Profile → `Icons.account_circle_outlined`

### 8.5 Section Headers

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('section_title'.tr(), style: AppTextStyles.font14ExtraBold.copyWith(color: cc.textPrimary)),
    if (hasViewAll)
      GestureDetector(
        onTap: onViewAll,
        child: Text('view_all'.tr(), style: AppTextStyles.font12SemiBold.copyWith(color: AppColors.primary200)),
      ),
  ],
)
// margin bottom: rh(10)
```

### 8.6 Empty State

```dart
// Used on Tasks, Units, Reports when list is empty after filter
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.cloud_off_outlined, size: rf(48), color: cc.iconSecondary),
    verticalSpacing(12),
    Text('no_results_found'.tr(), style: AppTextStyles.font14Light.copyWith(color: cc.textHint)),
  ],
)
```

---

## 9. Global Filtering UI Standard

**Every list screen in this module must include a search field and a live result counter.** This is a non-negotiable design rule for the Supervisor module.

### Layout

```
Column:
  ├── Search Field (CustomTextForm variant)
  └── Row: filter pills  ·  counter badge (right-aligned)
```

### Search Field Spec

```dart
CustomTextForm(
  hintText: 'search_placeholder'.tr(),  // e.g. "Search by flight or unit..."
  prefixIcon: Icon(Icons.search, color: cc.iconSecondary, size: rf(20)),
  onChanged: (q) => cubit.setSearch(q),
  // No form validation — this is a live search field
  // border style: default (cc.border) / focused (primary50)
)
// margin: rw(16) horizontal, rh(12) vertical
```

### Filter Pills Spec

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: EdgeInsets.symmetric(horizontal: rw(16)),
  child: Row(
    children: filters.map((f) => _FilterPill(label: f, isActive: ..., onTap: ...)).toList(),
  ),
)
```

Each pill:
```dart
// Active:
Container(
  padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(6)),
  decoration: BoxDecoration(
    color: AppColors.primary200,
    borderRadius: BorderRadius.circular(rr(20)),
  ),
  child: Text(label, style: AppTextStyles.font12SemiBold.copyWith(color: AppColors.white)),
)

// Inactive:
Container(
  padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(6)),
  decoration: BoxDecoration(
    color: cc.surfaceVariant,
    borderRadius: BorderRadius.circular(rr(20)),
    border: Border.all(color: cc.border),
  ),
  child: Text(label, style: AppTextStyles.font12SemiBold.copyWith(color: cc.textSecondary)),
)
// Transition: AnimatedContainer 200ms
```

### Result Counter

```dart
// Shown between filter pills row and list
Padding(
  padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(8)),
  child: Row(
    children: [
      Text(
        '${state.resultCount} ${'results'.tr()}',
        style: AppTextStyles.font12SemiBold.copyWith(color: cc.textSecondary),
      ),
    ],
  ),
)
```

Counter updates live on every filter or search change — it always reflects `filteredList.length`, not `allList.length`.

### Where Applied

| Screen | Search placeholder | Filter pills |
|---|---|---|
| Tasks (Tab 1) | "Search by flight or unit..." | All · In Progress · Pending · Completed · Cancelled |
| Units (Tab 2) | "Search by unit name..." | All · Available · Busy · Offline |
| Reports (Tab 3) | "Search by flight or description..." | All · Open · Acknowledged · Resolved |
| AssignUnitBottomSheet | "Search units..." | Available (only) |

---

## 10. DI Registration Checklist

Add to `lib/core/di/dependency_injection.dart`:

```dart
// Remote data sources
getIt.registerLazySingleton<DashboardRemoteDs>(() => DashboardRemoteDs(getIt()));
getIt.registerLazySingleton<SupervisorTaskRemoteDs>(() => SupervisorTaskRemoteDs(getIt()));
getIt.registerLazySingleton<SupervisorUnitsRemoteDs>(() => SupervisorUnitsRemoteDs(getIt()));
getIt.registerLazySingleton<SupervisorReportsRemoteDs>(() => SupervisorReportsRemoteDs(getIt()));

// Repositories
getIt.registerLazySingleton<DashboardRepo>(() => DashboardRepoImpl(getIt()));
getIt.registerLazySingleton<SupervisorTaskRepo>(() => SupervisorTaskRepoImpl(getIt()));
getIt.registerLazySingleton<SupervisorUnitsRepo>(() => SupervisorUnitsRepoImpl(getIt()));
getIt.registerLazySingleton<SupervisorReportsRepo>(() => SupervisorReportsRepoImpl(getIt()));

// Cubits (factory — new instance per provision)
getIt.registerFactory<DashboardCubit>(() => DashboardCubit(getIt()));
getIt.registerFactory<SupervisorTasksCubit>(() => SupervisorTasksCubit(getIt()));
getIt.registerFactory<SupervisorUnitsCubit>(() => SupervisorUnitsCubit(getIt()));
getIt.registerFactory<SupervisorReportsCubit>(() => SupervisorReportsCubit(getIt()));
getIt.registerFactory<SupervisorProfileCubit>(() => SupervisorProfileCubit(getIt()));
```

---

## Appendix: Localization Keys

Add to both `assets/lang/en.json` and `assets/lang/ar.json`:

```json
{
  "supervisor_dashboard_title": "Dashboard",
  "supervisor_tasks_title": "Tasks",
  "supervisor_units_title": "Units",
  "supervisor_reports_title": "Reports",
  "supervisor_profile_title": "Profile",
  "service_requests_section": "Service Requests",
  "live_unit_status_section": "Live Unit Status",
  "view_all": "View all",
  "assign_unit": "Assign Unit",
  "acknowledge": "Acknowledge",
  "resolve": "Resolve",
  "task_assigned": "Unit assigned successfully",
  "report_updated": "Report updated",
  "search_by_flight_or_unit": "Search by flight or unit...",
  "search_by_unit_name": "Search by unit name...",
  "search_by_flight_or_description": "Search by flight or description...",
  "search_units": "Search units...",
  "results": "results",
  "no_results_found": "No results found",
  "active_tasks": "Active Tasks",
  "pending_requests": "Pending Requests",
  "units_available": "Units Available",
  "open_reports": "Open Reports"
}
```

---

*GroundScope · Supervisor Module Reference · Version 1.0 · June 2026*
