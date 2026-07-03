# GroundScope — Complete System Reference

This document is the single source of truth for the GroundScope project.
Read this at the start of every Claude Code session before touching any file.

---

# 1. Project Overview

**GroundScope** is a Flutter-based airport ground services coordination platform
built as a university graduation project.

**Purpose:** Coordinate all ground services for flights at an airport —
from the moment a flight is scheduled until it departs.

**Three user roles:**
| Role | Who | Responsibilities |
|------|-----|-----------------|
| `admin` | Airport operations manager | Manages flights, stands, service requests, units, users, reports |
| `supervisor` | Service type lead (e.g. Fuel Supervisor) | Creates tasks, assigns units, monitors services, manages reports |
| `unit_manager` | Ground crew lead | Executes tasks, updates status, submits reports |

---

# 2. Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| State management | flutter_bloc (Cubit pattern) |
| Dependency injection | get_it |
| Backend | Supabase (PostgreSQL + RLS + Edge Functions + Real-time) |
| Push notifications | Firebase Cloud Messaging (FCM V1 API) |
| Localization | easy_localization (Arabic + English) |
| Responsive sizing | flutter_screenutil (canvas: 390×844) |
| Animations | flutter_animate |
| HTTP | dio |
| Image caching | cached_network_image |
| Secure storage | flutter_secure_storage |
| External flight data | AviationStack API |

---

# 3. Architecture

### Layer order (strict — never skip)
```
ui/ → logic/cubit/ → data/repo/ → data/remote/
```

### Project structure
```
lib/
├── core/
│   ├── auth/                    ← login, auth cubit, user model
│   ├── di/
│   │   └── dependency_injection.dart
│   ├── error/
│   │   ├── models/app_error.dart
│   │   └── handlers/supabase_error_handler.dart
│   ├── notifications/           ← full notification system
│   │   ├── data/models/notification_model.dart
│   │   ├── data/remote/notification_remote_ds.dart
│   │   ├── data/repo/notification_repo.dart
│   │   ├── logic/cubit/notification_cubit.dart
│   │   ├── service/notification_service.dart
│   │   ├── service/notification_sender.dart
│   │   ├── service/notification_navigator.dart
│   │   └── ui/notifications_screen.dart
│   ├── router/
│   │   ├── routes.dart
│   │   └── app_routers.dart
│   ├── shared/
│   │   └── data/
│   │       ├── models/          ← all shared models
│   │       ├── remote/          ← all remote data sources
│   │       └── repo/            ← all repos + impls
│   ├── themes/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── custom_colors.dart
│   ├── utils/
│   │   ├── extensions/context_ext.dart
│   │   ├── spacing.dart
│   │   ├── credentials_generator.dart
│   │   └── flight_status_checker.dart
│   └── widgets/                 ← shared reusable widgets
│
└── modules/
    ├── admin/features/
    │   ├── dashboard/
    │   ├── flights/
    │   ├── stands/
    │   ├── service_requests/
    │   ├── service_types/
    │   ├── units/
    │   ├── users/
    │   └── reports/             ← NEW (to be built)
    ├── supervisor/features/
    │   ├── dashboard/
    │   ├── tasks/
    │   ├── units/
    │   ├── reports/             ← NEW (to be built)
    │   └── notifications/
    └── worker/features/
        ├── home/
        ├── task_details/
        ├── reports/             ← EXISTS (needs refactor)
        ├── add_report/          ← EXISTS (needs refactor)
        └── notifications/
```

---

# 4. Design System Rules

### CRITICAL — always follow these

**Sizing — never raw pixels:**
```dart
rw(20)   // responsive width
rh(16)   // responsive height
rr(12)   // responsive radius
rf(14)   // responsive font
```

