# Phase 5 — Units Tab
> Supervisor Module Rebuild · GroundScope  
> Prerequisite: Phase 1 complete. Phase 4 recommended (reuses `FilterPills`, `SearchWithCounter`).  
> Reference: `supervisor_module_reference.md` §4.3

---

## Feature 5.1 — Units Remote DS

**File:** `features/units/data/remote/supervisor_units_remote_ds.dart`

### Methods
```dart
class SupervisorUnitsRemoteDs {
  // One-time fetch — joined with unit_members
  Future<List<UnitModel>> fetchUnits(String serviceTypeId);

  // Realtime stream — emits new list on any change to units table
  Stream<List<Map<String, dynamic>>> watchUnits(String serviceTypeId);
}
```

### Supabase Queries
```dart
// One-time fetch
supabase.client.from('units')
  .select('*, unit_members(*)')
  .eq('service_type_id', serviceTypeId)
  .order('name', ascending: true);

// Realtime stream
supabase.client
  .from('units')
  .stream(primaryKey: ['id'])
  .eq('service_type_id', serviceTypeId);
// Note: .stream() does not support joins — fetch members separately on update
```

### Checklist
- [ ] One-time fetch joins `unit_members`
- [ ] Realtime stream uses `.stream(primaryKey: ['id'])`
- [ ] Stream filtered by `service_type_id`
- [ ] `PostgrestException` → `AppError`

---

## Feature 5.2 — Units Repo

**Files:**
- `features/units/data/repo/supervisor_units_repo.dart`
- `features/units/data/repo/supervisor_units_repo_impl.dart`

### Interface
```dart
abstract class SupervisorUnitsRepo {
  Future<List<UnitModel>> getUnits(String serviceTypeId);
  Stream<List<UnitModel>> watchUnits(String serviceTypeId);
}
```

### Impl note
`watchUnits` maps the raw stream from DS into `List<UnitModel>` using `UnitModel.fromJson`.

### Checklist
- [ ] Interface + impl pattern
- [ ] `watchUnits` maps raw stream to typed stream
- [ ] Already registered in DI from Phase 1

---

## Feature 5.3 — Units Cubit

**File:** `features/units/logic/cubit/supervisor_units_cubit.dart`

### State
```dart
enum SupervisorUnitsStatus { initial, loading, loaded, failure }

class SupervisorUnitsState extends Equatable {
  final SupervisorUnitsStatus status;
  final List<UnitModel> allUnits;
  final List<UnitModel> filteredUnits;
  final String activeFilter;   // 'all' | 'available' | 'busy' | 'offline'
  final String searchQuery;
  final AppError? error;

  int get resultCount => filteredUnits.length;
}
```

### Methods
```dart
class SupervisorUnitsCubit extends Cubit<SupervisorUnitsState> {
  StreamSubscription? _subscription;

  Future<void> loadUnits(String serviceTypeId);
  void setFilter(String filter);
  void setSearch(String query);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

### `loadUnits` implementation
```dart
Future<void> loadUnits(String serviceTypeId) async {
  emit(state.copyWith(status: SupervisorUnitsStatus.loading));
  try {
    // 1. Initial fetch
    final units = await _repo.getUnits(serviceTypeId);
    emit(state.copyWith(
      status: SupervisorUnitsStatus.loaded,
      allUnits: units,
      filteredUnits: _applyFilters(units, state.activeFilter, state.searchQuery),
    ));
    // 2. Subscribe to realtime updates
    _subscription = _repo.watchUnits(serviceTypeId).listen(
      (updated) {
        emit(state.copyWith(
          allUnits: updated,
          filteredUnits: _applyFilters(updated, state.activeFilter, state.searchQuery),
        ));
      },
      onError: (_) { /* silent — don't override loaded state on stream error */ },
    );
  } on AppError catch (e) {
    emit(state.copyWith(status: SupervisorUnitsStatus.failure, error: e));
  } catch (_) {
    emit(state.copyWith(status: SupervisorUnitsStatus.failure, error: AppError.unknown()));
  }
}
```

### Filter logic
```dart
List<UnitModel> _applyFilters(List<UnitModel> all, String filter, String query) {
  return all.where((u) {
    final matchesFilter = filter == 'all' || u.status.name == filter;
    final matchesSearch = query.isEmpty ||
      u.name.toLowerCase().contains(query.toLowerCase());
    return matchesFilter && matchesSearch;
  }).toList();
}
```

### Checklist
- [ ] Initial fetch + realtime subscription in `loadUnits`
- [ ] `_subscription` cancelled in `close()`
- [ ] Stream errors are silent (don't override loaded state)
- [ ] Filter and search re-apply on every `setFilter`/`setSearch`
- [ ] `resultCount` always equals `filteredUnits.length`

---

## Feature 5.4 — Unit Status Card

**File:** `features/units/ui/widgets/unit_status_card.dart`

### Layout
```
GestureDetector(onTap: () => _openDetailSheet(context, unit))
  Container (surface, rr(14), border cc.border@0.6)
    padding: rw(14) h, rh(12) v
    Row:
      ├── icon container rw(42)×rw(42), rr(12), statusColor@0.1
      │     Icon(Icons.local_shipping_outlined, rf(20), color: statusColor)
      ├── Column (flex 1):
      │     ├── unit name (font14ExtraBold, textPrimary)
      │     ├── shift: "shift_start – shift_end" (font12Light, textHint)
      │     └── task status line (font12Light):
      │           if busy: current task description (primary200 color)
      │           if available: "no_active_task".tr() (textHint)
      │           if offline: "off_shift".tr() (textDisabled)
      └── status Badge (right-aligned)
