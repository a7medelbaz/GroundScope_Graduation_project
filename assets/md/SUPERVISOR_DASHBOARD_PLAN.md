# GroundScope — Supervisor Dashboard: Implementation Plan

> **Scope:** Complete build-out of the Supervisor module dashboard and all supporting tabs.
> **Excluded (by decision):** Report Incident / Add Report feature (supervisors do not file reports). Admin Notification Card (deferred until notification service is ready).
> **Prerequisites:** CLAUDE.md conventions, DATABASE.md schema, design_system.md tokens.

---

## 1. Tab Layout — Restructured (5 → 4 Tabs)

The current scaffold has 5 tabs. With the Add Report tab removed, the supervisor gets a clean 4-tab layout:

| Index | Icon | Label | Screen Class | Status |
|---|---|---|---|---|
| 0 | `Icons.dashboard_outlined` | Dashboard | `SupervisorDashboardScreen` | ⚠️ Partial — widgets hardcoded |
| 1 | `Icons.assignment_outlined` | Tasks | `SupervisorTasksScreen` | ❌ Placeholder |
| 2 | `Icons.analytics_outlined` | Reports | `SupervisorReportsScreen` | ❌ Crashes — missing BlocProvider |
| 3 | `Icons.person_outline` | Profile | `SupervisorProfileScreen` | ⚠️ Logout/theme only |

**File to modify:** `lib/modules/supervisor/core/main_navigation/supervisor_scaffold.dart`

**Changes:**
- Remove Tab 2 (add report / FAB-style `add` icon) entirely from `_buildScreens()` and the nav bar items list.
- Reindex remaining tabs: Dashboard=0, Tasks=1, Reports=2, Profile=3.
- Update `NavBarStyle` if needed (style15 supports 4 items).
- Remove `supervisor_add_report_screen.dart` import.

**Files to delete:**
- `lib/modules/supervisor/features/add_report/supervisor_add_report_screen.dart`
- The entire `lib/modules/supervisor/features/add_report/` directory.

---

## 2. MultiBlocProvider — Supervisor Root

**File:** `lib/core/auth/ui/user_authenticated_check.dart`

The supervisor case currently only provides `DashboardCubit`. Update to:

```dart
'supervisor' => MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => getIt<DashboardCubit>()..loadDashboardStats()),
    BlocProvider(create: (_) => getIt<SupervisorReportsCubit>()..loadReportsToday()),
    BlocProvider(create: (_) => getIt<SupervisorTasksCubit>()..loadAllTasks()),
  ],
  child: const SupervisorScaffold(),
),
```

**Why each cubit is here:**
- `DashboardCubit` — Tab 0 stats grid + live task summary.
- `SupervisorReportsCubit` — Tab 2 (reports list). Already exists, just not provided. **Fixes BUG-01.**
- `SupervisorTasksCubit` — Tab 1 (task management hub). New cubit — see §5.

**DI registration** (`lib/core/di/dependency_injection.dart`):
- `SupervisorTasksCubit` → register as `factory` (same pattern as all cubits).
- `SupervisorReportsCubit` and `DashboardCubit` — already registered, no change.

---

## 3. Dashboard Screen (Tab 0)

**Path:** `lib/modules/supervisor/features/dashboard/`

The dashboard is the supervisor's command center. It shows at-a-glance stats, a live task breakdown, and quick navigation to key workflows.

### 3.1 Screen Layout — Top to Bottom

```
┌─────────────────────────────────────┐
│  SupervisorAppBar                   │  ← greeting + avatar + date
├─────────────────────────────────────┤
│  StatusGrid (2×2)                   │  ← 4 stat cards
├─────────────────────────────────────┤
│  LiveTaskSummary                    │  ← donut chart + legend
├─────────────────────────────────────┤
│  QuickActionsRow                    │  ← 2 action buttons
└─────────────────────────────────────┘
```

**Wrapped in:** `RefreshIndicator` → calls `DashboardCubit.loadDashboardStats()`.

### 3.2 SupervisorAppBar — Fix Notification Bell

**File:** `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_app_bar.dart`

**Current state:** Notification bell has `onTap: () {}`.

**Change:** For now, keep the bell icon visually but make it **non-interactive** (remove the `InkWell` / `GestureDetector` or set `onTap: null`). The notification system is deferred. Do NOT wire it to a route that doesn't exist.

**No other changes** — greeting, avatar, and date are complete.

### 3.3 StatusGrid — Fix Delayed Tasks Card (BUG-02)

**File:** `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart`

**Current bug:** The "Delayed Tasks" card passes `filterStatus: TaskStatus.completed` — this shows completed tasks instead of delayed ones.

**Fix requires a new query chain:**