**Colors — never raw Color():**
```dart
// Context-aware (prefer these)
context.customColors.background
context.customColors.surface
context.customColors.surfaceVariant
context.customColors.textPrimary
context.customColors.textSecondary
context.customColors.textHint
context.customColors.textDisabled
context.customColors.border
context.customColors.iconPrimary
context.customColors.iconSecondary

// Static accent colors
AppColors.primary200
AppColors.secondary200
AppColors.blue200
AppColors.green200
AppColors.amber200
AppColors.amber400
AppColors.red200
AppColors.red0
AppColors.error
AppColors.grey400
AppColors.white
AppColors.black
```

**Typography — never inline TextStyle:**
```dart
AppTextStyles.font12Light / font12Regular / font12SemiBold / font12ExtraBold
AppTextStyles.font14Light / font14Regular / font14SemiBold / font14Bold / font14ExtraBold
AppTextStyles.font16SemiBold / font16Bold
AppTextStyles.font18SemiBold / font18Bold
AppTextStyles.font20Bold / font20ExtraBold
AppTextStyles.font22ExtraBold

// Color override only:
AppTextStyles.font14SemiBold.copyWith(color: context.customColors.textSecondary)
```

**Fonts:**
- English → Manrope
- Arabic → Tajawal

**Spacing:**
```dart
verticalSpacing(12)    // SizedBox(height: rh(12))
horizontalSpacing(8)   // SizedBox(width: rw(8))
```

**Animations — entrance only:**
```dart
Widget().animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0)
// List stagger: delay: Duration(milliseconds: (index * 40).clamp(0, 300))
```

**Loading — always shimmer skeletons, never CircularProgressIndicator for pages**

**Navigation — always named routes:**
```dart
context.pushNamed(Routes.myScreen, arguments: {'key': value})
context.pop()
```

**Localization — every string must use .tr():**
- Add all keys to BOTH `assets/lang/en.json` AND `assets/lang/ar.json`

---

# 5. Database Schema

## Core Tables

### users
```
id              uuid PK
full_name       text
email           text UNIQUE
phone           text NULLABLE
role            user_role enum
service_type_id uuid FK → service_types NULLABLE
unit_id         uuid FK → units NULLABLE
fcm_token       text NULLABLE         ← saved on login, cleared on logout
is_active       boolean DEFAULT true
auth_id         uuid NULLABLE         ← linked to Supabase auth.users
created_at      timestamptz
```

### flights
```
id                   uuid PK
flight_number        text
airline              text
origin               text
destination          text
aircraft_type        text NULLABLE
aircraft_registration text NULLABLE
scheduled_arrival    timestamptz
estimated_arrival    timestamptz NULLABLE
actual_arrival       timestamptz NULLABLE
scheduled_departure  timestamptz NULLABLE
actual_departure     timestamptz NULLABLE
stand_id             uuid FK → stands NULLABLE
status               flight_status enum
pax_count            int NULLABLE
api_source           text NULLABLE
external_id          text UNIQUE NULLABLE
flight_type          text DEFAULT 'arrival'
created_at           timestamptz
```

### stands
```
id                  uuid PK
code                text UNIQUE
terminal            text NULLABLE
compatible_aircraft text[] NULLABLE
has_camera          boolean DEFAULT false
is_active           boolean DEFAULT true
created_at          timestamptz
```

### service_types
```
id         uuid PK
name       text
icon       text NULLABLE
color      text NULLABLE
is_active  boolean DEFAULT true
created_at timestamptz
```

### units
```
id              uuid PK
name            text
service_type_id uuid FK → service_types
status          unit_status enum DEFAULT 'available'
is_active       boolean DEFAULT true
created_at      timestamptz
```

### tasks
```
id              uuid PK
flight_id       uuid FK → flights
service_type_id uuid FK → service_types
unit_id         uuid FK → units
assigned_by     uuid FK → users
scheduled_start timestamptz NULLABLE
scheduled_end   timestamptz NULLABLE
actual_start    timestamptz NULLABLE
actual_end      timestamptz NULLABLE
status          task_status enum DEFAULT 'assigned'
priority        task_priority enum DEFAULT 'medium'
notes           text NULLABLE
created_at      timestamptz
updated_at      timestamptz
```

