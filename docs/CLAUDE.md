# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GroundScope is a Flutter application for managing airport ground operations. It serves three user roles — **Worker**, **Supervisor**, and **Admin** — each with dedicated feature modules. The backend is Supabase (auth + PostgreSQL + Storage) and the app supports English and Arabic.

## Architecture

**Pattern**: Modular architecture + MVVM with BLoC (Cubits).

```
lib/
├── core/                        # Shared infrastructure across all modules
│   ├── api/                     # Dio HTTP client (consumer, interceptors, factory)
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/user_date.dart          # UserModel
│   │   │   ├── remote/auth_remote_ds.dart
│   │   │   └── repo/auth_repo.dart + auth_repo_impl.dart
│   │   ├── logic/cubit/auth_cubit.dart + auth_state.dart
│   │   └── ui/
│   │       ├── login_screen.dart
│   │       ├── user_authenticated_check.dart  # Auth gate → routes to role scaffold
│   │       └── widgets/login_form.dart
│   ├── config/
│   │   ├── app_config.dart
│   │   └── firebase_options.dart
│   ├── di/
│   │   └── dependency_injection.dart  # GetIt registrations for ALL services/repos/cubits
│   ├── error/
│   │   ├── models/app_error.dart + error_details.dart
│   │   ├── types/error_type.dart + error_handler.dart
│   │   └── handlers/supabase_error_handler.dart + firebase_error_handler.dart
│   ├── localization/
│   │   └── localization_manager.dart
│   ├── networking/
│   │   └── supabase_service.dart
│   ├── onboarding/ui/on_boarding_screen.dart + widgets/
│   ├── router/
│   │   ├── routes.dart           # All named route constants
│   │   └── app_routers.dart      # AppRouter.generateRoute() switch-case
│   ├── service/
│   │   ├── secure_storage.dart
│   │   ├── shared_prefs.dart
│   │   └── user_service.dart     # Reads cached UserModel from SecureStorage (async getUser())
│   ├── settings/
│   │   └── cubit/app_settings_cubit.dart + app_settings_state.dart
│   ├── shared/data/
│   │   ├── models/               # Cross-module domain models (see list below)
│   │   ├── remote/               # Shared remote data sources (Supabase)
│   │   ├── repo/                 # Shared repository interfaces + implementations
│   │   └── ui/widgets/credentials_share_sheet.dart
│   ├── themes/
│   │   ├── app_colors.dart       # Full palette + AppColors.primaryGradient
│   │   ├── app_text_styles.dart  # font12–font24 × Light/SemiBold/ExtraBold
│   │   ├── custom_colors.dart    # Semantic tokens (textPrimary, surface, border…)
│   │   └── theme_data/theme_data_light.dart + theme_data_dark.dart
│   ├── utils/
│   │   ├── app_assets.dart
│   │   ├── app_constants.dart    # navigatorKey, userDataKey
│   │   ├── spacing.dart          # rw/rh/rr/rf + verticalSpacing/horizontalSpacing
│   │   ├── task_ui_helpers.dart  # priorityColor(), statusColor()
│   │   ├── validators.dart
│   │   ├── credentials_generator.dart
│   │   ├── extensions/context_ext.dart + datetime_ext.dart + list_ext.dart + …
│   │   └── functions/app_setting_method.dart  # switchLanguage(), switchTheme()
│   └── widgets/                  # Shared UI components (see list below)
│
├── modules/
│   ├── worker/           # Role: unit_manager
│   ├── supervisor/       # Role: supervisor
│   └── admin/            # Role: admin
│
├── ground_scope_app.dart  # ScreenUtilInit + MultiBlocProvider (AppSettingsCubit, AuthCubit)
├── main_dev.dart
└── main_prod.dart
```

**Feature module layout** (every feature follows this exactly):

