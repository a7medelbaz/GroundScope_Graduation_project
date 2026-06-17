# Phase 2 — Dashboard
> Supervisor Module Rebuild · GroundScope  
> Prerequisite: Phase 1 complete.  
> Reference: `supervisor_module_reference.md` §4.1, `design_system.md`

---

## Feature 2.1 — `ServiceRequestModel`

**File:** `features/dashboard/data/models/service_request_model.dart`

### Requirements
```dart
class ServiceRequestModel extends Equatable {
  final String id;
  final String flightId;
  final String serviceTypeId;
  final String requestedBy;
  final String? assignedSupervisorId;
  final String status;         // 'pending' | 'assigned' | 'completed'
  final String? notes;
  final DateTime createdAt;
  final FlightModel? flight;   // joined from flights table
}
```

- `fromJson(Map<String, dynamic> json)` factory
- `flight` parsed from nested `json['flights']` if present
- `toJson()` not required (read-only model)

### Checklist
- [ ] All fields present
- [ ] `fromJson` handles null `flights` key gracefully
- [ ] `props` includes all fields
- [ ] Extends `Equatable`

---

## Feature 2.2 — Dashboard Remote DS

**File:** `features/dashboard/data/remote/dashboard_remote_ds.dart`

### Methods & Queries

```dart
class DashboardRemoteDs {
  final SupabaseService _supabase;

  // Returns {'pending': 2, 'in_progress': 1, 'completed': 4, ...}
  Future<Map<String, int>> fetchTaskStats(String serviceTypeId);

  // Returns {'available': 2, 'busy': 3, 'offline': 0}
  Future<Map<String, int>> fetchUnitStats(String serviceTypeId);

  // Returns count of open reports
  Future<int> fetchOpenReportCount(String serviceTypeId);

  // Returns pending service requests joined with flights
  Future<List<ServiceRequestModel>> fetchPendingServiceRequests(String serviceTypeId);

  // Returns top N units for dashboard preview
  Future<List<UnitModel>> fetchUnitsPreview(String serviceTypeId, {int limit = 3});
}
```

### Supabase Queries
```dart
// Task stats
supabase.client.from('tasks')
  .select('status')
  .eq('service_type_id', serviceTypeId);

// Unit stats
supabase.client.from('units')
  .select('status')
  .eq('service_type_id', serviceTypeId);

// Open report count (via tasks join)
supabase.client.from('reports')
  .select('id, tasks!inner(service_type_id)')
  .eq('tasks.service_type_id', serviceTypeId)
  .eq('status', 'open');

// Pending service requests
supabase.client.from('flight_service_requests')
  .select('*, flights(*)')
  .eq('service_type_id', serviceTypeId)
  .eq('status', 'pending')
  .order('created_at', ascending: true);

// Units preview
supabase.client.from('units')
  .select('*')
  .eq('service_type_id', serviceTypeId)
  .limit(limit);
```

### Error Handling
- Wrap all calls in `try/catch`
- Catch `PostgrestException` → `SupabaseErrorHandler`
- Re-throw as `AppError`

### Checklist
- [ ] All 5 methods implemented
- [ ] All queries scoped by `serviceTypeId`
- [ ] `PostgrestException` caught and converted to `AppError`
- [ ] Never access `supabase.client` directly — always through `SupabaseService`

---

## Feature 2.3 — Dashboard Repo

**Files:**
- `features/dashboard/data/repo/dashboard_repo.dart` (abstract)
- `features/dashboard/data/repo/dashboard_repo_impl.dart`

### Interface
```dart
abstract class DashboardRepo {
  Future<Map<String, int>> getTaskStats(String serviceTypeId);
  Future<Map<String, int>> getUnitStats(String serviceTypeId);
  Future<int> getOpenReportCount(String serviceTypeId);
  Future<List<ServiceRequestModel>> getPendingServiceRequests(String serviceTypeId);
  Future<List<UnitModel>> getUnitsPreview(String serviceTypeId);
}
```

### Checklist
- [ ] Abstract interface defined
- [ ] Impl delegates to `DashboardRemoteDs`
- [ ] No business logic in repo — pass-through only

---

## Feature 2.4 — Dashboard Cubit

**File:** `features/dashboard/logic/cubit/dashboard_cubit.dart`

### State
```dart
enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final int activeTaskCount;       // in_progress count
  final int pendingRequestCount;
  final int availableUnitCount;
  final int totalUnitCount;
  final int openReportCount;
  final List<ServiceRequestModel> pendingRequests;
  final List<UnitModel> unitsPreview;
  final AppError? error;
}
```

