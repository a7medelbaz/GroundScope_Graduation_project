<!--
SYNC IMPACT REPORT
==================
Version change: [TEMPLATE] → 1.0.0
Modified principles: N/A (initial fill)
Added sections:
  - Core Principles (5 principles)
  - Development Standards
  - Quality & Workflow
  - Governance
Removed sections: None (template placeholders replaced)
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ — Constitution Check section aligns with principles
  - .specify/templates/spec-template.md ✅ — Scope/requirements section matches FR/SC pattern
  - .specify/templates/tasks-template.md ✅ — Phase structure and task types consistent
  - .specify/templates/checklist-template.md ✅ — No principle-breaking references found
  - .specify/templates/constitution-template.md ✅ — Source template, no changes required
Deferred TODOs: None — all placeholders resolved from CLAUDE.md context.
-->

# GroundScope Constitution

## Core Principles

### I. Modular Role-Based Architecture

Every feature MUST live inside exactly one role module (`worker`, `supervisor`, or `admin`).
No UI, cubit, or data-source code MAY cross module boundaries. Shared domain models
(Task, Flight, Report, Unit, Stand) belong exclusively in `lib/core/shared/data/`.
Each feature MUST follow the canonical folder layout: `data/remote/`, `data/repo/`,
`logic/cubit/`, and `ui/` (screen + widgets subdirectory). Cross-feature navigation
MUST use named routes defined in `lib/core/router/routes.dart` — raw `Navigator.push`
with widget constructors is prohibited.

**Rationale**: Role isolation prevents accidental coupling between Worker, Supervisor,
and Admin flows, making it safe to evolve each role independently without regression risk.

### II. Repository Pattern — No Direct Backend Access

Cubits and screens MUST NOT call Supabase (or any external SDK) directly. All remote
operations MUST flow through: Remote Data Source → Repository Implementation → Repository
Interface. The Supabase client MUST only be accessed via `SupabaseService`; raw
`Supabase.instance.client` calls outside of a Remote Data Source are prohibited.

**Rationale**: The repository layer is the single seam for mocking, retrying, and
swapping backends (e.g., migrating tables or switching auth providers) without
touching business logic or UI.

### III. BLoC/Cubit State Management (Non-Negotiable)

All state MUST be managed through Cubits. UI widgets MUST NOT hold mutable business
state via `setState` beyond local widget-only concerns (e.g., focus, animation).
Global cubits (AuthCubit, AppSettingsCubit, HomeCubit, AddReportCubit, ReportsCubit)
MUST be provided at the app root via `MultiBlocProvider` in `UserAuthenticatedCheck`.
Feature/route-scoped cubits MUST be provided at route level in `app_routers.dart`.
Cubit state files MUST be declared as `part of` the cubit file — never as standalone.
All exceptions from remote calls MUST be caught, converted to `AppError` via
`ErrorHandler` / `SupabaseErrorHandler`, and emitted as a failure state — never
swallowed or rethrown raw to the UI.

**Rationale**: A uniform state contract lets every screen handle loading, success,
and failure predictably, and makes the error story auditable and testable.

### IV. Responsive UI — No Raw Pixel Values

Every size value (width, height, font, radius, spacing) MUST use `flutter_screenutil`
extensions: `.w`, `.h`, `.sp`, `.r`. Spacing MUST use `rw()`, `rh()`, `rr()`, `rf()`,
`verticalSpacing()`, or `horizontalSpacing()` from `lib/core/utils/spacing.dart`.
All colours MUST reference `AppColors` or `CustomColors` (semantic tokens). All text
styles MUST use `AppTextStyles` — inline `TextStyle(...)` or raw `Color(0x...)` are
prohibited. Design canvas is 390×844; ScreenUtil is initialized once in
`ground_scope_app.dart`.

**Rationale**: Raw pixel values break layouts on every device size and require
per-screen overrides. A single responsive system keeps the UI consistent across
phones, tablets, and orientations.

### V. Localization-First & Accessibility

Every user-facing string MUST go through `easy_localization` (`.tr()` extension).
Hardcoded English strings in widgets or cubits are prohibited. Keys MUST be added
to both `assets/lang/en.json` and `assets/lang/ar.json` in the same commit.
Arabic layout MUST be verified after any UI change (`context.isArabic` helper is
available). `AppAssets` constants MUST be used for all asset paths — no inline string
literals for asset paths.

