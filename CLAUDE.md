* [ ] col1col2col3

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GroundScope is a Flutter application for managing airport ground operations. It serves three user roles — **Worker**, **Supervisor**, and **Admin** — each with dedicated feature modules. The backend is Supabase (auth + PostgreSQL + Storage) and the app supports English and Arabic.

## Architecture

**Pattern**: Modular architecture + MVVM with BLoC (Cubits).

```
lib/
├── core/                        # Shared infrastructure across all modules
│   ├── auth/                    # Authentication logic + UI
│   │   ├── data/
│   │   │   ├── models/user_date.dart          # UserModel
│   │   │   ├── remote/auth_remote_ds.dart
│   │   │   └── repo/auth_repo.dart + auth_repo_impl.dart
│   │   ├── logic/cubit/auth_cubit.dart + auth_state.dart
│   │   └── ui/
│   │       ├── login_screen.dart
│   │       ├── user_authenticated_check.dart  # Auth gate → routes to role scaffold
│   │       └── widgets/login_form.dart
│   │
│   ├── config/
│   │   └── app_config.dart      # Dev/prod env, Supabase credentials, app metadata
│   │
│   ├── di/
│   │   └── dependency_injection.dart  # GetIt registrations for ALL services/repos/cubits
│   │
│   ├── error/                   # Centralised error system
│   │   ├── models/app_error.dart          # AppError with factory constructors
│   │   ├── models/error_details.dart      # Metadata wrapper (field errors, trace IDs)
│   │   ├── types/error_type.dart          # ErrorType enum + ErrorCode class
│   │   ├── handlers/error_handler.dart    # Converts any exception → AppError
│   │   └── handlers/supabase_error_handler.dart  # AuthException, PostgrestException, StorageException
│   │
│   ├── localization/
│   │   └── localization_manager.dart  # Supported locales, translations path, fallback
│   │
│   ├── networking/
│   │   └── supabase_service.dart  # Singleton SupabaseClient wrapper + currentUser + signOut
│   │
│   ├── onboarding/
│   │   └── ui/on_boarding_screen.dart + widgets/
│   │
│   ├── router/
│   │   ├── routes.dart           # All named route constants (see Routes class below)
│   │   └── app_routers.dart      # AppRouter.generateRoute() switch-case with PageRouteBuilder
│   │
│   ├── service/
│   │   ├── secure_storage.dart   # FlutterSecureStorage wrapper (write/read/delete/clearAll)
│   │   ├── shared_prefs.dart     # SharedPreferences static helper (String/int/bool/double)
│   │   └── user_service.dart     # Reads cached UserModel from SecureStorage
│   │
│   ├── settings/
│   │   ├── cubit/app_settings_cubit.dart   # Hydrated cubit — theme + locale + fontFamily
│   │   └── cubit/app_settings_state.dart
│   │
│   ├── shared/data/             # Cross-module models, repos, and remote data sources
│   │   ├── models/
│   │   │   ├── flight_model.dart
│   │   │   ├── report_model.dart    # ReportModel + ReportType/ReportSeverity/ReportStatus enums
│   │   │   ├── service_type_model.dart
│   │   │   ├── stand_model.dart
│   │   │   ├── task_check_list_model.dart
│   │   │   ├── task_model.dart      # TaskModel + TaskPriority/TaskStatus enums
│   │   │   ├── task_pause_model.dart
│   │   │   └── unit_model.dart
│   │   ├── remote/
│   │   │   ├── flights_remote_ds.dart
│   │   │   ├── report_remote_ds.dart
│   │   │   ├── task_remote_ds.dart
│   │   │   └── unit_remote_ds.dart
│   │   └── repo/
│   │       ├── flight_repo.dart + flight_repo_impl.dart
│   │       ├── report_repo.dart + report_repo_impl.dart
│   │       ├── task_repo.dart + task_repo_impl.dart
│   │       └── unit_repo.dart + unit_repo_impl.dart
│   │
│   ├── themes/
│   │   ├── app_colors.dart       # Full color palette (primary, secondary, grey, status, bg)
│   │   ├── app_font_family.dart
│   │   ├── app_font_weight.dart  # Font weight constants
│   │   ├── app_text_styles.dart  # Predefined TextStyles (font12–font24, Light/SemiBold/ExtraBold)
│   │   ├── custom_colors.dart    # Semantic theme tokens (textPrimary, surface, border, etc.)
│   │   └── theme_data/
│   │       ├── theme_data_light.dart
│   │       └── theme_data_dark.dart
│   │
│   ├── utils/                   # Helpers, extensions, constants
│   │   ├── app_assets.dart       # Asset path constants (SVGs, PNGs, images)
│   │   ├── app_constants.dart    # navigatorKey (GlobalKey<NavigatorState>), userDataKey
│   │   ├── regex.dart            # Regex patterns: email, password, phone (Egyptian), name, Arabic
│   │   ├── spacing.dart          # rw/rh/rr/rf helpers + verticalSpacing/horizontalSpacing
│   │   ├── task_ui_helpers.dart  # TaskUiHelpers: priorityColor(), statusColor()
│   │   ├── validators.dart       # Form validators: name(), email(), password(), phoneNumber()
│   │   ├── extensions/
│   │   │   ├── context_ext.dart      # Theme, MediaQuery, Locale, SnackBar, Navigation extensions
│   │   │   ├── datetime_ext.dart     # formattedDate/Time/DateTime, isToday, isYesterday, timeAgo
│   │   │   ├── list_ext.dart         # firstOrNull, lastOrNull
│   │   │   ├── num_ext.dart          # toCurrency(), toFileSize()
│   │   │   └── string_ext.dart       # capitalize, truncate, isValidEmail/Phone/Url
│   │   └── functions/
│   │       └── app_setting_method.dart  # switchLanguage(), switchTheme() via AppSettingsCubit
│   │
│   └── widgets/                 # Reusable UI components
│       ├── custom_app_bar.dart        # Back button + centered title + optional trailing icon
│       ├── custom_icon_button.dart    # Material InkWell icon button (optional label + tooltip)
│       ├── custom_text_button.dart
│       ├── custom_text_form_.dart     # TextFormField with validation
│       ├── error_screen.dart
│       ├── info_card.dart
│       ├── info_row_data.dart         # Key-value row
│       ├── notification_button.dart
│       ├── massage_snack_bar.dart
│       ├── dialogs/
│       │   ├── app_dialogs.dart
│       │   └── custom_dialog.dart
│       └── ui/loaders/overlay_loader.dart
│
├── modules/
│   ├── worker/
│   │   ├── core/
│   │   │   └── main_navigation/
│   │   │       ├── cubit/bottom_nav_cubit.dart
│   │   │       ├── model/nav_item.dart
│   │   │       └── ui/worker_scaffold.dart   # PersistentTabView with 5 tabs
│   │   └── features/
│   │       ├── home/             # Tab 0 — task list + unit info
│   │       ├── reports/          # Tab 1 — worker's submitted reports (report_details_screen.dart pushed via Routes.reportsDetailsScreen)
│   │       ├── add_report/       # Tab 2 — report submission form (also pushable as route)
│   │       ├── notifications/    # Tab 3
│   │       ├── profile/          # Tab 4
│   │       ├── task_details/     # Pushed via Routes.taskDetailsScreen
│   │       └── task_info/        # Pushed route — lightweight task info view
│   │
│   ├── supervisor/
│   │   ├── core/main_navigation/supervisor_scaffold.dart
│   │   └── features/
│   │       ├── dashboard/        # Supervisor overview
│   │       ├── tasks/            # Task management
│   │       ├── units/            # Unit/team management
│   │       ├── reports/          # All worker reports (UI stub — data/ folder exists but is empty)
│   │       ├── notifications/
│   │       └── profile/
│   │
│   └── admin/
│       └── features/home/admin_screen.dart   # Placeholder dashboard
│
├── ground_scope_app.dart   # ScreenUtilInit + MultiBlocProvider (AppSettingsCubit, AuthCubit)
├── main_dev.dart           # Dev entry: .env → Supabase → HydratedBloc → DI → runApp
└── main_prod.dart          # Prod entry: identical pattern to dev
```