```
feature/
├── data/
│   ├── remote/   # Supabase API calls
│   └── repo/     # Abstract interface + implementation
├── logic/
│   └── cubit/    # XxxCubit + XxxState (state is `part of` the cubit file)
└── ui/
    ├── xxx_screen.dart
    └── widgets/
```

---

## Shared Domain Models (`lib/core/shared/data/models/`)

| File | Contents |
|---|---|
| `flight_model.dart` | `FlightModel` |
| `report_model.dart` | `ReportModel` + `ReportType` / `ReportSeverity` / `ReportStatus` enums |
| `service_type_model.dart` | `ServiceTypeModel` |
| `service_request_model.dart` | `ServiceRequestModel` |
| `stand_model.dart` | `StandModel` |
| `task_model.dart` | `TaskModel` + `TaskPriority` / `TaskStatus` enums |
| `task_check_list_model.dart` | `TaskCheckListModel` |
| `task_pause_model.dart` | `TaskPauseModel` |
| `unit_model.dart` | `UnitModel` + `UnitStatus` enum; includes `shiftLabel` getter, `members: List<UnitMemberModel>`, `serviceTypeName` |
| `unit_member_model.dart` | `UnitMemberModel` |
| `unit_profile_model.dart` | `UnitStatus` enum (referenced by UnitModel) |
| `generated_credentials.dart` | `GeneratedCredentials` |

---

## Shared Core Widgets (`lib/core/widgets/`)

| File | Purpose |
|---|---|
| `custom_app_bar.dart` | Back button + centered title + optional trailing |
| `custom_icon_button.dart` | InkWell icon button with optional label |
| `custom_text_button.dart` | Primary + `CustomTextButton.outlined()` named ctor; `CustomButtonSize.small/medium/large`; `isFullWidth` |
| `custom_text_form_.dart` | TextFormField with validation |
| `error_screen.dart` | Full-screen error with retry callback |
| `filter_pills.dart` | Horizontal scrollable filter chips; `filters`, `filterLabels`, `activeFilter`, `onFilterChanged` |
| `search_with_counter.dart` | Search field + result counter below; `hintText`, `onChanged`, `resultCount` |
| `info_card.dart` | Key-value card; takes `List<InfoRowData>`; `rr(14)` card |
| `info_row_data.dart` | Data class for InfoCard rows: `icon`, `label`, `value`, `highlight`, `valueColor` |
| `notification_button.dart` | Bell icon button |
| `massage_snack_bar.dart` | Styled snackbar |
| `ui/dialogs/app_dialogs.dart` | `AppDialogs.showConfirm(context, message:, onConfirm:, …)` — always use instead of raw showDialog |
| `ui/dialogs/custom_dialog.dart` | Low-level dialog shell |
| `ui/loaders/overlay_loader.dart` | Full-screen loading overlay |

---

## Module: Worker (`lib/modules/worker/`)

**Role key**: `unit_manager`

**Navigation**: `WorkerScaffold` uses `PersistentTabView` (5 tabs).

| Tab | Feature | Cubit |
|---|---|---|
| 0 | Home (task list) | `HomeCubit` |
| 1 | Reports (my reports) | `ReportsCubit` |
| 2 | Add Report | `AddReportCubit` |
| 3 | Notifications | — |
| 4 | Profile | `ProfileCubit` |

**Pushed routes**: `taskDetailsScreen` → `TaskDetailsScreen` (cubit provided in `app_routers.dart`), `taskDetailsInfoScreen`, `addReportScreen`, `reportsScreen`, `reportsDetailsScreen`, `workerManagerAndMembersScreen`, `workerMemberDetailScreen`.

**Key note**: `AddReportScreen` is both tab 2 (not poppable) and a pushed route — guard all back-nav with `Navigator.canPop(context)`.

**Localization**: All worker UI strings are fully localized via `easy_localization`. Namespaced keys used:

