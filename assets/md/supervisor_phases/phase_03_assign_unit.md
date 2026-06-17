# Phase 3 — Assign Unit Bottom Sheet
> Supervisor Module Rebuild · GroundScope  
> Prerequisite: Phase 2 complete.  
> Reference: `supervisor_module_reference.md` §4.1 AssignUnitBottomSheet

---

## Feature 3.1 — Assign Unit Remote DS

**File:** `features/dashboard/data/remote/assign_unit_remote_ds.dart`

> Note: lives inside `dashboard/` since it's triggered from the dashboard.

### Methods
```dart
class AssignUnitRemoteDs {
  // Fetch only available units for this service type
  Future<List<UnitModel>> fetchAvailableUnits(String serviceTypeId);

  // Create task record
  Future<TaskModel> createTask({
    required String flightId,
    required String serviceTypeId,
    required String unitId,
    required String assignedBy,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? notes,
    String priority = 'medium',
  });

  // Update service request status to 'assigned'
  Future<void> markRequestAssigned(String requestId);
}
```

### Supabase Queries
```dart
// Available units
supabase.client.from('units')
  .select('*, unit_members(count)')
  .eq('service_type_id', serviceTypeId)
  .eq('status', 'available');

// Create task
supabase.client.from('tasks').insert({
  'flight_id': flightId,
  'service_type_id': serviceTypeId,
  'unit_id': unitId,
  'assigned_by': assignedBy,
  'created_by': assignedBy,
  'status': 'pending',
  'priority': priority,
  'scheduled_start': scheduledStart.toIso8601String(),
  'scheduled_end': scheduledEnd.toIso8601String(),
  'notes': notes,
}).select().single();

// Mark assigned
supabase.client.from('flight_service_requests')
  .update({'status': 'assigned'})
  .eq('id', requestId);
```

### Checklist
- [ ] `fetchAvailableUnits` filters `status = 'available'` AND `service_type_id`
- [ ] `createTask` inserts all required fields
- [ ] Both DB operations in `assignUnit` wrapped in sequence (task first, then update request)
- [ ] `PostgrestException` caught → `AppError` via `SupabaseErrorHandler`

---

## Feature 3.2 — Assign Unit Repo

**Files:**
- `features/dashboard/data/repo/assign_unit_repo.dart`
- `features/dashboard/data/repo/assign_unit_repo_impl.dart`

### Interface
```dart
abstract class AssignUnitRepo {
  Future<List<UnitModel>> getAvailableUnits(String serviceTypeId);
  Future<void> assignUnit({
    required String requestId,
    required String unitId,
    required String flightId,
    required String serviceTypeId,
    required String assignedBy,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? notes,
  });
}
```

### Impl — `assignUnit` sequence
```dart
// 1. Create the task
await _ds.createTask(...);
// 2. Mark request as assigned
await _ds.markRequestAssigned(requestId);
// If step 2 fails after step 1 — log error but don't throw (task already created)
```

### DI — add to `dependency_injection.dart`
```dart
getIt.registerLazySingleton<AssignUnitRemoteDs>(
  () => AssignUnitRemoteDs(getIt<SupabaseService>()));
getIt.registerLazySingleton<AssignUnitRepo>(
  () => AssignUnitRepoImpl(getIt<AssignUnitRemoteDs>()));
getIt.registerFactory<AssignUnitCubit>(
  () => AssignUnitCubit(getIt<AssignUnitRepo>()));
```

### Checklist
- [ ] Interface defined separately from impl
- [ ] Impl registered in DI
- [ ] Task creation happens before request status update
- [ ] Failure in status update does not block UI success flow

---

## Feature 3.3 — Assign Unit Cubit

**File:** `features/dashboard/logic/cubit/assign_unit_cubit.dart`

### State
```dart
enum AssignUnitStatus { initial, loading, loaded, assigning, success, failure }

class AssignUnitState extends Equatable {
  final AssignUnitStatus status;
  final List<UnitModel> allUnits;
  final List<UnitModel> filteredUnits;
  final String searchQuery;
  final AppError? error;

  int get resultCount => filteredUnits.length;
}
```

### Methods
```dart
class AssignUnitCubit extends Cubit<AssignUnitState> {
  Future<void> loadAvailableUnits(String serviceTypeId);
  void setSearch(String query);
  Future<void> assign({
    required String requestId,
    required UnitModel unit,
    required ServiceRequestModel request,
  });
}
```