### task_checklists
```
id          uuid PK
task_id     uuid FK → tasks (CASCADE)
item        text
is_checked  boolean DEFAULT false
checked_at  timestamptz NULLABLE
checked_by  uuid FK → users NULLABLE
order_index int DEFAULT 0
```

### task_pauses
```
id         uuid PK
task_id    uuid FK → tasks (CASCADE)
reason     text
paused_by  uuid FK → users
resumed_at timestamptz NULLABLE
created_at timestamptz
```

### flight_service_requests
```
id              uuid PK
flight_id       uuid FK → flights
service_type_id uuid FK → service_types
status          service_request_status enum DEFAULT 'pending'
created_by      uuid FK → users
created_at      timestamptz
updated_at      timestamptz
```

### reports
```
id                uuid PK
task_id           uuid FK → tasks NULLABLE      ← nullable (standalone reports allowed)
flight_id         uuid FK → flights NULLABLE
reported_by       uuid FK → users
type              report_type enum
description       text
severity          report_severity enum
status            report_status enum DEFAULT 'open'
direction         report_direction enum          ← indicates communication direction
forwarded_from_id uuid FK → reports NULLABLE     ← self-reference for forwarding
forwarder_notes   text NULLABLE
acknowledged_by   uuid FK → users NULLABLE
acknowledged_at   timestamptz NULLABLE
resolved_by       uuid FK → users NULLABLE
resolved_at       timestamptz NULLABLE
image_url         text NULLABLE
created_at        timestamptz
```

### report_recipients (NEW)
```
id          uuid PK
report_id   uuid FK → reports (CASCADE)
user_id     uuid FK → users (CASCADE)
is_read     boolean DEFAULT false
read_at     timestamptz NULLABLE
created_at  timestamptz
UNIQUE(report_id, user_id)
```

### notifications
```
id             uuid PK
user_id        uuid FK → users
title          text
body           text
type           notification_type enum
reference_id   uuid NULLABLE
reference_type text NULLABLE
is_read        boolean DEFAULT false
sent_via_fcm   boolean DEFAULT false
created_at     timestamptz
```

---

# 6. Database Enums (EXACT VALUES)

```sql
flight_status:
  scheduled, landed, in_service, ready, departed, cancelled

unit_status:
  available, busy, offline, maintenance

task_status:
  pending, assigned, in_progress, paused, completed, cancelled

task_priority:
  low, medium, high, critical

user_role:
  admin, supervisor, unit_manager

service_request_status:
  pending, assigned, in_progress, completed, cancelled

notification_type:
  task_assigned, alert, delay, report, flight_landed

report_type:
  issue, delay, damage, safety, other

report_severity:
  low, medium, high, critical

report_status:
  open, acknowledged, in_progress, resolved

report_direction:
  worker_to_supervisor, supervisor_to_unit, supervisor_to_admin,
  admin_to_supervisor, admin_broadcast
```

---

# 7. Real-time Tables

These tables are enabled in Supabase real-time publication:

```sql
public.tasks
public.flight_service_requests
public.units
public.notifications
public.reports
public.report_recipients
```

---

# 8. Supabase Edge Functions (Deployed)

### send-notification
Sends FCM V1 push notification + inserts to notifications table.

```dart
// Call from Flutter:
await _supabase.client.functions.invoke('send-notification', body: {
  'user_id':        userId,
  'title':          title,
  'body':           body,
  'type':           'task_assigned',  // notification_type enum value
  'reference_id':   referenceId,      // nullable
  'reference_type': 'task',           // nullable
});
```

### create-user
Creates Supabase auth user + public.users record using service role key.

### reset-user-password
Resets a user's auth password via admin API.

---

# 9. Notification System

## Architecture
```
lib/core/notifications/
├── service/notification_service.dart   ← FCM init, token, foreground handler
├── service/notification_sender.dart    ← one-line send helper
├── service/notification_navigator.dart ← tap-to-navigate handler
├── data/models/notification_model.dart
├── data/remote/notification_remote_ds.dart
├── data/repo/notification_repo.dart
├── logic/cubit/notification_cubit.dart
└── ui/notifications_screen.dart        ← shared screen for all roles
```

