# Phase 1 — Supervisor Scaffold
> Supervisor Module Rebuild · GroundScope  
> Complete this phase before starting any other phase.  
> Reference: `CLAUDE.md`, `supervisor_module_reference.md`

---

## Feature 1.1 — Folder Skeleton

Create the full folder structure with empty placeholder files. Every folder must exist before code is written.

```
lib/modules/supervisor/
├── core/
│   └── main_navigation/
│       ├── cubit/
│       │   ├── supervisor_nav_cubit.dart        ← placeholder
│       │   └── supervisor_nav_state.dart        ← placeholder
│       ├── model/
│       │   └── supervisor_nav_item.dart         ← placeholder
│       └── ui/
│           └── supervisor_scaffold.dart         ← placeholder
│
└── features/
    ├── dashboard/
    │   ├── data/remote/dashboard_remote_ds.dart
    │   ├── data/repo/dashboard_repo.dart
    │   ├── data/repo/dashboard_repo_impl.dart
    │   ├── data/models/service_request_model.dart
    │   ├── logic/cubit/dashboard_cubit.dart
    │   └── ui/dashboard_screen.dart
    │   └── ui/widgets/                          ← empty folder
    ├── tasks/
    │   ├── data/remote/supervisor_task_remote_ds.dart
    │   ├── data/repo/supervisor_task_repo.dart
    │   ├── data/repo/supervisor_task_repo_impl.dart
    │   ├── logic/cubit/supervisor_tasks_cubit.dart
    │   └── ui/supervisor_tasks_screen.dart
    │   └── ui/widgets/                          ← empty folder
    ├── units/
    │   ├── data/remote/supervisor_units_remote_ds.dart
    │   ├── data/repo/supervisor_units_repo.dart
    │   ├── data/repo/supervisor_units_repo_impl.dart
    │   ├── logic/cubit/supervisor_units_cubit.dart
    │   └── ui/supervisor_units_screen.dart
    │   └── ui/widgets/                          ← empty folder
    ├── reports/
    │   ├── data/remote/supervisor_reports_remote_ds.dart
    │   ├── data/repo/supervisor_reports_repo.dart
    │   ├── data/repo/supervisor_reports_repo_impl.dart
    │   ├── logic/cubit/supervisor_reports_cubit.dart
    │   └── ui/supervisor_reports_screen.dart
    │   └── ui/widgets/                          ← empty folder
    └── profile/
        ├── logic/cubit/supervisor_profile_cubit.dart
        └── ui/supervisor_profile_screen.dart
        └── ui/widgets/                          ← empty folder
```

### Checklist
- [ ] All folders created
- [ ] All placeholder `.dart` files created (can be empty classes)
- [ ] No compilation errors after creation

---

## Feature 1.2 — Nav Cubit

**File:** `core/main_navigation/cubit/supervisor_nav_cubit.dart`

### Requirements
- State holds a single `int currentIndex` (0–4)
- Method: `void changeTab(int index)`
- Initial index: `0`
- State file is `part of` the cubit file

### Checklist
- [ ] `SupervisorNavCubit extends Cubit<SupervisorNavState>`
- [ ] `SupervisorNavState` has `currentIndex` + `copyWith`
- [ ] `changeTab(int)` emits new state
- [ ] Extends `Equatable`
- [ ] No business logic — tab index only

---

## Feature 1.3 — Scaffold UI

**File:** `core/main_navigation/ui/supervisor_scaffold.dart`

### Requirements
- Uses `BlocBuilder<SupervisorNavCubit, SupervisorNavState>`
- Body: `IndexedStack` with 5 screen placeholders
- Bottom nav: `BottomNavigationBar` with `type: fixed`
- Top border on bottom nav: `Border(top: BorderSide(color: cc.border, width: 0.5))`
- `onTap` calls `context.read<SupervisorNavCubit>().changeTab(index)`

### Nav Items
| Index | Label key | Icon |
|---|---|---|
| 0 | `supervisor_dashboard_title` | `Icons.dashboard_outlined` |
| 1 | `supervisor_tasks_title` | `Icons.check_box_outlined` |
| 2 | `supervisor_units_title` | `Icons.local_shipping_outlined` |
| 3 | `supervisor_reports_title` | `Icons.flag_outlined` |
| 4 | `supervisor_profile_title` | `Icons.account_circle_outlined` |

### Bottom Nav Styling
```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: cc.surface,
  selectedItemColor: AppColors.primary200,
  unselectedItemColor: AppColors.grey400,
  selectedLabelStyle: AppTextStyles.font12SemiBold,
  unselectedLabelStyle: AppTextStyles.font12Light,
  elevation: 0,
)
```

