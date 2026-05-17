# Supabase API Contracts: Supervisor Dashboard

All queries go through `SupabaseService` via Remote Data Sources.
All error responses are caught and converted to `AppError` by `ErrorHandler`.

---

## SupervisorDashboardRemoteDs

### fetchActiveUnitsCount() → int

```
client.from('units').count().eq('status', 'active')
```

### fetchCompletedTasksTodayCount() → int

```
client.from('tasks').count()
  .eq('status', 'completed')
  .gte('scheduled_start', todayStart.toIso8601String())
  .lt('scheduled_start', tomorrowStart.toIso8601String())
```

### fetchDelayedTasksCount() → int

```
client.from('tasks').count()
  .lt('scheduled_end', DateTime.now().toIso8601String())
  .not('status', 'in', '(completed,cancelled)')
```

### fetchReportsTodayCount() → int

```
client.from('reports').count()
  .gte('created_at', todayStart.toIso8601String())
  .lt('created_at', tomorrowStart.toIso8601String())
```

### fetchTodaysTasksForSummary() → List\<Map\>

Returns minimal task data needed for the status summary bar.

```
client.from('tasks')
  .select('status, scheduled_end')
  .gte('scheduled_start', todayStart.toIso8601String())
  .lt('scheduled_start', tomorrowStart.toIso8601String())
```

### fetchUpcomingFlights() → List\<FlightModel\>

```
client.from('flights')
  .select('*, stands(*)')
  .gte('scheduled_arrival', DateTime.now().toIso8601String())
  .lte('scheduled_arrival', DateTime.now().add(Duration(hours: 24)).toIso8601String())
  .not('status', 'in', '(cancelled,departed)')
  .order('scheduled_arrival', ascending: true)
```

### fetchAllActiveUnits() → List\<UnitModel\>

```
client.from('units')
  .select()
  .eq('status', 'active')
  .order('name', ascending: true)
```

### fetchAllServiceTypes() → List\<ServiceTypeModel\>

```
client.from('service_types')
  .select()
  .eq('is_active', true)
  .order('name', ascending: true)
```

### assignTask(TaskAssignmentInput input, String assignedBy) → TaskModel

```
client.from('tasks').insert({
  'flight_id': input.flightId,
  'service_type_id': input.serviceTypeId,
  'unit_id': input.unitId,
  'assigned_by': assignedBy,
  'created_by': assignedBy,
  'status': 'assigned',
  'priority': input.priority.value,
  'scheduled_start': input.scheduledStart.toIso8601String(),
  'scheduled_end': input.scheduledEnd.toIso8601String(),
  'notes': input.notes,
}).select('''
  *,
  service_types (*),
  flights (*, stands (*))
''').single()
```

---

## ReportRemoteDs (additions)

### fetchAllReports() → List\<ReportModel\>

```
client.from('reports')
  .select()
  .order('created_at', ascending: false)
```

### deleteReport(String id) → void

```
client.from('reports').delete().eq('id', id)
```

---

## Error Handling

All methods wrap the Supabase call in `try/catch`:

```dart
try {
  // Supabase call
} catch (e) {
  throw ErrorHandler.handle(e);  // converts to AppError
}
```

Callers (Repository impls) propagate `AppError`; Cubits catch `AppError` first, then
fall back to `AppError.unknown()`.
