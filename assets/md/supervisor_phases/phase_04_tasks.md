# Phase 4 — Tasks Tab
> Supervisor Module Rebuild · GroundScope  
> Prerequisite: Phase 1 complete. Phase 3 recommended (task creation flow).  
> Reference: `supervisor_module_reference.md` §4.2, `design_system.md` §6

---

## Feature 4.1 — Supervisor Task Remote DS

**File:** `features/tasks/data/remote/supervisor_task_remote_ds.dart`

### Methods
```dart
class SupervisorTaskRemoteDs {
  // Fetch all tasks for this supervisor's service type
  // Joined with flights, units, service_types
  Future<List<TaskModel>> fetchTasks(String serviceTypeId);
}
```

### Supabase Query
```dart
supabase.client.from('tasks')
  .select('*, flights(*), units(*), service_types(*)')
  .eq('service_type_id', serviceTypeId)
  .order('created_at', ascending: false);
```

### Checklist
- [ ] Query joined with `flights`, `units`, `service_types`
- [ ] Ordered by `created_at` descending (newest first)
- [ ] Result mapped to `List<TaskModel>` using `TaskModel.fromJson`
- [ ] `PostgrestException` → `AppError` via `SupabaseErrorHandler`

---

## Feature 4.2 — Supervisor Task Repo

**Files:**
- `features/tasks/data/repo/supervisor_task_repo.dart`
- `features/tasks/data/repo/supervisor_task_repo_impl.dart`

### Interface
```dart
abstract class SupervisorTaskRepo {
  Future<List<TaskModel>> getTasks(String serviceTypeId);
}
```

### Checklist
- [ ] Abstract interface + impl pattern
- [ ] Impl delegates to `SupervisorTaskRemoteDs`
- [ ] Already registered in DI from Phase 1

---

## Feature 4.3 — Supervisor Tasks Cubit

**File:** `features/tasks/logic/cubit/supervisor_tasks_cubit.dart`

### State
```dart
enum SupervisorTasksStatus { initial, loading, loaded, failure }

class SupervisorTasksState extends Equatable {
  final SupervisorTasksStatus status;
  final List<TaskModel> allTasks;
  final List<TaskModel> filteredTasks;
  final String activeFilter;   // 'all' | 'pending' | 'in_progress' | 'completed' | 'cancelled'
  final String searchQuery;
  final AppError? error;

  int get resultCount => filteredTasks.length;

  SupervisorTasksState copyWith({...});
}
```

### Methods
```dart
class SupervisorTasksCubit extends Cubit<SupervisorTasksState> {
  Future<void> loadTasks(String serviceTypeId);
  Future<void> refresh(String serviceTypeId);
  void setFilter(String filter);
  void setSearch(String query);
}
```

### Filter logic (client-side — applied after every `setFilter` or `setSearch`)
```dart
List<TaskModel> _applyFilters(
  List<TaskModel> all,
  String filter,
  String query,
) {
  return all.where((t) {
    final matchesFilter = filter == 'all' || t.status.name == filter;
    final q = query.toLowerCase();
    final matchesSearch = q.isEmpty ||
      (t.flight?.flightNumber.toLowerCase().contains(q) ?? false) ||
      (t.unit?.name.toLowerCase().contains(q) ?? false);
    return matchesFilter && matchesSearch;
  }).toList();
}
```

### Checklist
- [ ] `loadTasks` emits loading → loaded/failure
- [ ] `setFilter` re-applies filter without refetch
- [ ] `setSearch` re-applies search without refetch
- [ ] `resultCount` always equals `filteredTasks.length`
- [ ] Default filter is `'all'`
- [ ] Default search is `''`

---

## Feature 4.4 — Filter Pills Widget (Reusable)

**File:** `lib/core/widgets/filter_pills.dart`

> This is a **shared** widget — place in `lib/core/widgets/` so other tabs can reuse it.

### Signature
```dart
class FilterPills extends StatelessWidget {
  final List<String> filters;       // raw filter keys: ['all', 'pending', ...]
  final List<String> filterLabels;  // translated labels: ['All', 'Pending', ...]
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
}
```

### Layout
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(10)),
  child: Row(
    children: List.generate(filters.length, (i) =>
      Padding(
        padding: EdgeInsets.only(right: rw(8)),
        child: _FilterPill(
          label: filterLabels[i],
          isActive: activeFilter == filters[i],
          onTap: () => onFilterChanged(filters[i]),
        ),
      ),
    ),
  ),
)
```

### `_FilterPill` spec
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(6)),
  decoration: BoxDecoration(
    color: isActive ? AppColors.primary200 : cc.surfaceVariant,
    borderRadius: BorderRadius.circular(rr(20)),
    border: Border.all(
      color: isActive ? AppColors.primary200 : cc.border,
    ),
  ),
  child: Text(
    label,
    style: AppTextStyles.font12SemiBold.copyWith(
      color: isActive ? AppColors.white : cc.textSecondary,
    ),
  ),
)
```

### Checklist
- [ ] Placed in `lib/core/widgets/` — not inside any feature folder
- [ ] `AnimatedContainer` with 200ms transition
- [ ] Active pill: `primary200` bg + white text
- [ ] Inactive pill: `surfaceVariant` bg + `textSecondary` text + `cc.border` border
- [ ] `rr(20)` radius — pill shape
- [ ] Horizontal scroll — no wrapping

---

## Feature 4.5 — Search + Counter Widget (Reusable)

**File:** `lib/core/widgets/search_with_counter.dart`

> Also a **shared** widget — reused in Units, Reports, and AssignUnitBottomSheet.