**Feature module layout** (every feature inside a module follows this exactly):

```
feature/
├── data/
│   ├── remote/         # Supabase API calls (remote data source)
│   └── repo/           # Repository interface + implementation
├── logic/
│   └── cubit/          # Cubit class + state class (state is `part of` the cubit file)
└── ui/
    ├── *_screen.dart   # Screen widget
    └── widgets/        # Feature-specific widgets only
```

---

## Key Flows

### Auth

`UserAuthenticatedCheck` watches `AuthCubit`. On `AuthSuccess` it switches on `userModel.role`:

- `unit_manager` → `MultiBlocProvider` (HomeCubit, AddReportCubit, ReportsCubit) → `WorkerScaffold`
- `supervisor` → `SupervisorScaffold`
- `admin` → `AdminScreen`

### DI

All services, data sources, repositories, and cubits are registered in `lib/core/di/dependency_injection.dart` and initialised before `runApp()`. Use `getIt<T>()` to resolve. Tab-level cubits (HomeCubit, AddReportCubit, ReportsCubit) are provided in `UserAuthenticatedCheck`'s `MultiBlocProvider`. Feature cubits for pushed routes (TaskDetailsCubit) are provided in `app_routers.dart` via `BlocProvider`.

### Navigation

`WorkerScaffold` uses `PersistentTabView` (5 tabs). The "Add Report" tab (`index 2`) embeds `AddReportScreen` directly — it is **not** pushed as a route, so `Navigator.canPop(context)` is `false` there. Cross-module and pushed screens use named routes via `Navigator.pushNamed`. Always use the context extension helpers from `context_ext.dart`.