#### 3.3.1 New Remote Method

**File:** `lib/core/shared/data/remote/task_remote_ds.dart`

Add:
```dart
/// Fetches tasks where scheduled_end has passed but status is not completed or cancelled.
Future<List<TaskModel>> fetchDelayedTasks() async {
  final now = DateTime.now().toUtc().toIso8601String();
  final response = await _client
      .from('tasks')
      .select('*, service_types(*), flights(*, stands(*))')
      .lt('scheduled_end', now)
      .neq('status', TaskStatus.completed.name)
      .neq('status', TaskStatus.cancelled.name)
      .order('scheduled_end', ascending: true);
  return (response as List).map((e) => TaskModel.fromMap(e)).toList();
}
```

**DB columns used:** `tasks.scheduled_end` (timestamptz), `tasks.status` (task_status enum). Joins: `service_types(*)`, `flights(*, stands(*))` — same join pattern as existing `fetchTasksByStatus`.

#### 3.3.2 Repo Layer

**File:** `lib/core/shared/data/repo/task_repo.dart` — add abstract method:
```dart
Future<List<TaskModel>> fetchDelayedTasks();
```

**File:** `lib/core/shared/data/repo/task_repo_impl.dart` — implement:
```dart
@override
Future<List<TaskModel>> fetchDelayedTasks() async {
  try {
    return await _remoteDs.fetchDelayedTasks();
  } catch (e) {
    throw ErrorHandler.handle(e);
  }
}
```

#### 3.3.3 Route Argument — TaskFilterType Enum

**New file:** `lib/core/shared/data/models/task_filter_type.dart`

```dart
enum TaskFilterType { completed, delayed }
```

This enum is passed as a route argument when navigating from the status grid cards to `SupervisorTaskListScreen`. The cubit uses it to dispatch the correct fetch method.

#### 3.3.4 Update SupervisorTaskListCubit

**File:** `lib/modules/supervisor/features/tasks/logic/cubit/supervisor_task_list_cubit.dart`

Add a new method:
```dart
Future<void> loadDelayedTasks() async {
  emit(SupervisorTaskListLoading());
  try {
    final tasks = await _taskRepo.fetchDelayedTasks();
    emit(SupervisorTaskListLoaded(
      allTasks: tasks,
      filteredTasks: tasks,
      searchQuery: '',
    ));
  } on AppError catch (e) {
    emit(SupervisorTaskListFailure(e));
  } catch (_) {
    emit(SupervisorTaskListFailure(AppError.unknown()));
  }
}
```

#### 3.3.5 Update StatusGrid Card

**File:** `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart`

Change the "Delayed Tasks" card's `onTap`:
- Pass `TaskFilterType.delayed` as route argument instead of `filterStatus: TaskStatus.completed`.

#### 3.3.6 Update Router

**File:** `lib/core/router/app_routers.dart`

The `supervisorTaskListScreen` case must read `TaskFilterType` from `settings.arguments` and call either `loadTasks(TaskStatus.completed)` or `loadDelayedTasks()` accordingly:

```dart
case Routes.supervisorTaskListScreen:
  final args = settings.arguments as Map<String, dynamic>;
  final filterType = args['filterType'] as TaskFilterType;
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => BlocProvider(
      create: (_) {
        final cubit = getIt<SupervisorTaskListCubit>();
        if (filterType == TaskFilterType.delayed) {
          cubit.loadDelayedTasks();
        } else {
          cubit.loadTasks(args['status'] as TaskStatus);
        }
        return cubit;
      },
      child: SupervisorTaskListScreen(title: args['title'] as String),
    ),
  );
```

### 3.4 LiveTaskSummary — Connect to Real Data (BUG-03)

**File:** `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_live_task_summary.dart`

**Current state:** Hardcoded `_donePct = 0.70`, `_inProgressPct = 0.20`, `_delayPct = 0.10`.

#### 3.4.1 Extend DashboardStatsModel

**File:** `lib/modules/supervisor/features/dashboard/data/models/dashboard_stats_model.dart`

Add fields:
```dart
final int totalTasks;
final int completedTasks;   // status = 'completed'
final int inProgressTasks;  // status = 'in_progress'
final int pendingTasks;     // status = 'pending'
final int delayedTasks;     // scheduled_end < now AND status not completed/cancelled

// Computed getters
double get completedRatio => totalTasks == 0 ? 0 : completedTasks / totalTasks;
double get inProgressRatio => totalTasks == 0 ? 0 : inProgressTasks / totalTasks;
double get pendingRatio => totalTasks == 0 ? 0 : pendingTasks / totalTasks;
double get delayedRatio => totalTasks == 0 ? 0 : delayedTasks / totalTasks;
```

