# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GroundScope is a Flutter application for managing airport ground operations. It serves three user roles — **Worker**, **Supervisor**, and **Admin** — each with dedicated feature modules. The backend is Supabase (auth + PostgreSQL) and the app supports English and Arabic.

## Architecture

**Pattern**: Modular architecture + MVVM with BLoC (Cubits).

```
lib/
├── core/                    # Shared infrastructure across all modules
│   ├── auth/                # Authentication logic + UI
│   ├── di/                  # Dependency injection (GetIt)
│   ├── error/               # AppError model + SupabaseErrorHandler / FirebaseErrorHandler
│   ├── localization/        # i18n (English + Arabic via easy_localization)
│   ├── networking/          # SupabaseService singleton wrapper
│   ├── router/              # Named routes (routes.dart) + transitions (app_routers.dart)
│   ├── service/             # UserService, SecureStorage, SharedPrefsService
│   ├── settings/            # AppSettingsCubit — theme + locale (hydrated/persistent)
│   ├── shared/data/         # Cross-module models (Task, Unit, Flight…) + repos + remote DSs
│   ├── themes/              # Light/dark ThemeData, AppColors, AppTextStyles
│   └── widgets/             # Reusable UI components
│
├── modules/
│   ├── worker/              # Worker role: task execution, reports
│   ├── supervisor/          # Supervisor role: task management, units, reports
│   └── admin/               # Admin role: dashboard
│
├── ground_scope_app.dart    # App root — ScreenUtilInit + MultiBlocProvider (global cubits)
├── main_dev.dart            # Dev entry: .env → Supabase → DI → runApp
└── main_prod.dart           # Prod entry: identical pattern to dev
```

**Feature module layout** (every feature inside a module follows this exactly):
```
feature/
├── data/
│   ├── remote/         # Supabase API calls (remote data source)
│   └── repo/           # Repository interface + implementation
├── logic/
│   └── cubit/          # Cubit class + state class
└── ui/
    ├── *_screen.dart   # Screen widget
    └── widgets/        # Feature-specific widgets only
```

**Key flows**:
- **Auth**: `UserAuthenticatedCheck` (app home widget) uses `AuthCubit` to redirect to the correct role scaffold or login.
- **DI**: All services, data sources, repositories, and cubits are registered in `lib/core/di/dependency_injection.dart` and initialized before `runApp()`.
- **Navigation**: `PersistentBottomNavBar` for in-module tab navigation. Cross-module navigation uses named routes via `Navigator.pushNamed`.
- **Error handling**: Supabase/Firebase exceptions → `AppError` via error handlers → emitted as error states from cubits.

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

Fonts: **Manrope** (default), **Tajawal** (Arabic). Design canvas: **390×844**.

## Conventions

**Naming**:
- Cubits: `FeatureNameCubit` / states: `FeatureNameState` (sealed or with subtypes)
- Screens: `feature_name_screen.dart` → `FeatureNameScreen`
- Remote data sources: `FeatureNameRemoteDs`
- Repositories: `FeatureNameRepo` (abstract) + `FeatureNameRepoImpl`
- Routes: constants in `lib/core/router/routes.dart`, switch-case in `app_routers.dart`

**Sizing**: Always use `flutter_screenutil` extensions — `.sp` for font sizes, `.w`/`.h` for widths/heights, `.r` for radii. Never use raw pixel values.

**Strings**: All user-facing strings must go through `easy_localization` (`.tr()` extension). Add keys to both `assets/lang/en.json` and `assets/lang/ar.json`.

**Global vs local cubits**: `AuthCubit` and `AppSettingsCubit` are provided at the app root. All feature cubits are provided at the screen level using `BlocProvider(create: (_) => sl<FeatureCubit>())`.

**Code generation**: Models using `freezed` or `json_serializable` require `make generate` (or `make watch` during development) after changes.

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

## Do

- Follow the `data/logic/ui` feature folder structure for every new feature.
- Register every new cubit, repository, and data source in `lib/core/di/dependency_injection.dart`.
- Add every new route as a constant in `lib/core/router/routes.dart` and handle it in `app_routers.dart`.
- Use `AppError` + the appropriate error handler when catching Supabase or Firebase exceptions.
- Use `AppTextStyles` and `AppColors` from `lib/core/themes/` for consistent styling.
- Reuse shared models from `lib/core/shared/data/` (Task, Unit, Flight, etc.) before creating new ones.
- Use `SecureStorage` for sensitive data (tokens, credentials) and `SharedPrefsService` for non-sensitive preferences.

## Don't

- Don't hardcode pixel values — always use `flutter_screenutil` extensions (`.sp`, `.w`, `.h`, `.r`).
- Don't hardcode user-facing strings — always use `easy_localization` `.tr()`.
- Don't access the Supabase client directly — always go through `SupabaseService` or a repository.
- Don't put feature-specific logic or state in global cubits (`AuthCubit`, `AppSettingsCubit`).
- Don't skip the repository layer — UI/cubits must never call remote data sources directly.
- Don't mix Worker, Supervisor, or Admin UI code across modules; keep each role fully self-contained.
- Don't use raw `Navigator` push with widget constructors for inter-screen navigation — use named routes.