### Error handling

Supabase/Firebase exceptions → `SupabaseErrorHandler` / `ErrorHandler` → `AppError` → emitted as failure state from cubits. Use `AppError.unknown()`, `AppError.noInternet()`, etc. as factory constructors. Display via `state.error!.messageKey`.

### Routing — all named routes

```dart
class Routes {
  static const String onBoardingScreen   = '/onBoardingScreen';
  static const String loginScreen        = '/loginScreen';
  static const String workerScaffold     = '/workerScaffold';
  static const String taskDetailsScreen  = '/taskDetailsScreen';
  static const String taskDetailsInfoScreen = '/taskDetailsInfoScreen';
  static const String addReportScreen    = '/addReportScreen';
  static const String reportsScreen      = '/reportsScreen';
  static const String reportsDetailsScreen = '/reportsDetailsScreen';
  static const String supervisorScaffold = '/supervisorScaffold';
  static const String supervisorTaskListScreen = '/supervisorTaskListScreen';
  static const String adminScreen        = '/adminScreen';
}
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

**Never use raw pixel values.** Always wrap with these helpers.

### Context Extensions (`lib/core/utils/extensions/context_ext.dart`)

```dart
context.customColors        // CustomColors (light/dark semantic tokens)
context.isDarkMode          // bool
context.screenWidth         // double
context.isArabic            // bool
context.pop()               // Navigator.pop — guards with mounted check
context.pushNamed(Routes.x) // named navigation
context.showErrorSnackBar('msg')
context.showSuccessSnackBar('msg')
```

### DateTime Extensions (`lib/core/utils/extensions/datetime_ext.dart`)

```dart
report.createdAt.timeAgo          // "2 hours ago"
report.createdAt.formattedDate    // "30/04/2026"
report.createdAt.formattedTime    // "14:30"
report.createdAt.isToday          // bool
```

### Task UI Helpers (`lib/core/utils/task_ui_helpers.dart`)

```dart
TaskUiHelpers.priorityColor(task.priority)      // Color by priority enum
TaskUiHelpers.statusColor(task.status, context) // Color by status enum
```

### Validators (`lib/core/utils/validators.dart`)

```dart
Validators.email(value)       // returns String? error message
Validators.password(value)    // checks uppercase, digit, special char, min 8 chars
Validators.name(value)
Validators.phoneNumber(value) // supports Egyptian format
```

### App Assets (`lib/core/utils/app_assets.dart`)

```dart
AppAssets.appLogoSVG     // 'assets/svgs/...'
AppAssets.appLogoPNG     // 'assets/images/app_logo.png'
AppAssets.onBoardingHero // 'assets/images/on_boarding_hero.png'
AppAssets.workerTest     // 'assets/images/worker_test.png'
```

---

## Tech Stack

| Category          | Package                   | Version  |
| ----------------- | ------------------------- | -------- |
| State management  | flutter_bloc              | ^9.1.1   |
| Persistent state  | hydrated_bloc             | ^11.0.0  |
| DI                | get_it                    | ^9.0.5   |
| Backend           | supabase_flutter          | ^2.10.3  |
| Firebase          | firebase_core             | ^4.2.1   |
| Responsive sizing | flutter_screenutil        | ^5.9.3   |
| Navigation        | persistent_bottom_nav_bar | ^6.2.1   |
| Localization      | easy_localization         | ^3.0.8   |
| Env vars          | flutter_dotenv            | ^6.0.0   |
| Secure storage    | flutter_secure_storage    | ^10.0.0  |
| SVG               | flutter_svg               | ^2.2.2   |
| Image caching     | cached_network_image      | ^3.4.1   |
| Animations        | flutter_animate           | ^4.5.2   |
| Equality          | equatable                 | ^2.0.8   |
| Image picking     | image_picker              | (latest) |

Fonts: **Manrope** (default, 7 weights), **Tajawal** (Arabic, 7 weights). Design canvas: **390×844**.

---

## Conventions

### Naming

- Cubits: `FeatureNameCubit` / states: `FeatureNameState`
- Screens: `feature_name_screen.dart` → `FeatureNameScreen`
- Remote data sources: `FeatureNameRemoteDs`
- Repositories: `FeatureNameRepo` (abstract) + `FeatureNameRepoImpl`
- Routes: constants in `lib/core/router/routes.dart`, switch-case in `app_routers.dart`
- State file is always `part of` the cubit file (not a standalone file)

### Sizing

Always use `flutter_screenutil` extensions — `.sp` for font sizes, `.w`/`.h` for widths/heights, `.r` for radii. Never use raw pixel values.

### Strings

All user-facing strings must go through `easy_localization` (`.tr()` extension). Add keys to both `assets/lang/en.json` and `assets/lang/ar.json`.

### Global vs local cubits

- **Global** (app root via `MultiBlocProvider` in `UserAuthenticatedCheck`): `AuthCubit`, `AppSettingsCubit`, `HomeCubit`, `AddReportCubit`, `ReportsCubit`
- **Route-level** (in `app_routers.dart` per-route `BlocProvider`): `TaskDetailsCubit`
- Never put feature-specific logic in global cubits

### `AddReportScreen` — dual context

This screen is used both as **tab 2** of `WorkerScaffold` (no route to pop) and as a **pushed named route** (poppable). Always guard any back-navigation with `Navigator.canPop(context)`.

---

## Error Handling Pattern

```dart
// In a cubit method:
try {
  final result = await repo.someCall();
  emit(state.copyWith(status: MyStatus.success, data: result));
} on AppError catch (e) {
  emit(state.copyWith(status: MyStatus.failure, error: e));
} catch (_) {
  emit(state.copyWith(status: MyStatus.failure, error: AppError.unknown()));
}