## How to send a notification from any feature
```dart
await NotificationSender.send(
  userId:        targetUserId,
  title:         'New Task Assigned',
  body:          'Fueling task for EK202 assigned to your unit',
  type:          NotificationType.taskAssigned,
  referenceId:   taskId,
  referenceType: 'task',
);
// Always silent fail — never blocks main action
```

## FCM Token lifecycle
- Saved to `users.fcm_token` on login
- Cleared from `users.fcm_token` on logout
- Uses FCM V1 API (legacy API is disabled)
- Uses Service Account JSON (stored as FIREBASE_SERVICE_ACCOUNT secret in Supabase)

---

# 10. Complete Feature Flow

## Flight lifecycle
```
scheduled → landed → in_service → ready → departed
```

| Status | Trigger | Who |
|--------|---------|-----|
| `scheduled` | AviationStack API import | Auto |
| `landed` | `scheduledArrival` time passed | Auto on load |
| `in_service` | First task starts | Worker action |
| `ready` | All service requests completed | Auto |
| `departed` | `scheduledDeparture` time passed | Auto on load |
| `cancelled` | Manual | Admin |

## Service request flow
```
Admin creates flight_service_request (status: pending)
  → Real-time: Supervisor dashboard updates instantly

Supervisor creates task + assigns unit
  → tasks.status = 'assigned'
  → units.status = 'busy'
  → flight_service_requests.status = 'assigned'
  → Notification → Unit Manager

Worker starts task
  → tasks.status = 'in_progress'
  → flight_service_requests.status = 'in_progress'

Worker completes task
  → tasks.status = 'completed'
  → units.status = 'available'
  → flight_service_requests.status = 'completed'
  → Notification → Supervisor

All FSRs for flight completed
  → flight.status = 'ready'
```

## Report flow
```
Worker submits report → supervisor(s) notified
Supervisor can:
  → View inbox (all reports from units)
  → Send alert to specific unit
  → Broadcast to all units in service type
  → Forward report to admin (with own notes)
Admin can:
  → View ALL reports across app
  → Send alert to specific supervisor(s)
  → Broadcast to everyone
  → See communication flow by direction
```

---

# 11. RLS Critical Notes

- `get_my_role()` returns null if `users.auth_id` is null → all write operations fail
- Admin fix: `UPDATE public.users SET auth_id = '<auth_uid>' WHERE email = 'admin@airport.com'`
- Service role key (in Edge Functions) bypasses all RLS
- Always check RLS policies first when debugging permission errors

## Important RLS policies applied
```sql
-- task_checklists INSERT (supervisor + admin)
-- notifications INSERT (supervisor + admin)
-- unit_manager_update_own_unit (units UPDATE)
-- supervisor_update_service_type_units (units UPDATE)
-- worker_update_fsr (flight_service_requests UPDATE)
-- report_recipients INSERT (all roles)
-- reports INSERT (any authenticated)
-- reports SELECT per role
```

---

# 12. Android Build Configuration (PINNED)

**Do not change these versions:**

```kotlin
// android/settings.gradle.kts
id("com.android.application") version "8.11.1" apply false
id("com.google.gms.google-services") version "4.4.1" apply false
id("org.jetbrains.kotlin.android") version "2.2.20" apply false
```

```kotlin
// android/app/build.gradle.kts
compileSdk = 36
minSdk = 21
targetSdk = 36
coreLibraryDesugaring("com.android.tools.desugar_jdk_libs:2.1.4")
```

```properties
# android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-bin.zip
```

```yaml
# pubspec.yaml — pinned (no ^ on these two)
supabase_flutter: 2.12.4
flutter_local_notifications: 18.0.1
```

---

# 13. Dependency Injection Rules