| Namespace | Coverage |
|---|---|
| `worker_home.*` | Greeting, "On Shift", filter chips (All/Assigned/In Progress/Paused/Done), empty states |
| `worker_add_report.*` | Form labels, image picker, task selector, success/error messages |
| `worker_reports.*` | App bar title/subtitle, filter strip, empty states, report detail row labels |
| `worker_task_details.*` | Header, meta section, checklist, notes, pause history, action buttons, dialogs |

Reused top-level keys: `good_morning/afternoon/evening`, `filter_all`, `filter_in_progress`, `filter_open`, `filter_acknowledged`, `filter_resolved`, `retry`, `cancel`, `checklist`, `scheduled_start`, `scheduled_end`, `task_info`, `task_details`, `primary_info`, `report_id`, `report_type`, `report_severity`, `attached_evidence`, `evidence`, `tap_to_expand`, `no_photo_attached`, `timeline`, `filed`, `at`, `acknowledged`, `resolved`, `something_went_wrong`, `image_picker.take_photo`, `image_picker.choose_from_gallery`.

---

## Module: Supervisor (`lib/modules/supervisor/`)

**Role key**: `supervisor`

**Navigation**: `SupervisorScaffold` — `IndexedStack` + `BottomNavigationBar` (5 tabs). Tab cubit: `SupervisorNavCubit`.

| Tab | Feature | Screen | Cubit |
|---|---|---|---|
| 0 | Dashboard | `SupervisorDashboardScreen` | `DashboardCubit` + `AssignUnitCubit` |
| 1 | Tasks | `SupervisorTasksScreen` | `SupervisorTasksCubit` |
| 2 | Units | `SupervisorUnitsScreen` | `SupervisorUnitsCubit` |
| 3 | Reports | `SupervisorReportsScreen` | `SupervisorReportsCubit` |
| 4 | Profile | `SupervisorProfileScreen` | `SupervisorProfileCubit` |

All 5 cubits are provided via `MultiBlocProvider` in `UserAuthenticatedCheck` (not the scaffold).

### Dashboard
- Stats grid: active tasks, pending requests, units available
- Service requests section: lists `tasks` with `status='pending'` and `unit_id IS NULL`
- Assign unit flow: `AssignUnitBottomSheet` → updates `tasks.unit_id`, `tasks.assigned_by`, `tasks.status='in_progress'`
- **No `flight_service_requests` table** — pending service requests ARE tasks with no unit

### Tasks Tab
- Realtime + manual refresh; `FilterPills` + `SearchWithCounter`
- Filters: `all`, `pending`, `in_progress`, `completed`, `cancelled`
- Card: left accent bar (`rw(4)`) colored by status; priority badge; wrapped in `IntrinsicHeight` (fixes infinite-height crash with `CrossAxisAlignment.stretch`)

### Units Tab
- Realtime stream (`SupervisorUnitsCubit._subscription`); no `RefreshIndicator`
- Stream doesn't support joins → initial fetch gets members, stream merges with existing member data
- `UnitStatusCard` → `UnitDetailBottomSheet` (shift, service type, compatible aircraft, crew list)
- `_subscription?.cancel()` in `cubit.close()`

### Reports Tab
- `FilterPills`: `all`, `open`, `acknowledged`, `resolved`
- Optimistic updates on acknowledge/resolve — changes local state immediately
- Per-card loading spinner via `actionReportId: String?` in state
- `actionReportId` uses sentinel-object pattern in `copyWith` to allow nullable clearing
- `AppDialogs.showConfirm` required before all actions
- Top accent bar (`rh(4)`) colored by severity
- **FAB** on `SupervisorReportsScreen` → navigates to `SupervisorAddReportScreen` (see Add Report feature)

### Add Report Feature (`lib/modules/supervisor/features/add_report/`)

Full data/logic/ui feature allowing supervisors to file reports without an associated task.