### Methods
```dart
class DashboardCubit extends Cubit<DashboardState> {
  // Fetches all data in parallel using Future.wait
  Future<void> loadDashboard(String serviceTypeId);
  Future<void> refresh(String serviceTypeId);
  // Called by AssignUnitBottomSheet after successful assignment
  void onRequestAssigned(String requestId);
}
```

### Parallel Loading
```dart
final results = await Future.wait([
  _repo.getTaskStats(serviceTypeId),
  _repo.getUnitStats(serviceTypeId),
  _repo.getOpenReportCount(serviceTypeId),
  _repo.getPendingServiceRequests(serviceTypeId),
  _repo.getUnitsPreview(serviceTypeId),
]);
```

### `onRequestAssigned`
Removes the request from `pendingRequests` list and decrements `pendingRequestCount` locally — no refetch needed.

### Checklist
- [ ] All fields in state with `copyWith`
- [ ] `loadDashboard` uses `Future.wait` for parallel fetch
- [ ] Error pattern: `on AppError catch (e)` + `catch (_) → AppError.unknown()`
- [ ] `onRequestAssigned` updates state without network call
- [ ] `serviceTypeId` read from `UserService` inside cubit — not passed from UI

---

## Feature 2.5 — Stats Row Widget

**File:** `features/dashboard/ui/widgets/stats_row.dart`

### Layout
```
GridView (2 columns, crossAxisSpacing rw(10), mainAxisSpacing rh(10), childAspectRatio 1.6)
  └── StatCard × 4
```

### `StatCard` spec
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(12)),
  decoration: BoxDecoration(
    color: cc.surface,
    borderRadius: BorderRadius.circular(rr(14)),
    border: Border.all(color: cc.border.withValues(alpha: 0.5)),
  ),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label.tr(), style: AppTextStyles.font12Light.copyWith(color: cc.textHint)),
    verticalSpacing(4),
    Text(value, style: AppTextStyles.font20ExtraBold.copyWith(color: valueColor)),
    verticalSpacing(2),
    Text(sub.tr(), style: AppTextStyles.font12Light.copyWith(color: cc.textHint)),
  ]),
)
```

### 4 Cards
| Label key | Value | Color |
|---|---|---|
| `active_tasks` | `activeTaskCount` | `AppColors.primary200` |
| `pending_requests` | `pendingRequestCount` | `AppColors.amber200` |
| `units_available` | `$availableUnitCount / $totalUnitCount` | `AppColors.green200` |
| `open_reports` | `openReportCount` | `AppColors.red200` |

### Checklist
- [ ] 2×2 grid with correct spacing
- [ ] All colors from `AppColors` — no hardcoded hex
- [ ] All strings use `.tr()`
- [ ] `rr(14)` border radius — no raw values

---

## Feature 2.6 — Supervisor Header Widget

**File:** `features/dashboard/ui/widgets/supervisor_header.dart`

### Layout
```
Container (gradient decoration)
  padding: rh(20) top, rw(16) horizontal, rh(28) bottom
  Row:
    ├── Column:
    │     ├── "Good morning," (font12Light, white@0.75)  ← use timeOfDayGreeting()
    │     ├── user.fullName (font20ExtraBold, white)
    │     └── service type tag (badge style, white@0.15 bg, white border@0.25)
    └── NotificationButton (placeholder — wired in Phase 8)
```

### Gradient
```dart
BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary200, AppColors.primary300, AppColors.primary400],
  ),
)
```

### Greeting helper
```dart
String timeOfDayGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'good_morning'.tr();
  if (hour < 17) return 'good_afternoon'.tr();
  return 'good_evening'.tr();
}
```

### Service type tag
```dart
Container(
  margin: EdgeInsets.only(top: rh(6)),
  padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(3)),
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(rr(20)),
    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
  ),
  child: Text(
    user.serviceTypeName ?? '',
    style: AppTextStyles.font12SemiBold.copyWith(color: Colors.white),
  ),
)
```

### Checklist
- [ ] Gradient uses `AppColors.primary200/300/400` only
- [ ] Greeting changes by time of day
- [ ] Service type name shown in tag
- [ ] `NotificationButton` widget placed (can show static unread dot for now)
- [ ] No hardcoded colors

---

## Feature 2.7 — Service Request Card

**File:** `features/dashboard/ui/widgets/service_request_card.dart`

### Layout
```
Container (surface, rr(16), border cc.border@0.6, shadow black@0.04)
  ├── left accent bar: rw(4) wide, full height
  │     color: primary200 (pending) | amber200 (if > 30min until arrival)
  └── body padding: all rw(14)
        ├── Row: flight number + stand (font15ExtraBold) · status Badge
        ├── Row: meta chips (arrival · aircraft · pax)
        └── action Row (border-top divider rh(10) margin):
              [outlined "Details" btn] [filled "Assign Unit" btn]