### Signature
```dart
class SearchWithCounter extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final int resultCount;
  final String resultLabel; // defaults to 'results'.tr()
}
```

### Layout
```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(8)),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Search field
      CustomTextForm(
        hintText: hintText,
        prefixIcon: Icon(Icons.search_outlined, color: cc.iconSecondary, size: rf(20)),
        onChanged: onChanged,
      ),
      verticalSpacing(8),
      // Counter
      Text(
        '$resultCount ${resultLabel}',
        style: AppTextStyles.font12SemiBold.copyWith(color: cc.textSecondary),
      ),
    ],
  ),
)
```

### Checklist
- [ ] Placed in `lib/core/widgets/` — not inside any feature folder
- [ ] Counter updates whenever `resultCount` changes
- [ ] Uses `CustomTextForm` — not raw `TextField`
- [ ] Search icon uses `cc.iconSecondary` — no hardcoded color
- [ ] `resultLabel` defaults to `'results'.tr()`

---

## Feature 4.6 — Supervisor Task Card

**File:** `features/tasks/ui/widgets/supervisor_task_card.dart`

### Layout (from `design_system.md` §6 Card Spec)
```
Container(
  margin: EdgeInsets.only(bottom: rh(12)),
  decoration: BoxDecoration(
    color: cc.surface,
    borderRadius: BorderRadius.circular(rr(16)),
    border: Border.all(color: cc.border.withValues(alpha: 0.6)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0,2))],
  ),
)
Row:
  ├── left accent bar: rw(4) wide, full height
  │     color: TaskUiHelpers.statusColor(task.status, context)
  └── Padding(all: rw(14)):
        ├── Row: task title (font16SemiBold) · status Badge
        ├── verticalSpacing(4)
        ├── Text: "unit.name · stand · aircraft" (font14Light, textSecondary)
        ├── verticalSpacing(6)
        └── Row:
              ├── Icon(clock, rf(12)) + scheduled time range (font12Light, textHint)
              └── priority Badge (right)
```

### Status badge colors (`design_system.md` §5)
| Status | Color |
|---|---|
| `in_progress` | `primary200` |
| `completed` | `green200` |
| `pending` | `amber200` |
| `assigned` | `blue200` |
| `paused` | `secondary200` |
| `cancelled` | `textDisabled` |

### Priority badge colors
| Priority | Color |
|---|---|
| `critical` | `red200` |
| `high` | `secondary200` |
| `medium` | `amber200` |
| `low` | `green200` |

### Badge spec (from `design_system.md` §5)
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(rr(8)),
    border: Border.all(color: color.withValues(alpha: 0.3)),
  ),
  child: Text(label.tr(), style: AppTextStyles.font12SemiBold.copyWith(color: color)),
)
```

### Checklist
- [ ] `rr(16)` on card, `rr(8)` on badges
- [ ] Left accent bar uses `TaskUiHelpers.statusColor` — no hardcoded colors
- [ ] Priority badge uses correct color from table above
- [ ] Time range formatted using `task.scheduledStart.formattedTime` extension
- [ ] `rw(4)` accent bar — not hardcoded `4`
- [ ] Card tap → future navigation (leave as `() {}` for now)

---

## Feature 4.7 — Tasks Screen

**File:** `features/tasks/ui/supervisor_tasks_screen.dart`

### Layout
```
Scaffold (bg: cc.background)
  body: Column:
    ├── compact gradient header (rh(20) top, rw(16) h, rh(16) bottom)
    │     "supervisor_tasks_title".tr() (font18ExtraBold, white)
    │     service type name (font12Light, white@0.7)
    ├── SearchWithCounter(
    │     hintText: 'search_by_flight_or_unit'.tr(),
    │     onChanged: cubit.setSearch,
    │     resultCount: state.resultCount,
    │   )
    ├── FilterPills(
    │     filters: ['all','pending','in_progress','completed','cancelled'],
    │     filterLabels: [...translated...],
    │     activeFilter: state.activeFilter,
    │     onFilterChanged: cubit.setFilter,
    │   )
    └── BlocBuilder body:
          loading  → centered CircularProgressIndicator(color: primary200)
          failure  → ErrorScreen(onRetry: () => cubit.loadTasks(serviceTypeId))
          empty    → EmptyState
          loaded   → RefreshIndicator + ListView.builder of SupervisorTaskCard
```

### Init
```dart
@override
void initState() {
  super.initState();
  context.read<SupervisorTasksCubit>().loadTasks(serviceTypeId);
}
```

### Checklist
- [ ] `initState` loads tasks
- [ ] Search field wired to `cubit.setSearch`
- [ ] Filter pills wired to `cubit.setFilter`
- [ ] Counter shows `state.resultCount`
- [ ] Pull-to-refresh calls `cubit.refresh`
- [ ] Empty state renders when `filteredTasks` is empty
- [ ] All 3 reusable widgets used: `SearchWithCounter`, `FilterPills`, `SupervisorTaskCard`

---

## Phase 4 — Done Criteria

- [ ] Tasks tab loads real data scoped to supervisor's service type
- [ ] Search field filters by flight number or unit name live
- [ ] Filter pills switch between status filters
- [ ] Counter always shows visible task count
- [ ] Empty state shown when no tasks match filter/search
- [ ] Pull-to-refresh reloads from Supabase
- [ ] Each task card shows: unit name + flight + stand + status + priority + time range
- [ ] Status and priority badges use correct colors from design system
- [ ] No hardcoded strings, no raw pixel values
- [ ] `FilterPills` and `SearchWithCounter` are in `lib/core/widgets/` (reusable)
