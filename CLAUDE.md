# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GroundScope is a Flutter graduation project for airport ground operations management. It supports three user roles — **Worker**, **Supervisor**, and **Admin** — each with their own feature modules.

## Common Commands

All common tasks are managed via `Makefile`:

```bash
make install          # flutter pub get
make dev              # Run dev flavor (main_dev.dart)
make prod             # Run prod flavor (main_prod.dart)
make generate         # One-time code generation (build_runner)
make watch            # Watch mode for code generation
make clean            # Clean and reinstall
make l10n             # Generate localization files
make test             # Run all tests
make test-verbose     # Verbose test output
make test-coverage    # Generate coverage report
make test-file FILE=path/to/test.dart  # Run single test file
```

Build commands:
```bash
make build-apk-dev    # Debug APK (dev)
make build-apk-prod   # Release APK (prod)
make build-aab-prod   # App Bundle for Play Store
make build-ios-prod   # iOS IPA (prod)
```

## Architecture

### Module Structure

The codebase uses a **modular architecture + MVVM with BLoC**. Each role is a self-contained module under `lib/modules/`:

```
lib/
├── core/                    # Shared infrastructure
│   ├── auth/                # Authentication logic + UI
│   ├── di/                  # Dependency injection (GetIt)
│   ├── error/               # AppError model + handlers
│   ├── localization/        # i18n (English + Arabic via easy_localization)
│   ├── networking/          # SupabaseService singleton wrapper
│   ├── router/              # Named routes + custom page transitions
│   ├── service/             # UserService, SecureStorage, SharedPrefsService
│   ├── settings/            # AppSettingsCubit (theme/locale)
│   ├── shared/data/         # Cross-module models (Task, Unit, Flight, etc.)
│   │                          and their repositories + remote data sources
│   ├── themes/              # Light/dark themes, AppColors, AppTextStyles
│   └── widgets/             # Reusable UI components
│
├── modules/
│   ├── worker/              # Worker role (task execution, reports)
│   ├── supervisor/          # Supervisor role (task management, units)
│   └── admin/               # Admin role (dashboard)
│
├── ground_scope_app.dart    # App root — ScreenUtilInit + MultiBlocProvider
├── main_dev.dart            # Dev entry: loads .env, sets up Supabase + DI
└── main_prod.dart           # Prod entry: same pattern as dev
```

### Feature Module Convention

Every feature inside a module follows this structure:
```
feature/
├── data/
│   ├── remote/         # Supabase API calls
│   └── repo/           # Repository implementations
├── logic/
│   └── cubit/          # Cubit + state classes
└── ui/
    ├── *_screen.dart   # Screen widget
    └── widgets/        # Feature-specific widgets
```

### Key Patterns

- **State management**: `flutter_bloc` Cubits throughout. `AuthCubit` and `AppSettingsCubit` are global (provided at app root in `ground_scope_app.dart`). Feature cubits are registered in GetIt and provided at screen level.
- **Dependency injection**: GetIt service locator. All services, data sources, repositories, and cubits are registered in `lib/core/di/dependency_injection.dart` and set up before `runApp()`.
- **Navigation**: Named routes defined in `lib/core/router/routes.dart`, resolved in `lib/core/router/app_routers.dart` with custom fade+scale+slide transitions. Each role module uses `PersistentBottomNavBar` for tab navigation.
- **Backend**: Supabase (auth + PostgreSQL database). Firebase is configured but minimally used. Credentials loaded from `.env` via `flutter_dotenv`.
- **Responsive UI**: `flutter_screenutil` with design size 390×844. Use `sp`, `w`, `h` extensions everywhere.
- **Theming**: `AppSettingsCubit` (hydrated/persistent) drives light/dark mode and locale. Fonts: Manrope (default), Tajawal (Arabic).
- **Error handling**: Wrap Supabase/Firebase calls, convert exceptions to `AppError` via `SupabaseErrorHandler`/`FirebaseErrorHandler`, emit error states from cubits.

### Auth Flow

`UserAuthenticatedCheck` (rendered as home in MaterialApp) uses `AuthCubit` to determine the initial route — it redirects to the appropriate role's scaffold or the login screen based on auth state and stored user role.

## Environment Setup

The app requires a `.env` file at the project root with:
```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

## Flavors

Two flavors: `development` and `production`. Run with:
- `--flavor development --target lib/main_dev.dart`
- `--flavor production --target lib/main_prod.dart`

## CI/CD

GitHub Actions workflow at `.github/workflows/android_fastlane_firebase_app_distribution_workflow.yml` triggers on push to `main`, builds the release APK, and distributes via Firebase App Distribution using Fastlane.