Update `fromMap` / `copyWith` / `==` / `props` (Equatable) accordingly.

#### 3.4.2 Extend DashboardRemoteDs

**File:** `lib/modules/supervisor/features/dashboard/data/remote/dashboard_remote_ds.dart`

Add to the existing `Future.wait` call:

```dart
// Existing 4 queries + new ones:
final completedCount = _client.from('tasks').select().eq('status', 'completed').count(CountOption.exact);
final inProgressCount = _client.from('tasks').select().eq('status', 'in_progress').count(CountOption.exact);
final pendingCount = _client.from('tasks').select().eq('status', 'pending').count(CountOption.exact);
final totalCount = _client.from('tasks').select().count(CountOption.exact);
final delayedCount = _client.from('tasks').select()
    .lt('scheduled_end', DateTime.now().toUtc().toIso8601String())
    .neq('status', 'completed')
    .neq('status', 'cancelled')
    .count(CountOption.exact);
```

All 9 queries run in a single `Future.wait` — no sequential calls.

#### 3.4.3 Update LiveTaskSummary Widget

Remove all static constants. Read from `BlocBuilder<DashboardCubit, DashboardState>`:

```dart
BlocBuilder<DashboardCubit, DashboardState>(
  builder: (context, state) {
    if (state is! DashboardLoaded) return const SizedBox.shrink();
    final stats = state.stats;
    // Use stats.completedRatio, stats.inProgressRatio, etc.
  },
)
```

**UI spec for the donut + legend (unchanged visual):**

| Element | Spec |
|---|---|
| Container | `cc.surface`, radius `rr(16)`, border `cc.border @ 0.6`, shadow same as Card Spec §6 |
| Section title | `font16SemiBold`, color `textPrimary`, text: `'Live Task Summary'.tr()` |
| Donut chart | Custom painter, `rw(100)` diameter, stroke `rw(12)` |
| Donut segments | Completed=`green200`, InProgress=`primary200`, Pending=`amber200`, Delayed=`red200` |
| Center text | `font20ExtraBold` total count, `font12Light` "Total Tasks" below |
| Legend | Row of `_LegendDot` items: colored circle `rw(8)` + `font12SemiBold` label + `font12Light` count |
| Padding | `rw(16)` all sides, `rh(12)` between title and chart |

**Empty state:** If `totalTasks == 0`, show the donut as a single grey (`grey200`) ring with center text "0" and legend text "No tasks yet".

### 3.5 QuickActionsRow — Remove "Report Incident" Only

**File:** `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_quick_actions_row.dart`

**Scope:** Dashboard body only. The Reports tab in the bottom nav bar is untouched.

**Remove:** The "Report Incident" button widget and its `onTap` handler. Delete only this button — do not touch anything else in the file or the scaffold.

**Keep:** The "Assign Task" button exactly as-is (icon, label, handler). No changes to it.

**Resulting layout — one action button:**

| Button | Icon | Label | Navigation |
|---|---|---|---|
| Assign Task | `Icons.add_task_rounded` | `'Assign Task'.tr()` | `context.pushNamed(Routes.supervisorTasksScreen)` |

> If the row widget uses an `Expanded` + `Row` layout for two buttons, replace it with a single full-width button using the same visual spec (height `rh(52)`, surface bg, border, shadow, icon + label).

**Button spec (both identical):**

| Property | Value |
|---|---|
| Layout | `Expanded` inside a `Row` with `horizontalSpacing(12)` gap |
| Height | `rh(52)` |
| Background | `cc.surface` |
| Border | `cc.border @ 0.6`, radius `rr(14)` |
| Shadow | same as Card Spec (black @ 0.04, blur 10, offset 0,2) |
| Icon | `rf(20)`, color `primary200` |
| Label | `font14SemiBold`, color `textPrimary` |
| Splash | `InkWell` with `borderRadius: rr(14)` |
| Internal padding | `rw(14)` horizontal |

### 3.6 Admin Notification Card — Feature Flag (Deferred)

**File:** `lib/modules/supervisor/features/dashboard/ui/supervisor_dashboard_screen.dart`

**Do NOT remove the widget or its import.** Instead, wrap the `SupervisorAdminNotificationCard` call in a `const bool` feature flag so it renders nothing but is trivially re-enabled:

```dart
// Set to true when notification service is ready
const bool _showAdminNotificationCard = false;

// In the Column build tree, where the card currently sits:
if (_showAdminNotificationCard) const SupervisorAdminNotificationCard(),
```

**Re-enabling later:** Change `false` → `true` on the single flag line. Nothing else needs to change.

**File untouched:** `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_admin_notification_card.dart` — do not modify or delete.

