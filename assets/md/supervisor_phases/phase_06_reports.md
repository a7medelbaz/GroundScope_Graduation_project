# Phase 6 — Reports Tab
> Supervisor Module Rebuild · GroundScope  
> Prerequisite: Phase 1 complete. Phase 4 recommended (reuses `FilterPills`, `SearchWithCounter`).  
> Reference: `supervisor_module_reference.md` §4.4, `design_system.md` §5 Report colors

---

## Feature 6.1 — Reports Remote DS (Supervisor)

**File:** `features/reports/data/remote/supervisor_reports_remote_ds.dart`

### Methods
```dart
class SupervisorReportsRemoteDs {
  // Fetch all reports from units under this service type
  Future<List<ReportModel>> fetchReports(String serviceTypeId);

  Future<void> acknowledgeReport({
    required String reportId,
    required String supervisorId,
  });

  Future<void> resolveReport({
    required String reportId,
    required String supervisorId,
  });
}
```

### Supabase Queries
```dart
// Fetch — join through tasks to filter by service_type
supabase.client.from('reports')
  .select('*, tasks!inner(service_type_id), flights(*), users!reported_by(*)')
  .eq('tasks.service_type_id', serviceTypeId)
  .order('created_at', ascending: false);

// Acknowledge
supabase.client.from('reports')
  .update({
    'status': 'acknowledged',
    'acknowledged_by': supervisorId,
    'acknowledged_at': DateTime.now().toUtc().toIso8601String(),
  })
  .eq('id', reportId);

// Resolve
supabase.client.from('reports')
  .update({
    'status': 'resolved',
    'resolved_by': supervisorId,
    'resolved_at': DateTime.now().toUtc().toIso8601String(),
  })
  .eq('id', reportId);
```

### Checklist
- [ ] Fetch uses `tasks!inner` join to scope by `service_type_id`
- [ ] `acknowledged_at` and `resolved_at` use UTC timestamps
- [ ] `PostgrestException` → `AppError`
- [ ] `ReportModel` reused from `lib/core/shared/data/models/report_model.dart`

---

## Feature 6.2 — Reports Repo

**Files:**
- `features/reports/data/repo/supervisor_reports_repo.dart`
- `features/reports/data/repo/supervisor_reports_repo_impl.dart`

### Interface
```dart
abstract class SupervisorReportsRepo {
  Future<List<ReportModel>> getReports(String serviceTypeId);
  Future<void> acknowledgeReport(String reportId, String supervisorId);
  Future<void> resolveReport(String reportId, String supervisorId);
}
```

### Checklist
- [ ] Interface + impl pattern
- [ ] Impl delegates to `SupervisorReportsRemoteDs`
- [ ] Already registered in DI from Phase 1

---

## Feature 6.3 — Reports Cubit

**File:** `features/reports/logic/cubit/supervisor_reports_cubit.dart`

### State
```dart
enum SupervisorReportsStatus { initial, loading, loaded, actionLoading, failure }

class SupervisorReportsState extends Equatable {
  final SupervisorReportsStatus status;
  final List<ReportModel> allReports;
  final List<ReportModel> filteredReports;
  final String activeFilter;    // 'all' | 'open' | 'acknowledged' | 'resolved'
  final String searchQuery;
  final String? actionReportId; // ID of report being acted on (for per-card loading)
  final AppError? error;

  int get resultCount => filteredReports.length;
}
```

### Methods
```dart
class SupervisorReportsCubit extends Cubit<SupervisorReportsState> {
  Future<void> loadReports(String serviceTypeId);
  Future<void> refresh(String serviceTypeId);
  void setFilter(String filter);
  void setSearch(String query);
  Future<void> acknowledgeReport(String reportId);
  Future<void> resolveReport(String reportId);
}
```

### Action flow (acknowledge / resolve)
```dart
Future<void> acknowledgeReport(String reportId) async {
  emit(state.copyWith(
    status: SupervisorReportsStatus.actionLoading,
    actionReportId: reportId,
  ));
  try {
    final supervisorId = getIt<UserService>().currentUser!.id;
    await _repo.acknowledgeReport(reportId, supervisorId);
    // Optimistic update — change status locally without refetch
    final updated = state.allReports.map((r) {
      if (r.id == reportId) return r.copyWith(status: ReportStatus.acknowledged);
      return r;
    }).toList();
    emit(state.copyWith(
      status: SupervisorReportsStatus.loaded,
      allReports: updated,
      filteredReports: _applyFilters(updated, state.activeFilter, state.searchQuery),
      actionReportId: null,
    ));
  } on AppError catch (e) {
    emit(state.copyWith(
      status: SupervisorReportsStatus.failure,
      error: e,
      actionReportId: null,
    ));
  } catch (_) {
    emit(state.copyWith(
      status: SupervisorReportsStatus.failure,
      error: AppError.unknown(),
      actionReportId: null,
    ));
  }
}
```

### Filter logic
```dart
List<ReportModel> _applyFilters(List<ReportModel> all, String filter, String query) {
  return all.where((r) {
    final matchesFilter = filter == 'all' || r.status.name == filter;
    final q = query.toLowerCase();
    final matchesSearch = q.isEmpty ||
      (r.flight?.flightNumber.toLowerCase().contains(q) ?? false) ||
      r.description.toLowerCase().contains(q);
    return matchesFilter && matchesSearch;
  }).toList();
}
```