```

### Meta chips
Each chip: `Icon(size: rf(13)) + Text(font11Light, textHint)`, gap `rw(4)`, chips separated by `rw(12)`

Icons: `Icons.access_time_outlined` · `Icons.flight` · `Icons.person_outline`

### Buttons
```dart
// Details
CustomTextButton.outlined(
  label: 'details'.tr(),
  size: ButtonSize.small,
  onPressed: () { /* future: push to flight detail */ },
)

// Assign Unit
CustomTextButton.filled(
  label: 'assign_unit'.tr(),
  size: ButtonSize.small,
  onPressed: onAssignTap,  // opens bottom sheet
)
```

### Checklist
- [ ] Left accent bar `rw(4)` — not hardcoded `4`
- [ ] `rr(16)` border radius
- [ ] Both buttons use `CustomTextButton` — no raw `ElevatedButton`
- [ ] Flight number + stand on same line
- [ ] Meta chips with correct icons
- [ ] Card tap does nothing (buttons handle actions)

---

## Feature 2.8 — Unit Preview Mini Card

**File:** `features/dashboard/ui/widgets/unit_status_mini_card.dart`

### Layout
```
Container (surface, rr(14), border cc.border@0.6)
  padding: rw(14) h, rh(12) v
  Row:
    ├── icon container rw(42)×rw(42), rr(12), bg statusColor@0.1
    │     Icon(Icons.local_shipping_outlined, rf(20), color statusColor)
    ├── Column (flex 1):
    │     ├── unit name (font14ExtraBold, textPrimary)
    │     ├── current task or "No active task" (font12Light)
    └── status Badge (right)
```

### Status colors
| Status | Color |
|---|---|
| `available` | `AppColors.green200` |
| `busy` | `AppColors.primary200` |
| `offline` | `cc.textDisabled` |

### Checklist
- [ ] `rr(14)` on card, `rr(12)` on icon container
- [ ] Status color applied to icon + badge consistently
- [ ] "No active task" shown in `textHint` color
- [ ] Uses `AppColors.*` — no hardcoded colors

---

## Feature 2.9 — Dashboard Screen

**File:** `features/dashboard/ui/dashboard_screen.dart`

### Layout (top to bottom)
```
Scaffold (bg: cc.background)
  body: BlocBuilder<DashboardCubit, DashboardState>
    loading  → OverlayLoader
    failure  → ErrorScreen(onRetry: cubit.loadDashboard)
    loaded   →
      RefreshIndicator (color: primary200)
        CustomScrollView / SingleChildScrollView:
          ├── SupervisorHeader
          ├── StatsRow (padding rw(16) h, rh(16) top)
          ├── Section: "service_requests_section" + "view_all" → Tab 1
          │     └── ListView of ServiceRequestCard (max 5)
          └── Section: "live_unit_status_section" + "view_all" → Tab 2
                └── ListView of UnitStatusMiniCard (max 3)
```

### Section header widget (reuse across all tabs)
```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: rw(16)),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title.tr(), style: AppTextStyles.font14ExtraBold.copyWith(color: cc.textPrimary)),
      if (onViewAll != null)
        GestureDetector(
          onTap: onViewAll,
          child: Text('view_all'.tr(), style: AppTextStyles.font12SemiBold.copyWith(color: AppColors.primary200)),
        ),
    ],
  ),
)
```

### Init
```dart
@override
void initState() {
  super.initState();
  context.read<DashboardCubit>().loadDashboard(serviceTypeId);
}
```
Read `serviceTypeId` from `UserService` via `getIt<UserService>().currentUser?.serviceTypeId`.

### Checklist
- [ ] `initState` calls `loadDashboard`
- [ ] Pull-to-refresh calls `cubit.refresh`
- [ ] Loading state shows `OverlayLoader`
- [ ] Failure state shows `ErrorScreen` with retry
- [ ] Empty service requests shows `EmptyState` widget in that section
- [ ] "View all" for requests switches to Tab 1 via `SupervisorNavCubit`
- [ ] "View all" for units switches to Tab 2 via `SupervisorNavCubit`
- [ ] No hardcoded strings
- [ ] No raw pixel values

---

## Phase 2 — Done Criteria

- [ ] Dashboard loads real data from Supabase
- [ ] Stats row shows correct counts (active tasks / pending requests / available units / open reports)
- [ ] Pending service requests render with correct flight info
- [ ] Unit preview cards show correct statuses
- [ ] Pull-to-refresh works
- [ ] Error state renders with retry button
- [ ] "View all" links navigate to correct tabs
- [ ] All border radii use `rr()` — zero raw pixel values
- [ ] All strings use `.tr()`