### 3.7 Pull-to-Refresh — Wire (BUG-07)

**File:** `lib/modules/supervisor/features/dashboard/ui/supervisor_dashboard_screen.dart`

Replace `Future.delayed(Duration(seconds: 1))` with:

```dart
onRefresh: () async {
  await context.read<DashboardCubit>().loadDashboardStats();
},
```

The `loadDashboardStats` method already returns `Future<void>`, which satisfies `RefreshIndicator.onRefresh`.

---

## 4. Dashboard — Final Build Tree After All Changes

```
SupervisorDashboardScreen
└── RefreshIndicator (onRefresh → DashboardCubit.loadDashboardStats)
    └── BlocBuilder<DashboardCubit>
        ├── Loading → CircularProgressIndicator(color: primary200)
        ├── Failure → ErrorScreen(error: state.error.messageKey, onRetry: loadDashboardStats)
        └── Loaded → SingleChildScrollView
            └── Column
                ├── SupervisorAppBar (greeting, avatar, date, bell=disabled)
                ├── verticalSpacing(16)
                ├── SupervisorStatusGrid (4 stat cards from DashboardStatsModel)
                ├── verticalSpacing(16)
                ├── if (_showAdminNotificationCard) SupervisorAdminNotificationCard()  ← flag=false
                ├── SupervisorLiveTaskSummary (donut from DashboardStatsModel ratios)
                ├── verticalSpacing(16)
                ├── SupervisorQuickActionsRow (Assign Task only)
                └── verticalSpacing(24)
```

**Admin card:** present in code, hidden by `_showAdminNotificationCard = false` flag.

---

## 5. Tasks Screen (Tab 1) — Full Build

**Path:** `lib/modules/supervisor/features/tasks/`

This is the supervisor's primary workflow screen. It shows all tasks with status filtering.

### 5.1 New Cubit — SupervisorTasksCubit

**New files:**
```
supervisor/features/tasks/logic/cubit/
├── supervisor_tasks_cubit.dart
└── supervisor_tasks_state.dart
```

This is a **separate cubit** from the existing `SupervisorTaskListCubit`. The list cubit is for pushed route screens (filtered by a single status). This cubit powers the main tab and supports multi-filter + search.

#### State

```dart
part of 'supervisor_tasks_cubit.dart';

sealed class SupervisorTasksState extends Equatable { ... }

final class SupervisorTasksInitial extends SupervisorTasksState { ... }
final class SupervisorTasksLoading extends SupervisorTasksState { ... }
final class SupervisorTasksFailure extends SupervisorTasksState {
  final AppError error;
}
final class SupervisorTasksLoaded extends SupervisorTasksState {
  final List<TaskModel> allTasks;
  final List<TaskModel> filteredTasks;
  final TaskStatus? selectedFilter;  // null = "All"
  final String searchQuery;
}
```

#### Cubit

```dart
class SupervisorTasksCubit extends Cubit<SupervisorTasksState> {
  final TaskRepo _taskRepo;

  SupervisorTasksCubit(this._taskRepo) : super(SupervisorTasksInitial());

  Future<void> loadAllTasks() async {
    emit(SupervisorTasksLoading());
    try {
      final tasks = await _taskRepo.fetchAllTasks();
      emit(SupervisorTasksLoaded(
        allTasks: tasks,
        filteredTasks: tasks,
        selectedFilter: null,
        searchQuery: '',
      ));
    } on AppError catch (e) {
      emit(SupervisorTasksFailure(error: e));
    } catch (_) {
      emit(SupervisorTasksFailure(error: AppError.unknown()));
    }
  }

  void filterByStatus(TaskStatus? status) { /* filter allTasks, emit Loaded */ }

  void search(String query) { /* filter by query on current filter set, emit Loaded */ }
}
```

#### New Shared Repo Method — fetchAllTasks

**File:** `lib/core/shared/data/remote/task_remote_ds.dart`

```dart
Future<List<TaskModel>> fetchAllTasks() async {
  final response = await _client
      .from('tasks')
      .select('*, service_types(*), flights(*, stands(*))')
      .order('scheduled_start', ascending: false);
  return (response as List).map((e) => TaskModel.fromMap(e)).toList();
}
```

**File:** `lib/core/shared/data/repo/task_repo.dart` — add abstract `Future<List<TaskModel>> fetchAllTasks();`
**File:** `lib/core/shared/data/repo/task_repo_impl.dart` — implement with try/catch + `ErrorHandler.handle`.

#### DI Registration

**File:** `lib/core/di/dependency_injection.dart`

```dart
getIt.registerFactory<SupervisorTasksCubit>(
  () => SupervisorTasksCubit(getIt<TaskRepo>()),
);
```