```

### Status colors
| Status | Color |
|---|---|
| `available` | `AppColors.green200` |
| `busy` | `AppColors.primary200` |
| `offline` | `cc.textDisabled` |

### Shift time format
Use `unit.shiftStartTime` and `unit.shiftEndTime` (time strings from DB).
Display as: `"06:00 – 14:00"` — no date.

### Checklist
- [ ] Card tap opens `UnitDetailBottomSheet`
- [ ] `rr(14)` on card, `rr(12)` on icon container — no raw values
- [ ] Status color applied to icon AND badge
- [ ] Shift time displayed when available
- [ ] Member count visible in bottom sheet (not card)

---

## Feature 5.5 — Unit Detail Bottom Sheet

**File:** `features/units/ui/widgets/unit_detail_bottom_sheet.dart`

### How to open
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => UnitDetailBottomSheet(unit: unit),
);
```

### Layout
```
Container (surface, rr(16) top corners only)
  ├── drag handle
  ├── header row: unit name (font18ExtraBold) · status Badge
  ├── divider
  ├── InfoCard rows:
  │     ├── Shift: "shift_label".tr() · "06:00 – 14:00"
  │     ├── Service Type: icon · service type name
  │     └── Compatible Aircraft: icon · comma-joined list or "—"
  ├── section: "crew_members".tr() (font14ExtraBold)
  └── ListView of MemberRow (non-scrollable inside sheet — use shrinkWrap)
```

### `MemberRow` spec
```
Row (padding rw(14) h, rh(10) v, border-bottom divider):
  ├── avatar circle rw(36)×rw(36), rr(18), primary200@0.1
  │     initials (font12SemiBold, primary200)
  ├── Column:
  │     ├── full_name (font14SemiBold, textPrimary)
  │     └── position (font12Light, textHint)  ← use .tr() on position key
  └── (no action — display only)
```

### InfoCard rows spec (`design_system.md` §4 InfoCard)
```dart
InfoCard(rows: [
  InfoRowData(icon: Icons.access_time_outlined, label: 'shift'.tr(), value: '06:00 – 14:00'),
  InfoRowData(icon: Icons.bolt_outlined, label: 'service_type'.tr(), value: unit.serviceTypeName ?? '—'),
  InfoRowData(icon: Icons.airplanemode_active_outlined, label: 'compatible_aircraft'.tr(),
    value: unit.compatibleAircraft?.join(', ') ?? '—'),
])
```

### Checklist
- [ ] Uses existing `InfoCard` + `InfoRowData` from `lib/core/widgets/`
- [ ] `borderRadius: BorderRadius.vertical(top: Radius.circular(rr(16)))` — top only
- [ ] Avatar shows initials (first letter of each word in full_name)
- [ ] `shrinkWrap: true` on member list inside sheet
- [ ] Sheet is scrollable if crew list is long (`isScrollControlled: true`)
- [ ] No auth-user data shown — unit_members are display-only

---

## Feature 5.6 — Units Screen

**File:** `features/units/ui/supervisor_units_screen.dart`

### Layout
```
Scaffold (bg: cc.background)
  body: Column:
    ├── compact gradient header
    │     "supervisor_units_title".tr() (font18ExtraBold, white)
    │     "$totalUnits units · serviceTypeName" (font12Light, white@0.7)
    ├── SearchWithCounter(
    │     hintText: 'search_by_unit_name'.tr(),
    │     onChanged: cubit.setSearch,
    │     resultCount: state.resultCount,
    │   )
    ├── FilterPills(
    │     filters: ['all', 'available', 'busy', 'offline'],
    │     filterLabels: [...translated...],
    │     activeFilter: state.activeFilter,
    │     onFilterChanged: cubit.setFilter,
    │   )
    └── BlocBuilder body:
          loading  → centered CircularProgressIndicator(color: primary200)
          failure  → ErrorScreen(onRetry: () => cubit.loadUnits(serviceTypeId))
          empty    → EmptyState
          loaded   → ListView.builder of UnitStatusCard
                     (no RefreshIndicator — realtime handles updates)
```

### Init
```dart
@override
void initState() {
  super.initState();
  context.read<SupervisorUnitsCubit>().loadUnits(serviceTypeId);
}
```

### Checklist
- [ ] `initState` calls `loadUnits`
- [ ] Realtime updates reflect in list without manual pull-to-refresh
- [ ] Search + counter wired correctly
- [ ] Filter pills work independently of search
- [ ] No `RefreshIndicator` — realtime is the update mechanism
- [ ] Empty state shown when no units match filter

---

## Phase 5 — Done Criteria

- [ ] Units tab loads all units for supervisor's service type
- [ ] Unit statuses update in real time (change status in Supabase → card updates)
- [ ] Search filters by unit name live
- [ ] Filter pills filter by status
- [ ] Counter shows visible unit count
- [ ] Tapping a unit card opens `UnitDetailBottomSheet`
- [ ] Bottom sheet shows shift times, service type, compatible aircraft, and crew list
- [ ] Stream subscription cancelled when cubit is closed (no memory leaks)
- [ ] No hardcoded strings, no raw pixel values
- [ ] `rr(14)` cards, `rr(12)` icon containers, `rr(16)` bottom sheet (top only)