### Checklist
- [ ] `actionReportId` tracks which card is loading
- [ ] Optimistic update: change status in local list without full refetch
- [ ] On failure: `actionReportId` cleared + error emitted
- [ ] `resolveReport` follows same pattern as `acknowledgeReport`
- [ ] Filter applies to both `allReports` and emits `filteredReports`

---

## Feature 6.4 — Supervisor Report Card

**File:** `features/reports/ui/widgets/supervisor_report_card.dart`

### Layout
```
Container (surface, rr(16), border cc.border@0.6, shadow black@0.04)
  ├── top accent bar: height rh(4), color = severityColor
  ├── header (padding rw(14) h, rh(12) v):
  │     Row:
  │       ├── Column:
  │       │     ├── report title / type (font14ExtraBold, textPrimary)
  │       │     └── "unitName · flightNumber · timeAgo" (font12Light, textHint)
  │       └── severity Badge (right)
  ├── body (padding rw(14) h, rh(0) top, rh(10) bottom):
  │     Text(description, font12Light, textSecondary, maxLines: 3)
  └── action row (border-top divider, padding rw(14) h, rh(10) v):
        status = 'open':         [outlined "details"] [filled "acknowledge"]
        status = 'acknowledged': [outlined "details"] [filled "resolve"]
        status = 'resolved':     [outlined "view"]
```

### Severity colors (`design_system.md` §5)
| Severity | Color |
|---|---|
| `low` | `AppColors.green200` |
| `medium` | `AppColors.amber200` |
| `high` | `AppColors.secondary200` |
| `critical` | `AppColors.red200` |

### Action button loading state
When `state.actionReportId == report.id`:
- Replace action buttons with `CircularProgressIndicator(color: primary200, strokeWidth: 2)`
- Size: `rw(22) × rw(22)`

### Timestamp
```dart
report.createdAt.timeAgo  // uses datetime_ext.dart
```

### Checklist
- [ ] `rh(4)` top accent bar — not hardcoded `4`
- [ ] `rr(16)` on card — not hardcoded `16`
- [ ] Severity badge uses correct color from table
- [ ] Action buttons change based on `report.status`
- [ ] Loading spinner shown when this card's report is being acted on
- [ ] `timeAgo` from `datetime_ext.dart`
- [ ] Description capped at 3 lines
- [ ] Both buttons use `CustomTextButton` — no raw buttons

---

## Feature 6.5 — Reports Screen

**File:** `features/reports/ui/supervisor_reports_screen.dart`

### Layout
```
Scaffold (bg: cc.background)
  body: Column:
    ├── compact gradient header
    │     "supervisor_reports_title".tr() (font18ExtraBold, white)
    │     "from_your_units".tr() (font12Light, white@0.7)
    ├── SearchWithCounter(
    │     hintText: 'search_by_flight_or_description'.tr(),
    │     onChanged: cubit.setSearch,
    │     resultCount: state.resultCount,
    │   )
    ├── FilterPills(
    │     filters: ['all', 'open', 'acknowledged', 'resolved'],
    │     filterLabels: [...translated...],
    │     activeFilter: state.activeFilter,
    │     onFilterChanged: cubit.setFilter,
    │   )
    └── BlocBuilder body:
          loading        → centered CircularProgressIndicator(color: primary200)
          failure        → ErrorScreen(onRetry: () => cubit.loadReports(serviceTypeId))
          empty          → EmptyState
          loaded         → RefreshIndicator + ListView.builder of SupervisorReportCard
```

### Acknowledge / Resolve flow in screen
```dart
// Wired to card button callbacks:
onAcknowledge: () async {
  final confirmed = await AppDialogs.showConfirm(
    context,
    message: 'acknowledge_confirm'.tr(),
    onConfirm: () => cubit.acknowledgeReport(report.id),
  );
},

onResolve: () async {
  final confirmed = await AppDialogs.showConfirm(
    context,
    message: 'resolve_confirm'.tr(),
    onConfirm: () => cubit.resolveReport(report.id),
  );
},
```

### BlocListener for feedback
```dart
BlocListener<SupervisorReportsCubit, SupervisorReportsState>(
  listener: (context, state) {
    if (state.status == SupervisorReportsStatus.failure && state.actionReportId == null) {
      context.showErrorSnackBar(state.error!.messageKey.tr());
    }
  },
)
```

### Init
```dart
@override
void initState() {
  super.initState();
  context.read<SupervisorReportsCubit>().loadReports(serviceTypeId);
}
```

### Checklist
- [ ] `initState` calls `loadReports`
- [ ] `AppDialogs.showConfirm` used before acknowledge/resolve — never raw dialog
- [ ] Success is reflected optimistically in the card (status badge changes)
- [ ] Error shown via snackbar — card stays open
- [ ] Pull-to-refresh calls `cubit.refresh`
- [ ] `SearchWithCounter` and `FilterPills` reused from `lib/core/widgets/`
- [ ] No hardcoded strings, no raw pixel values

---

## Phase 6 — Done Criteria

- [ ] Reports tab loads all reports scoped to supervisor's service type (via tasks join)
- [ ] Search filters by flight number or description live
- [ ] Filter pills switch between Open / Acknowledged / Resolved / All
- [ ] Counter shows visible report count
- [ ] Tapping "Acknowledge" shows confirm dialog → updates report status
- [ ] Tapping "Resolve" shows confirm dialog → updates report status
- [ ] Card action buttons change to match report status after update
- [ ] Loading spinner shown on the card being acted on
- [ ] Error snackbar shown on failure without crashing
- [ ] Pull-to-refresh reloads from Supabase
- [ ] No hardcoded strings, no raw pixel values
- [ ] Severity badge colors match design system exactly