### 5.2 SupervisorTasksScreen UI

**File:** `lib/modules/supervisor/features/tasks/ui/supervisor_tasks_screen.dart` (replace placeholder)

#### Layout

```
SupervisorTasksScreen
└── BlocBuilder<SupervisorTasksCubit>
    ├── Loading → Center(CircularProgressIndicator(color: primary200))
    ├── Failure → ErrorScreen(onRetry: loadAllTasks)
    └── Loaded →
        └── Column
            ├── _Header (title + search bar)
            ├── verticalSpacing(12)
            ├── SupervisorTaskFilterStrip (horizontal scrollable pills)
            ├── verticalSpacing(12)
            └── Expanded
                └── RefreshIndicator(onRefresh: loadAllTasks)
                    └── filteredTasks.isEmpty
                        ? TaskListEmptyState()
                        : ListView.builder(items: filteredTasks, itemBuilder: TaskCard)
```

#### _Header Widget

| Element | Spec |
|---|---|
| Title | `font22ExtraBold`, color `textPrimary`, text: `'Tasks'.tr()` |
| Subtitle | `font14Light`, color `textSecondary`, text: `'{count} tasks'.tr(args: [allTasks.length.toString()])` |
| Search bar | `CustomTextForm` with `prefixIcon: Icons.search`, hint: `'Search tasks...'.tr()` |
| Search debounce | 300ms via `Timer` — calls `cubit.search(query)` |
| Padding | `rw(16)` horizontal |

#### SupervisorTaskFilterStrip

**New file:** `lib/modules/supervisor/features/tasks/ui/widgets/supervisor_task_filter_strip.dart`

A horizontal `ListView` of filter pills. Follows the Filter Pills spec from design_system.md:

| Property | Value |
|---|---|
| Items | `['All', 'Pending', 'In Progress', 'Completed', 'Cancelled']` |
| Selected pill | bg `primary200`, text `white`, `font12SemiBold` |
| Unselected pill | bg `cc.surfaceVariant`, border `cc.border`, text `cc.textSecondary`, `font12SemiBold` |
| Padding per pill | `rw(14)` h, `rh(6)` v |
| Radius | `rr(20)` |
| Gap between pills | `horizontalSpacing(8)` |
| Strip padding | `rw(16)` left (first item), `rw(16)` right (last item) |
| Animation | 200ms color/bg transition |
| Height | intrinsic (no fixed height on the ListView, `shrinkWrap: true`) |

**onTap:** Calls `cubit.filterByStatus(status)` where `status` is `null` for "All" and the corresponding `TaskStatus` enum value for others.

#### TaskCard onTap

Each `TaskCard` in the list navigates to the existing worker `TaskDetailsScreen` via:
```dart
context.pushNamed(Routes.taskDetailsScreen, arguments: {'taskId': task.id});
```

> **Note:** The existing `TaskDetailsScreen` + `TaskDetailsCubit` are reusable. The supervisor sees the same detail view as the worker. Role-specific actions (start/pause/complete) are already guarded by `userModel.role` checks in that screen. If they aren't, this must be added — but that's a separate task outside this plan's scope.

### 5.3 Files Summary — Tasks Tab

| Action | File |
|---|---|
| **Create** | `supervisor/features/tasks/logic/cubit/supervisor_tasks_cubit.dart` |
| **Create** | `supervisor/features/tasks/logic/cubit/supervisor_tasks_state.dart` |
| **Create** | `supervisor/features/tasks/ui/widgets/supervisor_task_filter_strip.dart` |
| **Rewrite** | `supervisor/features/tasks/ui/supervisor_tasks_screen.dart` |
| **Modify** | `lib/core/shared/data/remote/task_remote_ds.dart` — add `fetchAllTasks()` |
| **Modify** | `lib/core/shared/data/repo/task_repo.dart` — add abstract method |
| **Modify** | `lib/core/shared/data/repo/task_repo_impl.dart` — implement |
| **Modify** | `lib/core/di/dependency_injection.dart` — register `SupervisorTasksCubit` |
| **Modify** | `lib/core/auth/ui/user_authenticated_check.dart` — add to MultiBlocProvider |

---

## 6. Reports Screen (Tab 2) — Fix Crash + Enhance

**Path:** `lib/modules/supervisor/features/reports/`

### 6.1 Crash Fix (BUG-01)

Already handled in §2 — `SupervisorReportsCubit` is now provided in `UserAuthenticatedCheck`'s `MultiBlocProvider`. No further changes needed for the crash.

### 6.2 Current Screen — Already Built

`supervisor_reports_screen.dart` is ✅ Complete — it has:
- Today banner
- Search bar with `cubit.search(query)`
- `BlocBuilder<SupervisorReportsCubit>` with loading/failure/loaded states
- `ReportCard` list
- `ReportsEmptyState` for empty