**Rationale**: The app serves English and Arabic users in airport operations; a
missed translation key breaks the UI for half the user base and violates
accessibility expectations.

## Development Standards

**Dependency Injection**: Every new cubit, repository, and data source MUST be
registered in `lib/core/di/dependency_injection.dart` before first use. Resolution
MUST use `getIt<T>()`. No manual instantiation of services inside widgets or cubits.

**Routing**: Every new screen MUST have a named-route constant in `lib/core/router/routes.dart`
and a corresponding `case` in `AppRouter.generateRoute()`. Context extension helpers
(`context.pushNamed`, `context.pop`) MUST be used — never raw `Navigator` widget push.

**Error Handling**: Cubits MUST follow the try-catch pattern:
catch `AppError` first, then catch all (`_`) and emit `AppError.unknown()`.
Never use `on Exception` or `on Error` as the primary catch clause.

**Naming Conventions**:

- Cubits: `FeatureNameCubit` / States: `FeatureNameState`
- Screens: `feature_name_screen.dart` → `FeatureNameScreen`
- Remote data sources: `FeatureNameRemoteDs`
- Repositories: `FeatureNameRepo` (abstract) + `FeatureNameRepoImpl`

**Dual-Context Screens**: Any screen that can appear both as a persistent tab and
as a pushed route (e.g., `AddReportScreen`) MUST guard back-navigation with
`Navigator.canPop(context)` before calling `context.pop()`.

**Sensitive Data**: Tokens and credentials MUST use `SecureStorage`
(`lib/core/service/secure_storage.dart`). Non-sensitive preferences MUST use
`SharedPrefsService`. Never store credentials in plain SharedPreferences.

## Quality & Workflow

**Testing**: Unit tests MUST cover cubit state transitions (loading → success/failure).
Integration tests MUST cover repository implementations against Supabase. Widget tests
MUST cover critical user flows (auth gate, tab navigation, form submission).
Run `make test` before every PR; failing tests block merge.

**Code Review Gates**: Every PR MUST pass the constitution check below before merge:

- [ ] No raw pixel values introduced
- [ ] No hardcoded user-facing strings (no missing `.tr()`)
- [ ] No direct Supabase client calls outside Remote Data Sources
- [ ] No cross-module UI/cubit imports
- [ ] New routes registered in `routes.dart` and `app_routers.dart`
- [ ] New DI registrations in `dependency_injection.dart`
- [ ] Both `en.json` and `ar.json` updated for new/changed string keys
- [ ] `AppError` used for all caught exceptions

**Performance**: Network images MUST use `CachedNetworkImage`. SVGs MUST use
`flutter_svg`. Animations MUST use `flutter_animate` — no custom `AnimationController`
unless `flutter_animate` cannot express the required effect.

**Security**: MUST NOT store Supabase credentials in source code.
Credentials MUST come from the `.env` file loaded via `flutter_dotenv` and MUST be
excluded from version control (`.gitignore` must include `.env`).

## Governance

**Authority**: This constitution supersedes all other practices and guidelines in
this repository. In any conflict between CLAUDE.md, a PR comment, or verbal
agreement, this constitution takes precedence. CLAUDE.md is a supplementary
developer guide that MUST remain consistent with this constitution.

**Amendment Procedure**: Amendments require:

1. A written proposal explaining the motivation and the principle being changed.
2. Approval from the project lead (Ahmed Elbaz) before merging.
3. A migration plan if existing code violates the amended principle.
4. Version bump following semantic versioning (see below).
5. A commit message of the form: `docs: amend constitution to vX.Y.Z (summary)`.

**Versioning Policy**:

- MAJOR: Backward-incompatible governance changes — principle removals or redefinitions
  that require significant code migration.
- MINOR: New principle or section added, or materially expanded guidance that new
  features must follow.
- PATCH: Clarifications, wording corrections, typo fixes, non-semantic refinements.

**Compliance Review**: Compliance MUST be verified during code review via the Quality
& Workflow gate checklist above. Automated lint rules (if present) supplement but do
not replace the manual checklist.

**Runtime Guidance**: For day-to-day development conventions, commands, and
architecture details consult `CLAUDE.md` at the repository root.

---

**Version**: 1.0.0 | **Ratified**: 2026-05-16 | **Last Amended**: 2026-05-16
