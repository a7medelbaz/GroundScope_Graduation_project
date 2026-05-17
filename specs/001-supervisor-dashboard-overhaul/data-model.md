# Data Model: Supervisor Dashboard Overhaul

## New Models

### DashboardStatsModel

Aggregated dashboard KPIs fetched on load / pull-to-refresh.

```dart
class DashboardStatsModel {
  final int activeUnits;          // units WHERE status = 'active'
  final int completedTasksToday;  // tasks WHERE status='completed' AND date=today
  final int delayedTasks;         // tasks WHERE scheduled_end < now() AND status NOT IN (completed, cancelled)
  final int reportsToday;         // reports WHERE created_at::date = today
}
```

**Validation rules**:
- All counts are non-negative integers (Supabase count() cannot return null).
- On fetch failure: `null` — UI renders `—` placeholder.

---

### TaskStatusSummaryModel

Derived breakdown for the Live Task Summary stacked progress bar.

```dart
class TaskStatusSummaryModel {
  final int total;       // total tasks scheduled today
  final int done;        // status = 'completed'
  final int inProgress;  // status IN ('in_progress', 'assigned', 'paused')
  final int delayed;     // scheduled_end < now() AND status NOT IN ('completed','cancelled')

  // Computed ratios (0.0–1.0, sum ≤ 1.0)
  double get donePct        => total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;
  double get inProgressPct  => total > 0 ? (inProgress / total).clamp(0.0, 1.0) : 0.0;
  double get delayedPct     => total > 0 ? (delayed / total).clamp(0.0, 1.0) : 0.0;

  bool get isEmpty => total == 0;
}
```

**Derivation**: Computed client-side from the same tasks list used for stats.
A task can appear in at most one bucket (delayed takes priority over in-progress
for tasks that are both past due AND actively in-progress).

---

### TaskAssignmentInput

Input DTO for the Assign Task bottom sheet submission.

```dart
class TaskAssignmentInput {
  final String flightId;
  final String serviceTypeId;
  final String unitId;
  final TaskPriority priority;     // reuses existing TaskPriority enum
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String? notes;
}
```

**Validation rules**:
- `flightId`, `serviceTypeId`, `unitId` MUST be non-empty UUIDs.
- `scheduledEnd` MUST be strictly after `scheduledStart`.
- `notes` is optional, max 500 characters.
- `priority` defaults to `TaskPriority.medium` if not selected.

---

## Existing Models (reused, no changes)

| Model | Source | Reused For |
|-------|--------|-----------|
| `TaskModel` | `lib/core/shared/data/models/task_model.dart` | Stats queries, task summary, assign task result |
| `TaskStatus` | same | Status grouping for summary bar |
| `TaskPriority` | same | Priority dropdown in assign task form |
| `ReportModel` | `lib/core/shared/data/models/report_model.dart` | Supervisor reports list + delete |
| `UnitModel` | `lib/core/shared/data/models/unit_model.dart` | Unit dropdown in assign task |
| `FlightModel` | `lib/core/shared/data/models/flight_model.dart` | Flight dropdown in assign task |
| `ServiceTypeModel` | `lib/core/shared/data/models/service_type_model.dart` | Service type dropdown in assign task |

---

## State Models

### SupervisorDashboardState

```dart
enum DashboardStatus { initial, loading, success, failure }

class SupervisorDashboardState {
  final DashboardStatus status;
  final DashboardStatsModel? stats;
  final TaskStatusSummaryModel? taskSummary;
  final AppError? error;

  bool get isLoading => status == DashboardStatus.loading;
  bool get hasData   => stats != null && taskSummary != null;
}
```

---

### AssignTaskState

```dart
enum AssignTaskStatus { initial, loadingFormData, formReady, submitting, success, failure }

class AssignTaskState {
  final AssignTaskStatus status;
  // Dropdown options (loaded on sheet open)
  final List<FlightModel> flights;
  final List<UnitModel> allUnits;
  final List<ServiceTypeModel> serviceTypes;
  // Current selections
  final FlightModel? selectedFlight;
  final ServiceTypeModel? selectedServiceType;
  final UnitModel? selectedUnit;
  final TaskPriority priority;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String? notes;
  // Derived
  final List<UnitModel> filteredUnits;  // units filtered by selectedServiceType
  final AppError? error;
  final String? validationError;

  bool get isFormValid =>
    selectedFlight != null &&
    selectedServiceType != null &&
    selectedUnit != null &&
    scheduledStart != null &&
    scheduledEnd != null &&
    scheduledEnd!.isAfter(scheduledStart!);
}
```

---

### SupervisorReportsState

```dart
enum SupervisorReportsStatus { initial, loading, success, failure, deleting }

class SupervisorReportsState {
  final SupervisorReportsStatus status;
  final List<ReportModel> reports;
  final AppError? error;
  final String? deletingReportId;  // id of report being deleted (for optimistic UI)
}
```

---

## Supabase Query Contracts

### Stats Queries (SupervisorDashboardRemoteDs)

```
GET /rest/v1/units?select=count&status=eq.active
→ [{"count": N}]

GET /rest/v1/tasks?select=count&status=eq.completed&scheduled_start=gte.{today}T00:00:00&scheduled_start=lt.{tomorrow}T00:00:00
→ [{"count": N}]

GET /rest/v1/tasks?select=count&scheduled_end=lt.{now}&status=not.in.(completed,cancelled)
→ [{"count": N}]

GET /rest/v1/reports?select=count&created_at=gte.{today}T00:00:00&created_at=lt.{tomorrow}T00:00:00
→ [{"count": N}]
```

### Task Summary Query

```
GET /rest/v1/tasks?select=status,scheduled_end
       &scheduled_start=gte.{today}T00:00:00
       &scheduled_start=lt.{tomorrow}T00:00:00
→ List of {status, scheduled_end} — grouped client-side
```

### Upcoming Flights Query

```
GET /rest/v1/flights?select=*,stands(*)
       &scheduled_arrival=gte.{now}
       &scheduled_arrival=lte.{now+24h}
       &status=not.in.(cancelled,departed)
       &order=scheduled_arrival.asc
→ List<FlightModel>
```

### Assign Task Mutation

```
POST /rest/v1/tasks
Body: {
  flight_id, service_type_id, unit_id,
  assigned_by, created_by,
  status: "assigned",
  priority, scheduled_start, scheduled_end, notes
}
→ TaskModel (single)
```

### Delete Report Mutation

```
DELETE /rest/v1/reports?id=eq.{reportId}
→ 204 No Content
```