### Checklist
- [ ] `IndexedStack` renders correct screen per tab index
- [ ] `BottomNavigationBar` highlights active tab in `primary200`
- [ ] Top border renders on bottom nav
- [ ] Labels use `.tr()` — no hardcoded strings
- [ ] No `Scaffold` inside each tab screen at this stage (just `Container` placeholders)

---

## Feature 1.4 — DI Wiring

**File:** `lib/core/di/dependency_injection.dart`

Add all supervisor registrations. Use `registerLazySingleton` for DSes and repos, `registerFactory` for cubits.

### Registrations to add
```dart
// === SUPERVISOR MODULE ===

// Nav
getIt.registerFactory<SupervisorNavCubit>(() => SupervisorNavCubit());

// Dashboard
getIt.registerLazySingleton<DashboardRemoteDs>(
  () => DashboardRemoteDs(getIt<SupabaseService>()));
getIt.registerLazySingleton<DashboardRepo>(
  () => DashboardRepoImpl(getIt<DashboardRemoteDs>()));
getIt.registerFactory<DashboardCubit>(
  () => DashboardCubit(getIt<DashboardRepo>()));

// Tasks
getIt.registerLazySingleton<SupervisorTaskRemoteDs>(
  () => SupervisorTaskRemoteDs(getIt<SupabaseService>()));
getIt.registerLazySingleton<SupervisorTaskRepo>(
  () => SupervisorTaskRepoImpl(getIt<SupervisorTaskRemoteDs>()));
getIt.registerFactory<SupervisorTasksCubit>(
  () => SupervisorTasksCubit(getIt<SupervisorTaskRepo>()));

// Units
getIt.registerLazySingleton<SupervisorUnitsRemoteDs>(
  () => SupervisorUnitsRemoteDs(getIt<SupabaseService>()));
getIt.registerLazySingleton<SupervisorUnitsRepo>(
  () => SupervisorUnitsRepoImpl(getIt<SupervisorUnitsRemoteDs>()));
getIt.registerFactory<SupervisorUnitsCubit>(
  () => SupervisorUnitsCubit(getIt<SupervisorUnitsRepo>()));

// Reports
getIt.registerLazySingleton<SupervisorReportsRemoteDs>(
  () => SupervisorReportsRemoteDs(getIt<SupabaseService>()));
getIt.registerLazySingleton<SupervisorReportsRepo>(
  () => SupervisorReportsRepoImpl(getIt<SupervisorReportsRemoteDs>()));
getIt.registerFactory<SupervisorReportsCubit>(
  () => SupervisorReportsCubit(getIt<SupervisorReportsRepo>()));

// Profile
getIt.registerFactory<SupervisorProfileCubit>(
  () => SupervisorProfileCubit(getIt<UserService>()));
```

### Checklist
- [ ] All 5 cubits registered as `Factory`
- [ ] All DSes registered as `LazySingleton`
- [ ] All repos registered as `LazySingleton`
- [ ] No duplicate registrations
- [ ] App compiles after adding registrations

---

## Feature 1.5 — Route Registration

### `lib/core/router/routes.dart`
Add if not already present:
```dart
static const String supervisorScaffold = '/supervisorScaffold'; // verify exists
```

### `lib/core/router/app_routers.dart`
Add to `generateRoute` switch:
```dart
case Routes.supervisorScaffold:
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SupervisorNavCubit>()),
        BlocProvider(create: (_) => getIt<DashboardCubit>()),
        BlocProvider(create: (_) => getIt<SupervisorTasksCubit>()),
        BlocProvider(create: (_) => getIt<SupervisorUnitsCubit>()),
        BlocProvider(create: (_) => getIt<SupervisorReportsCubit>()),
        BlocProvider(create: (_) => getIt<SupervisorProfileCubit>()),
      ],
      child: const SupervisorScaffold(),
    ),
    transitionDuration: Duration.zero,
  );
```

### `lib/core/auth/ui/user_authenticated_check.dart`
Ensure `supervisor` role routes to `Routes.supervisorScaffold`:
```dart
case 'supervisor':
  context.pushNamedAndRemoveAll(Routes.supervisorScaffold);
```

### Checklist
- [ ] Route constant exists in `routes.dart`
- [ ] `generateRoute` handles `supervisorScaffold`
- [ ] All 6 cubits provided via `MultiBlocProvider`
- [ ] Auth gate navigates supervisor role to scaffold
- [ ] Logging in as a supervisor user opens the scaffold with 5 tabs

---

## Phase 1 — Done Criteria

- [ ] App builds with zero errors
- [ ] Logging in as a supervisor role lands on `SupervisorScaffold`
- [ ] All 5 tabs are tappable and switch the `IndexedStack`
- [ ] Active tab highlighted in `primary200`
- [ ] No hardcoded strings — all labels use `.tr()`
- [ ] No raw pixel values — all sizing uses `rw()`, `rh()`, `rr()`, `rf()`