// AppError factory constructors:
AppError.unknown([String? message])
AppError.noInternet()
AppError.timeout()
AppError.unauthorized()
AppError.serverError()
```

---

## Common Commands

```bash
make install          # flutter pub get
make dev              # Run dev flavor (lib/main_dev.dart)
make prod             # Run prod flavor (lib/main_prod.dart)
make generate         # One-time build_runner code generation
make watch            # Watch mode for code generation
make clean            # Clean + reinstall
make l10n             # Generate localization files
make test             # Run all tests
make test-verbose     # Verbose test output
make test-coverage    # Generate coverage report
make test-file FILE=path/to/test.dart  # Run a single test file
make build-apk-dev    # Debug APK (dev flavor)
make build-apk-prod   # Release APK (prod flavor)
make build-aab-prod   # App Bundle for Play Store
make build-ios-prod   # iOS IPA (prod flavor)
```

Environment: requires a `.env` file at the project root:

```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

---

## Do

- Follow the `data/logic/ui` feature folder structure for every new feature.
- Register every new cubit, repository, and data source in `lib/core/di/dependency_injection.dart`.
- Add every new route as a constant in `lib/core/router/routes.dart` and handle it in `app_routers.dart`.
- Use `AppError` + the appropriate error handler when catching Supabase or Firebase exceptions.
- Use `AppTextStyles` and `AppColors` / `CustomColors` from `lib/core/themes/` for all styling.
- Reuse shared models from `lib/core/shared/data/` (Task, Unit, Flight, Report…) before creating new ones.
- Use `SecureStorage` for sensitive data (tokens, credentials) and `SharedPrefsService` for non-sensitive preferences.
- Use `TaskUiHelpers` for task/priority colours; follow the same pattern for other domain-specific colour logic.
- Use `context_ext.dart` navigation helpers (`context.pushNamed`, `context.pop`) — never raw `Navigator` widget push.
- Use `validators.dart` for all form field validation.
- Check `Navigator.canPop(context)` before popping when a screen can be both a tab and a pushed route.

## Don't

- Don't hardcode pixel values — always use `flutter_screenutil` extensions (`.sp`, `.w`, `.h`, `.r`).
- Don't hardcode user-facing strings — always use `easy_localization` `.tr()`.
- Don't access the Supabase client directly — always go through `SupabaseService` or a repository.
- Don't put feature-specific logic or state in global cubits (`AuthCubit`, `AppSettingsCubit`).
- Don't skip the repository layer — UI/cubits must never call remote data sources directly.
- Don't mix Worker, Supervisor, or Admin UI code across modules; keep each role fully self-contained.
- Don't use raw `Navigator.push` with widget constructors for inter-screen navigation — use named routes.
- Don't call `context.pop()` unconditionally on screens that can appear as both a tab and a pushed route.
- Don't inline `TextStyle(...)` or raw `Color(0x...)` values — always use `AppTextStyles` and `AppColors`.