**No UI changes needed for this phase.** The screen works once the cubit is provided.

### 6.3 Future Enhancement (Out of Scope — Noted for Later)

- Historical / all-time reports view (not just today).
- Report status update actions (acknowledge, resolve) — requires new `ReportRemoteDs.updateReportStatus()` method.
- Report detail screen for supervisor.

These are **not** part of this plan. They'll be addressed when the report management workflow is designed.

---

## 7. Profile Screen (Tab 3) — Full Build

**File:** `lib/modules/supervisor/features/profile/ui/supervisor_profile_screen.dart` (rewrite stub)

### 7.1 Data Source

No new cubit needed. `AuthCubit` is globally provided and its `AuthSuccess` state contains `UserModel` with:
- `fullName` (text)
- `email` (text)
- `phone` (text, nullable)
- `role` (user_role enum — will be `'supervisor'`)
- `serviceTypeId` (uuid, nullable)
- `unitId` (uuid, nullable — will be null for supervisors)

Read via: `context.watch<AuthCubit>().state` → cast to `AuthSuccess` → access `.userModel`.

### 7.2 Layout

```
SupervisorProfileScreen
└── BlocBuilder<AuthCubit>
    └── AuthSuccess →
        └── SingleChildScrollView
            └── Column
                ├── _ProfileHeader (avatar + name + role badge)
                ├── verticalSpacing(24)
                ├── _PersonalInfoCard (InfoCard with name, email, phone)
                ├── verticalSpacing(16)
                ├── _SettingsCard (theme, language)
                ├── verticalSpacing(16)
                ├── _LogoutButton
                └── verticalSpacing(32)
```

### 7.3 _ProfileHeader

| Element | Spec |
|---|---|
| Container | Full width, `rh(160)` height, gradient bg `AppColors.primaryGradient`, radius `rr(0)` top / `rr(24)` bottom |
| Avatar | `CircleAvatar`, `rw(72)` radius, bg `white`, child: initials from `fullName` in `font24ExtraBold` color `primary200`. If `imageUrl` exists on model, use `CachedNetworkImage`. |
| Name | `font20ExtraBold`, color `white` |
| Role badge | Chip: bg `white @ 0.2`, radius `rr(12)`, padding `rw(12)` h / `rh(4)` v, text `font12SemiBold` color `white`, text: `'Supervisor'.tr()` |
| Vertical spacing | `rh(12)` between avatar and name, `rh(6)` between name and badge |
| Alignment | `Column` centered |

### 7.4 _PersonalInfoCard

Reuse `InfoCard` + `InfoRowData`:

```dart
InfoCard(
  rows: [
    InfoRowData(
      icon: Icons.person_outline,
      label: 'Full Name'.tr(),
      value: user.fullName,
      highlight: true,
    ),
    InfoRowData(
      icon: Icons.email_outlined,
      label: 'Email'.tr(),
      value: user.email,
      highlight: false,
    ),
    InfoRowData(
      icon: Icons.phone_outlined,
      label: 'Phone'.tr(),
      value: user.phone ?? '—',
      highlight: false,
    ),
  ],
)
```

Padding: `rw(16)` horizontal around the card.

### 7.5 _SettingsCard

Same `InfoCard` visual container but with tappable rows:

| Row | Icon | Label | Trailing | onTap |
|---|---|---|---|---|
| Theme | `Icons.dark_mode_outlined` | `'Dark Mode'.tr()` | `Switch` bound to `AppSettingsCubit.state.isDarkMode` | `switchTheme(context)` |
| Language | `Icons.language_outlined` | `'Language'.tr()` | Text showing current locale (`'English'` / `'العربية'`) | `switchLanguage(context)` |

Row height: `rh(52)`. Divider between rows: `cc.divider`.

### 7.6 _LogoutButton

```dart
CustomTextButton.filled(
  onPressed: () => AppDialogs.showConfirm(
    context,
    message: 'Are you sure you want to logout?'.tr(),
    onConfirm: () => context.read<AuthCubit>().signOut(),
  ),
  text: 'Logout'.tr(),
  backgroundColor: AppColors.red200,
  size: ButtonSize.large,
)
```

Full width with `rw(16)` horizontal margin.

### 7.7 Files Summary — Profile

| Action | File |
|---|---|
| **Rewrite** | `supervisor/features/profile/ui/supervisor_profile_screen.dart` |

No new cubits, repos, or DI changes.

---

## 8. Units Screen — Already Complete (Pushed Route)

**Path:** `lib/modules/supervisor/features/units/`