File: `lib/core/di/dependency_injection.dart`

```dart
// Remote DS → always LazySingleton
getIt.registerLazySingleton<MyRemoteDs>(() => MyRemoteDs(getIt()));

// Repo → always LazySingleton
getIt.registerLazySingleton<MyRepo>(() => MyRepoImpl(getIt()));

// Cubit → always Factory (new instance per screen)
getIt.registerFactory<MyCubit>(() => MyCubit(getIt()));
```

**Rules:**
- NEVER re-register an existing registration
- NEVER use `getIt<SomeCubit>()` inside UI widgets → use `context.read<SomeCubit>()`
- `getIt<>()` only in route handlers and app-level providers

---

# 14. Credentials System

```dart
CredentialsGenerator.supervisorEmail(name)    // → supervisor.{slug}@groundscope.com
CredentialsGenerator.unitManagerEmail(name)   // → manager.{slug}@groundscope.com
CredentialsGenerator.generatePassword()       // → GroundScope{4digits}{special}
```

---

# 15. Current Build Status

## Completed Features

| Feature | Module | Status |
|---------|--------|--------|
| Login / Auth | All | ✅ Done |
| FCM token save on login | Auth | ✅ Done |
| Notification system | Core | ✅ Done |
| Admin dashboard | Admin | ✅ Done |
| Flights management (AviationStack) | Admin | ✅ Done |
| Stands management | Admin | ✅ Done |
| Service requests (create/view) | Admin | ✅ Done |
| Units management | Admin | ✅ Done |
| Users management (create/reset) | Admin | ✅ Done |
| Supervisor dashboard | Supervisor | ✅ Done |
| Create task + assign unit | Supervisor | ✅ Done |
| Supervisor tasks screen | Supervisor | ✅ Done |
| Supervisor units screen | Supervisor | ✅ Done |
| Worker home (task list) | Worker | ✅ Done |
| Worker task details | Worker | ✅ Done |
| Worker add report | Worker | ✅ Done |
| Worker reports history | Worker | ✅ Done |
| Flight status auto-update | Admin | ✅ Done |
| Status sync (task→unit→FSR) | All | ✅ Done |
| Real-time (all key tables) | All | ✅ Done |
| Logout navigation fix | Auth | ✅ Done |

## In Progress / Next

| Feature | Module | Status |
|---------|--------|--------|
| Reports system refactor | All | 🔄 Planned (prompt ready) |
| Supervisor reports module | Supervisor | 🔄 Planned |
| Admin reports module | Admin | 🔄 Planned |
| Notification real-time badge | All | 🔄 Partially done |
| FCM push on real device | All | ⏳ Needs real device test |

---

# 16. Known Issues & Fixes Applied

| Issue | Fix |
|-------|-----|
| task_checklists INSERT RLS missing | Added `checklists_insert` policy |
| Admin auth_id was null | `UPDATE users SET auth_id = '...'` |
| Logout not navigating | Changed `getIt<AuthCubit>()` to `context.read<AuthCubit>()` |
| AviationStack 429 rate limit | Created new account + better error message |
| Stand scheduled flights not showing | Removed `gte` time filter from query |
| FCM V1 (legacy disabled) | Switched to V1 with service account JWT |
| notifications INSERT RLS missing | Added `notifications_insert` policy |
| report reference_id NOT NULL | `ALTER TABLE reports ALTER COLUMN reference_id DROP NOT NULL` |
| report flight_id NOT NULL (blocked standalone admin/supervisor reports) | `ALTER TABLE reports ALTER COLUMN flight_id DROP NOT NULL` |
| reports query joined non-existent `profiles` table (`PGRST200`) | Changed `reporter:profiles!reported_by(...)` to `reporter:users!reported_by(...)` in `report_remote_ds.dart` |
| report/alert notifications didn't navigate anywhere on tap | Added `report`/`alert` cases to `NotificationNavigator._navigateByType`, fetching the report and routing by current user's role |
| Android build: desugar mismatch | Pinned versions (see section 12) |
| Flutter pub upgrade breaking build | Pinned `supabase_flutter: 2.12.4` + `flutter_local_notifications: 18.0.1` |