### Filter logic (client-side)
```dart
List<UnitModel> _filter(List<UnitModel> all, String query) {
  if (query.isEmpty) return all;
  return all.where((u) =>
    u.name.toLowerCase().contains(query.toLowerCase())
  ).toList();
}
```

### Checklist
- [ ] `loadAvailableUnits` called on bottom sheet open
- [ ] `setSearch` applies filter and re-emits
- [ ] `assign` emits `assigning` status while in-flight
- [ ] On success: emits `success` status
- [ ] On failure: emits `failure` with `AppError`
- [ ] `resultCount` getter always reflects `filteredUnits.length`

---

## Feature 3.4 — Bottom Sheet UI

**File:** `features/dashboard/ui/widgets/assign_unit_bottom_sheet.dart`

### How to open
```dart
// From ServiceRequestCard "Assign Unit" button:
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => BlocProvider(
    create: (_) => getIt<AssignUnitCubit>()..loadAvailableUnits(serviceTypeId),
    child: AssignUnitBottomSheet(request: request),
  ),
);
```

### Layout
```
Container (surface, rr(16) top-left + top-right only, no bottom radius)
  ├── drag handle (centered, rw(40)×rh(4), grey200, rr(2))
  ├── header row: "assign_unit_title".tr() (font18ExtraBold) · X close button
  ├── flight info row: flight number + stand (font14Light, textSecondary)
  ├── ── Global Filter UI ──
  │     ├── Search field (CustomTextForm, "search_units".tr())
  │     └── counter: "X results".tr() (font12SemiBold, textSecondary)
  └── ListView of UnitPickerRow
        (if empty after search → EmptyState)
```

### `UnitPickerRow` spec
```
Row (padding rw(14) h, rh(12) v, border-bottom divider):
  ├── icon container rw(42)×rw(42), rr(12), green200@0.1
  │     Icon(Icons.local_shipping_outlined, rf(20), green200)
  ├── Column:
  │     ├── unit name (font14ExtraBold, textPrimary)
  │     ├── shift time (font12Light, textHint)
  │     └── member count (font12Light, textHint)
  └── CustomTextButton.filled(label: 'assign'.tr(), size: small)
```

### Max height
```dart
constraints: BoxConstraints(
  maxHeight: MediaQuery.of(context).size.height * 0.75,
),
```

### Checklist
- [ ] Bottom sheet max height 75% of screen
- [ ] Drag handle rendered
- [ ] Search field filters list live
- [ ] Counter shows `filteredUnits.length`
- [ ] Empty state shown when search yields 0 results
- [ ] `BlocProvider` wraps sheet with its own `AssignUnitCubit` instance
- [ ] `rr(16)` applied only to top corners — `borderRadius: BorderRadius.vertical(top: Radius.circular(rr(16)))`

---

## Feature 3.5 — Success / Failure Feedback

### On success (inside `AssignUnitBottomSheet` via `BlocListener`)
```dart
BlocListener<AssignUnitCubit, AssignUnitState>(
  listener: (context, state) {
    if (state.status == AssignUnitStatus.success) {
      Navigator.of(context).pop(); // close sheet
      context.showSuccessSnackBar('task_assigned'.tr());
      // Notify dashboard to remove this request from list
      context.read<DashboardCubit>().onRequestAssigned(widget.request.id);
    }
    if (state.status == AssignUnitStatus.failure) {
      context.showErrorSnackBar(state.error!.messageKey.tr());
    }
  },
)
```

### Loading state inside sheet
- While `status == assigning`: show `OverlayLoader` over the sheet content
- Disable all "Assign" buttons during loading

### Checklist
- [ ] Sheet closes automatically on success
- [ ] Success snackbar shown after sheet closes
- [ ] Dashboard removes assigned request from list without refetch
- [ ] Error snackbar shown on failure without closing sheet
- [ ] All "Assign" buttons disabled while `assigning`

---

## Phase 3 — Done Criteria

- [ ] Tapping "Assign Unit" on a service request card opens the bottom sheet
- [ ] Bottom sheet shows only available units (status = available)
- [ ] Search field filters units by name live
- [ ] Counter reflects number of visible units
- [ ] Tapping "Assign" on a unit: creates task + marks request assigned
- [ ] Success closes sheet and shows snackbar
- [ ] Dashboard pending requests list updates immediately (request removed)
- [ ] Pending request count in stats row decrements by 1
- [ ] No hardcoded strings, no raw pixel values
- [ ] `rr(16)` on sheet corners (top only)