The units list screen is ✅ Complete and already accessible via `Routes.supervisorUnitsScreen` from the dashboard's Quick Actions "View Units" button (§3.5) and from the Status Grid's "Active Units" card.

**No changes needed.** Unit detail screen is a future enhancement outside this plan.

---

## 9. Route Changes

**File:** `lib/core/router/routes.dart`

No new route constants needed for this plan. All screens are either tabs (no routes) or use existing routes:
- `supervisorTaskListScreen` — exists, update to accept `TaskFilterType`.
- `supervisorUnitsScreen` — exists.
- `taskDetailsScreen` — exists (shared with worker).

**File:** `lib/core/router/app_routers.dart`

**Modify:** `supervisorTaskListScreen` case to handle `TaskFilterType` argument as described in §3.3.6.

---

## 10. Removed Items — Cleanup Checklist

| Item | Action | Reason |
|---|---|---|
| `supervisor_add_report_screen.dart` | Delete file | Feature removed |
| `lib/modules/supervisor/features/add_report/` | Delete directory | Feature removed |
| `SupervisorAdminNotificationCard` usage in dashboard | Wrap in `_showAdminNotificationCard` flag (false) | Deferred — code kept intact |
| `supervisor_admin_notification_card.dart` file | Keep unchanged | Will be enabled later |
| `supervisor_notifications_screen.dart` (empty file) | Keep (do not delete) | Will be built later |
| `SupervisorAppBar` notification bell | Make non-interactive | Deferred |
| Quick action "Report Incident" | Remove button from row only | Dashboard UI only — Reports tab untouched |

---

## 11. Bug Fix Summary

| Bug | Fix Location | Status in This Plan |
|---|---|---|
| BUG-01 (Reports tab crash) | §2 — MultiBlocProvider | ✅ Addressed |
| BUG-02 (Delayed Tasks wrong filter) | §3.3 — full query chain | ✅ Addressed |
| BUG-03 (LiveTaskSummary hardcoded) | §3.4 — real data connection | ✅ Addressed |
| BUG-04 (Admin notification card) | §3.6 — feature-flagged, code kept | ✅ Deferred by design |
| BUG-05 (Quick actions empty handlers) | §3.5 — Report Incident removed, Assign Task wired | ✅ Addressed |
| BUG-06 (Notification bell dead) | §3.2 — disabled intentionally | ✅ Deferred by design |
| BUG-07 (Pull-to-refresh placeholder) | §3.7 — wired | ✅ Addressed |
| DEBT-02 (UnitRepoImpl missing throw) | §12 below | ✅ Addressed |

---

## 12. Technical Debt Fix — UnitRepoImpl

**File:** `lib/core/shared/data/repo/unit_repo_impl.dart`

**Bug:** `getUnitData` and `fetchUnitById` use `ErrorHandler.handle(e)` without the `throw` keyword. The return type is `UnitModel` but the error path returns `void`, causing a silent failure.

**Fix:** Add `throw` before `ErrorHandler.handle(e)`:

```dart
} catch (e) {
  throw ErrorHandler.handle(e);
}
```

Apply to both methods.

---

## 13. Localization Keys

All new/modified UI strings must use `.tr()`. Add these keys to `assets/lang/en.json` and `assets/lang/ar.json` under a `supervisor` namespace:

```json
{
  "supervisor": {
    "dashboard": {
      "live_task_summary": "Live Task Summary",
      "total_tasks": "Total Tasks",
      "completed": "Completed",
      "in_progress": "In Progress",
      "pending": "Pending",
      "delayed": "Delayed",
      "assign_task": "Assign Task",
      "view_units": "View Units",
      "no_tasks_yet": "No tasks yet"
    },
    "tasks": {
      "title": "Tasks",
      "task_count": "{} tasks",
      "search_hint": "Search tasks...",
      "filter_all": "All",
      "filter_pending": "Pending",
      "filter_in_progress": "In Progress",
      "filter_completed": "Completed",
      "filter_cancelled": "Cancelled"
    },
    "profile": {
      "title": "Profile",
      "supervisor": "Supervisor",
      "full_name": "Full Name",
      "email": "Email",
      "phone": "Phone",
      "dark_mode": "Dark Mode",
      "language": "Language",
      "logout": "Logout",
      "logout_confirm": "Are you sure you want to logout?"
    }
  }
}
```

Arabic translations must be added to `ar.json` with the same key structure.

> **Existing supervisor strings** (in dashboard, reports, units screens) are still hardcoded English from prior work. Those should be migrated to `.tr()` in the same pass — add their keys under `supervisor.dashboard.*`, `supervisor.reports.*`, `supervisor.units.*`.

---

## 14. Execution Order

Execute phases in this order. Each phase is independently shippable.