```
add_report/
├── data/
│   ├── remote/supervisor_add_report_remote_ds.dart   # Inserts into `reports` table; uploads to `report-images` bucket
│   └── repo/
│       ├── supervisor_add_report_repo.dart             # Abstract interface
│       └── supervisor_add_report_repo_impl.dart        # Delegates to remote DS
├── logic/cubit/
│   ├── supervisor_add_report_cubit.dart               # selectTarget, selectType, selectSeverity, pickImage, removeImage, submit, resetForm
│   └── supervisor_add_report_state.dart               # SupervisorAddReportStatus enum + SupervisorAddReportState
└── ui/
    └── supervisor_add_report_screen.dart              # Full form screen with animated Send To selector, type/severity pickers, description, image picker
```

**Key design decisions:**
- `reportedTo: 'admin' | 'worker'` — animated two-card selector; admin card = `AppColors.secondary200` (red), worker card = `AppColors.primary200` (blue)
- No `task_id` or `flight_id` in the insert — supervisor reports are standalone; **DB requires these columns to be nullable** and a `reported_to TEXT` column to exist
- Image picker widgets are self-contained inline in the screen (not reused from worker's `AddReportCubit`)
- Error display: `state.error?.serverMessage ?? state.error?.messageKey ?? 'Something went wrong'`
- DI: `SupervisorAddReportRemoteDs` and `SupervisorAddReportRepo` are `registerLazySingleton`; `SupervisorAddReportCubit` is `registerFactory`

**Required DB migration** (run once in Supabase):
```sql
ALTER TABLE reports ALTER COLUMN task_id DROP NOT NULL;
ALTER TABLE reports ALTER COLUMN flight_id DROP NOT NULL;
ALTER TABLE reports ADD COLUMN IF NOT EXISTS reported_to TEXT;
```

### Profile Tab
- Reads from `UserService.getUser()` — **no network call**, cache only
- `SupervisorProfileCubit` injects `UserService`, calls `await getUser()`
- Header: gradient matching dashboard, avatar with initials (max 2 letters)
- Settings tiles: language (`switchLanguage`), dark mode (`switchTheme`), notifications (no-op), logout (`AppDialogs.showConfirm` → `AuthCubit.logout()`)

---

## Module: Admin (`lib/modules/admin/`)

**Role key**: `admin`

**Navigation**: Single `AdminDashboardScreen` with feature cards that push named routes.

| Feature | Routes | Cubits |
|---|---|---|
| Dashboard | `adminDashboardScreen` | `AdminDashboardCubit` |
| Flights | `adminFlightsScreen`, `adminFlightDetailScreen` | `FlightsListCubit`, `FlightImportCubit` |
| Service Types | `adminServiceTypesScreen`, `adminServiceTypeFormScreen` | `ServiceTypesListCubit`, `ServiceTypeFormCubit` |
| Stands | `adminStandsScreen`, `adminStandFormScreen` | `StandsListCubit`, `StandFormCubit` |
| Units | `adminUnitsScreen`, `adminUnitDetailScreen`, `adminUnitFormScreen` | `UnitsListCubit`, `UnitDetailCubit`, `UnitFormCubit`, `UnitMemberCubit` |
| Users | `adminUsersScreen` | `UsersListCubit`, `UserResetCubit` |
| Service Requests | `adminFlightServiceRequestScreen` | `ServiceRequestCubit` |

---

## Key Flows

### Auth

`UserAuthenticatedCheck` watches `AuthCubit`. On `AuthSuccess` it switches on `userModel.role`:

- `unit_manager` → `MultiBlocProvider` (HomeCubit, AddReportCubit, ReportsCubit, ProfileCubit) → `WorkerScaffold`
- `supervisor` → `MultiBlocProvider` (DashboardCubit, SupervisorTasksCubit, SupervisorUnitsCubit, SupervisorReportsCubit, SupervisorProfileCubit) → `SupervisorScaffold`
- `admin` → `AdminDashboardScreen`

### DI

All services, remote data sources, repositories, and cubits are registered in `lib/core/di/dependency_injection.dart`. Use `getIt<T>()` to resolve.

- **Singletons** (`registerLazySingleton`): services (SecureStorage, SupabaseService, UserService), all remote DSes and repos
- **Factories** (`registerFactory`): all cubits — fresh instance on each `getIt<XxxCubit>()` call

### Navigation — all named routes

```dart
class Routes {
  // Auth / Onboarding
  static const onBoardingScreen   = '/onBoardingScreen';
  static const loginScreen        = '/loginScreen';

  // Worker
  static const workerScaffold                  = '/workerScaffold';
  static const taskDetailsScreen               = '/taskDetailsScreen';
  static const taskDetailsInfoScreen           = '/taskDetailsInfoScreen';
  static const addReportScreen                 = '/addReportScreen';
  static const reportsScreen                   = '/reportsScreen';
  static const reportsDetailsScreen            = '/reportsDetailsScreen';
  static const workerManagerAndMembersScreen   = '/workerManagerAndMembersScreen';
  static const workerMemberDetailScreen        = '/workerMemberDetailScreen';

  // Supervisor
  static const supervisorScaffold              = '/supervisorScaffold';
  static const supervisorTaskListScreen        = '/supervisorTaskListScreen';

  // Admin
  static const adminDashboardScreen            = '/adminDashboardScreen';
  static const adminUnitsScreen                = '/adminUnitsScreen';
  static const adminUnitDetailScreen           = '/adminUnitDetailScreen';
  static const adminUnitFormScreen             = '/adminUnitFormScreen';
  static const adminServiceTypesScreen         = '/adminServiceTypesScreen';
  static const adminServiceTypeFormScreen      = '/adminServiceTypeFormScreen';
  static const adminStandsScreen               = '/adminStandsScreen';
  static const adminStandFormScreen            = '/adminStandFormScreen';
  static const adminFlightsScreen              = '/adminFlightsScreen';
  static const adminFlightDetailScreen         = '/adminFlightDetailScreen';
  static const adminUsersScreen                = '/adminUsersScreen';
  static const adminFlightServiceRequestScreen = '/adminFlightServiceRequestScreen';
}
```

### Error handling

```dart
try {
  final result = await repo.someCall();
  emit(state.copyWith(status: MyStatus.success, data: result));
} on AppError catch (e) {
  emit(state.copyWith(status: MyStatus.failure, error: e));
} catch (e) {
  // Always use SupabaseErrorHandler — never swallow with catch (_)
  emit(state.copyWith(status: MyStatus.failure, error: SupabaseErrorHandler.handle(e)));
}

// AppError factory constructors:
AppError.unknown([String? message])
AppError.noInternet()
AppError.timeout()
AppError.unauthorized()
AppError.serverError()
```

**Critical**: Never use `catch (_)` — it discards real server errors. Always `catch (e)` + `SupabaseErrorHandler.handle(e)` so `serverMessage` is preserved and shown to the user.

---

## Localization

All user-facing strings use `easy_localization` (`.tr()`). JSON files: `assets/lang/en.json` and `assets/lang/ar.json`.

### Key namespaces

| Namespace | Module | Description |
|---|---|---|
| `errors.*` | Global | Network / auth / server error messages |
| `app_dialogs.*` | Global | Dialog button labels (cancel, ok, confirm…) |
| `image_picker.*` | Global | take_photo, choose_from_gallery, upload_image |
| `auth.*` | Auth | Login form strings + validation messages |
| `worker_profile.*` | Worker | Profile screen + settings section |
| `worker_home.*` | Worker | Greeting, shift status, task filter chips, empty states |
| `worker_add_report.*` | Worker | Add report form: labels, hints, task selector, image picker |
| `worker_reports.*` | Worker | Reports list: app bar, filters, empty states, detail row labels |
| `worker_task_details.*` | Worker | Task detail: header, meta, checklist, pause history, action buttons, dialogs |

### Named args pattern

```dart
// Simple
'worker_home.on_shift'.tr()

// With named args
'worker_home.no_status_tasks'.tr(namedArgs: {'status': status.label})
'worker_task_details.stand'.tr(namedArgs: {'code': task.standCode!})
'worker_task_details.resumed_after'.tr(namedArgs: {'minutes': '${p.duration.inMinutes}'})
```

### Section headers (uppercase display)

Store keys in Title Case, apply `.toUpperCase()` in the widget:
```dart
title: 'primary_info'.tr().toUpperCase()   // → "PRIMARY INFO" / "المعلومات الأساسية"
title: 'timeline'.tr().toUpperCase()
```

---

## Utilities Quick Reference

### Spacing (`lib/core/utils/spacing.dart`)

```dart
rw(20)   // responsive width   → 20.w
rh(16)   // responsive height  → 16.h
rr(12)   // responsive radius  → 12.r
rf(14)   // responsive font    → 14.sp
verticalSpacing(8)    // SizedBox(height: 8.h)
horizontalSpacing(8)  // SizedBox(width: 8.w)
```

**Never use raw pixel values.**

### Context Extensions (`lib/core/utils/extensions/context_ext.dart`)

```dart
context.customColors         // CustomColors semantic tokens
context.isDarkMode           // bool
context.isArabic             // bool
context.screenWidth          // double
context.pop()                // guarded Navigator.pop
context.pushNamed(Routes.x)
context.showErrorSnackBar('msg')
context.showSuccessSnackBar('msg')
context.showMessageSnackBar('msg', type: SnackBarType.success/error)
```

### DateTime Extensions

```dart
dt.timeAgo        // "2 hours ago"
dt.formattedDate  // "30/04/2026"
dt.formattedTime  // "14:30"
dt.isToday        // bool
```

### Task UI Helpers

```dart
TaskUiHelpers.priorityColor(task.priority)       // Color by TaskPriority
TaskUiHelpers.statusColor(task.status, context)  // Color by TaskStatus
```

### App Settings

```dart
switchLanguage(context)  // toggles locale via AppSettingsCubit
switchTheme(context)     // toggles light/dark via AppSettingsCubit
```

---

## Colors & Gradients

```dart
AppColors.primary200          // #2FA4D7 — main brand blue
AppColors.primaryGradient     // LinearGradient topLeft→bottomRight: [primary100, primary200, primary300]
AppColors.green200            // #22C55E
AppColors.red200              // #EF4444
AppColors.amber200            // #F59E0B
AppColors.secondary200        // #D12052

// Semantic tokens (theme-aware):
context.customColors.textPrimary
context.customColors.textSecondary
context.customColors.textHint
context.customColors.surface
context.customColors.background
context.customColors.border
context.customColors.divider
context.customColors.iconSecondary
```

---

## Tech Stack

| Category | Package | Version |
|---|---|---|
| State management | flutter_bloc | ^9.1.1 |
| Persistent state | hydrated_bloc | ^11.0.0 |
| DI | get_it | ^9.0.5 |
| Backend | supabase_flutter | ^2.10.3 |
| Firebase | firebase_core | ^4.2.1 |
| Responsive sizing | flutter_screenutil | ^5.9.3 |
| Navigation | persistent_bottom_nav_bar | ^6.2.1 |
| Localization | easy_localization | ^3.0.8 |
| Env vars | flutter_dotenv | ^6.0.0 |
| Secure storage | flutter_secure_storage | ^10.0.0 |
| SVG | flutter_svg | ^2.2.2 |
| Image caching | cached_network_image | ^3.4.1 |
| Animations | flutter_animate | ^4.5.2 |
| Equality | equatable | ^2.0.8 |
| Image picking | image_picker | (latest) |

Fonts: **Manrope** (default, 7 weights), **Tajawal** (Arabic). Design canvas: **390×844**.

---

## Conventions

### Naming

- Cubits: `FeatureNameCubit` / state: `FeatureNameState` (`part of` cubit file)
- Screens: `feature_name_screen.dart` → `FeatureNameScreen`
- Remote DS: `FeatureNameRemoteDs`
- Repos: `FeatureNameRepo` (abstract) + `FeatureNameRepoImpl`
- Route constants in `routes.dart`; switch-case in `app_routers.dart`

### Sizing

Always `flutter_screenutil` — `.sp`/`.w`/`.h`/`.r` or the `rw/rh/rr/rf` helpers. Never raw pixel values.

### Strings

All user-facing strings via `easy_localization` (`.tr()`). Add to both `assets/lang/en.json` and `assets/lang/ar.json`. Use namespaced keys for feature-specific strings (e.g. `worker_home.*`, `worker_add_report.*`). Reuse existing top-level keys where they already exist.

### AppDialogs

Always use `AppDialogs.showConfirm(context, message:, onConfirm:)` — never raw `showDialog` for confirmation flows.

### Realtime streams

Cancel subscription in `cubit.close()`:
```dart
StreamSubscription? _subscription;

@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}
```

Supabase `.stream()` does **not** support joins — do the initial fetch with `.select('*, related(*)')`, then merge incoming stream data with existing joined data from state.

### Nullable `copyWith` fields

When a state field must be clearable to `null` via `copyWith`, use the sentinel-object pattern:
```dart
const _clear = Object();

SomeState copyWith({ Object? myNullableField = _clear }) {
  return SomeState(
    myNullableField: identical(myNullableField, _clear)
        ? this.myNullableField
        : myNullableField as String?,
  );
}
```

---

## Do

- Follow the `data/logic/ui` folder structure for every feature.
- Register every new cubit, repo, and DS in `dependency_injection.dart`.
- Add every new route to `routes.dart` and handle it in `app_routers.dart`.
- Use `AppError` factory constructors for all exception handling.
- Use `SupabaseErrorHandler.handle(e)` in every `catch (e)` block — never `catch (_)`.
- Use `AppTextStyles.*` and `AppColors.*` / `context.customColors.*` for all styling.
- Reuse shared models from `lib/core/shared/data/models/` before creating new ones.
- Use `AppDialogs.showConfirm` before any destructive action.
- Use `TaskUiHelpers` for task/priority colours.
- Use `context_ext.dart` helpers — never raw `Navigator.push`.
- Use `filter_pills.dart` and `search_with_counter.dart` for filter+search UIs.

## Don't

- Don't hardcode pixel values — always `rw/rh/rr/rf`.
- Don't hardcode user-facing strings — always `.tr()`.
- Don't use `catch (_)` — it swallows real server error messages; always `catch (e)`.
- Don't access Supabase client directly — always via `SupabaseService` or a repo.
- Don't put feature logic in global cubits (`AuthCubit`, `AppSettingsCubit`).
- Don't skip the repository layer.
- Don't mix Worker/Supervisor/Admin UI across modules.
- Don't use raw `Navigator.push` with widget constructors.
- Don't inline `TextStyle(…)` or `Color(0x…)` — always `AppTextStyles.*` and `AppColors.*`.
- Don't call `context.pop()` unconditionally on dual-context screens (tab + pushed route).
- Don't use raw `showDialog` for confirmations — use `AppDialogs.showConfirm`.

---

## Common Commands

```bash
make install        # flutter pub get
make dev            # Run dev flavor
make prod           # Run prod flavor
make clean          # Clean + reinstall
make l10n           # Generate localization
make test           # Run all tests
make build-apk-dev  # Debug APK
make build-apk-prod # Release APK
make build-aab-prod # App Bundle
```

Environment: requires `.env` at project root:
```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```