---

# 17. Supervisor Module Note

The supervisor module was built by a teammate.
**Make surgical edits only — do NOT refactor, restructure, or rename.**

Key supervisor files (treat as read-only unless specifically editing):
```
lib/modules/supervisor/features/dashboard/data/remote/dashboard_remote_ds.dart
lib/modules/supervisor/features/dashboard/logic/cubit/dashboard_cubit.dart
lib/modules/supervisor/features/dashboard/ui/supervisor_dashboard_screen.dart
lib/modules/supervisor/core/main_navigation/supervisor_scaffold.dart
```

---

# 18. Worker Module Note

The worker module is stable and working.
**Do NOT touch worker UI screens unless specifically refactoring reports.**

Worker task flow:
- Tasks identified by `flightNumber` + `serviceTypeName` (no title field)
- Tasks fetched by `unit_id`
- Status flow: `assigned → in_progress → paused → in_progress → completed`
- Checklists: `task_checklists` rows with `item`, `is_checked: false`, `order_index`

---

# 19. Important Patterns

### Soft delete (never hard delete)
```dart
await supabase.from('units').update({'is_active': false}).eq('id', id);
```

### Error handling in cubits
```dart
try {
  // ...
} on AppError catch (e) {
  emit(state.copyWith(status: MyStatus.failure, error: e));
} catch (_) {
  emit(state.copyWith(status: MyStatus.failure, error: AppError.unknown()));
}
```

### Real-time stream (always cancel in close())
```dart
StreamSubscription? _sub;

void startWatch(String userId) {
  _sub?.cancel();
  _sub = _repo.watchItems(userId).listen(
    (items) => emit(state.copyWith(items: items)),
    onError: (e) => debugPrint('Error: $e'),
  );
}

@override
Future<void> close() {
  _sub?.cancel();
  return super.close();
}
```

### Notification send (always silent fail)
```dart
// Use NotificationSender.send() — never call Edge Function directly
await NotificationSender.send(
  userId: targetUserId,
  title: 'Title',
  body: 'Body',
  type: NotificationType.taskAssigned,
  referenceId: id,
  referenceType: 'task',
);
// No try/catch needed — sender handles it internally
```

---

# 20. Session Start Protocol

At the start of every Claude Code session:
1. Read this file completely
2. Read `lib/core/di/dependency_injection.dart`
3. Read `lib/core/router/routes.dart`
4. Read ONLY the files relevant to the current task

Do NOT read all project files upfront.
Do NOT start writing code before completing the audit.

---

# 21. How to Build a New Feature

1. Read this reference file
2. Audit shared layer — check if model/DS/repo already exists
3. Check DI — is it already registered?
4. Check routes — already exists?
5. **Data**: model → remote DS → repo abstract → repo impl
6. **Logic**: state → cubit
7. **UI**: screen → widgets (tile, skeleton, empty state)
8. Register in DI
9. Add routes
10. Add localization to both lang files

---

# 22. Critical Do-Nots

```
❌ Never raw pixels — always rw/rh/rr/rf
❌ Never raw Color() — always context.customColors or AppColors
❌ Never inline TextStyle — always AppTextStyles
❌ Never hardcoded strings — always .tr()
❌ Never Navigator.push — always context.pushNamed
❌ Never CircularProgressIndicator for page load — always shimmer
❌ Never hard delete — always is_active = false
❌ Never getIt<SomeCubit>() in UI — always context.read<SomeCubit>()
❌ Never skip the audit step
❌ Never put models/repos inside feature folders
❌ Never forget to cancel stream subscriptions in close()
❌ Never let notification failure block main action
❌ Never re-register existing DI entries
❌ Never run flutter pub upgrade — breaks pinned packages
❌ Never touch supervisor module structure without care
❌ Never touch worker UI screens (except reports refactor)
```