```
Phase 1 — Scaffold + Crash Fixes (30 min)
  ├── §2   Add cubits to MultiBlocProvider (fixes BUG-01)
  ├── §10  Delete add_report directory
  ├── §1   Restructure scaffold to 4 tabs
  └── §3.6 Remove admin notification card from dashboard tree

Phase 2 — Dashboard Data (2–3 hrs)
  ├── §3.3 Delayed tasks query chain (BUG-02)
  ├── §3.4 LiveTaskSummary real data (BUG-03)
  ├── §3.5 QuickActionsRow rewire (BUG-05)
  ├── §3.2 Notification bell disable (BUG-06)
  └── §3.7 Pull-to-refresh wire (BUG-07)

Phase 3 — Tasks Tab (3–4 hrs)
  ├── §5.1 SupervisorTasksCubit + state + DI
  ├── §5.1 fetchAllTasks() in shared repo
  ├── §5.2 SupervisorTasksScreen full UI
  └── §5.2 SupervisorTaskFilterStrip widget

Phase 4 — Profile Tab (1–2 hrs)
  └── §7   SupervisorProfileScreen full rewrite

Phase 5 — Router + Debt (30 min)
  ├── §9   Update app_routers.dart for TaskFilterType
  └── §12  Fix UnitRepoImpl throw

Phase 6 — Localization (1–2 hrs)
  └── §13  All supervisor keys in en.json + ar.json, apply .tr() everywhere
```

---

## 15. Files Changed — Complete Index

### New Files (Create)

| File | Section |
|---|---|
| `lib/core/shared/data/models/task_filter_type.dart` | §3.3.3 |
| `lib/modules/supervisor/features/tasks/logic/cubit/supervisor_tasks_cubit.dart` | §5.1 |
| `lib/modules/supervisor/features/tasks/logic/cubit/supervisor_tasks_state.dart` | §5.1 |
| `lib/modules/supervisor/features/tasks/ui/widgets/supervisor_task_filter_strip.dart` | §5.2 |

### Modified Files

| File | Section | Change |
|---|---|---|
| `lib/modules/supervisor/core/main_navigation/supervisor_scaffold.dart` | §1 | 5→4 tabs, remove add report |
| `lib/core/auth/ui/user_authenticated_check.dart` | §2 | Add SupervisorReportsCubit + SupervisorTasksCubit to MultiBlocProvider |
| `lib/core/di/dependency_injection.dart` | §5.1 | Register SupervisorTasksCubit |
| `lib/core/shared/data/remote/task_remote_ds.dart` | §3.3.1, §5.1 | Add fetchDelayedTasks() + fetchAllTasks() |
| `lib/core/shared/data/repo/task_repo.dart` | §3.3.2, §5.1 | Add 2 abstract methods |
| `lib/core/shared/data/repo/task_repo_impl.dart` | §3.3.2, §5.1 | Implement 2 methods |
| `lib/core/shared/data/repo/unit_repo_impl.dart` | §12 | Add missing throw |
| `lib/core/router/app_routers.dart` | §3.3.6 | Handle TaskFilterType in supervisorTaskListScreen |
| `lib/modules/supervisor/features/dashboard/data/models/dashboard_stats_model.dart` | §3.4.1 | Add task ratio fields |
| `lib/modules/supervisor/features/dashboard/data/remote/dashboard_remote_ds.dart` | §3.4.2 | Add 5 count queries |
| `lib/modules/supervisor/features/dashboard/ui/supervisor_dashboard_screen.dart` | §3.6, §3.7 | Add `_showAdminNotificationCard` flag (false), wire refresh |
| `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_app_bar.dart` | §3.2 | Disable bell |
| `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_status_grid.dart` | §3.3.5 | Fix delayed card args |
| `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_live_task_summary.dart` | §3.4.3 | Connect to real data |
| `lib/modules/supervisor/features/dashboard/ui/widgets/supervisor_quick_actions_row.dart` | §3.5 | Remove Report Incident button only — Assign Task kept, Reports tab untouched |
| `lib/modules/supervisor/features/tasks/ui/supervisor_tasks_screen.dart` | §5.2 | Full rewrite from placeholder |
| `lib/modules/supervisor/features/profile/ui/supervisor_profile_screen.dart` | §7 | Full rewrite from stub |
| `assets/lang/en.json` | §13 | Add supervisor.* keys |
| `assets/lang/ar.json` | §13 | Add supervisor.* keys (Arabic) |

### Deleted Files

| File | Section |
|---|---|
| `lib/modules/supervisor/features/add_report/supervisor_add_report_screen.dart` | §10 |
| `lib/modules/supervisor/features/add_report/` (directory) | §10 |
