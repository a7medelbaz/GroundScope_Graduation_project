# Data Model: Assign Task Full-Page Screen

**Feature**: `specs/003-add-task-screen`
**Date**: 2026-05-18

---

## Entities (all existing — no new models)

### TaskAssignmentInput
`lib/modules/supervisor/features/dashboard/data/models/task_assignment_input.dart`

| Field | Type | Required | Notes |
|---|---|---|---|
| `flightId` | `String` | Yes | UUID, from `FlightModel.id` |
| `serviceTypeId` | `String` | Yes | UUID, from `ServiceTypeModel.id` |
| `unitId` | `String` | Yes | UUID, from `UnitModel.id` |
| `priority` | `TaskPriority` | Yes | enum: low/medium/high/critical |
| `scheduledStart` | `DateTime` | Yes | today's date + picked time |
| `scheduledEnd` | `DateTime` | Yes | must be after scheduledStart |
| `notes` | `String?` | No | max 500 chars; null if empty |

### AssignTaskState
`lib/modules/supervisor/features/dashboard/logic/cubit/assign_task_state.dart`

| Field | Type | Initial | Notes |
|---|---|---|---|
| `status` | `AssignTaskStatus` | `initial` | enum: initial/loadingFormData/formReady/submitting/success/failure |
| `flights` | `List<FlightModel>` | `[]` | upcoming flights from Supabase |
| `allUnits` | `List<UnitModel>` | `[]` | all active units |
| `serviceTypes` | `List<ServiceTypeModel>` | `[]` | all active service types |
| `filteredUnits` | `List<UnitModel>` | `[]` | units filtered by selectedServiceType |
| `selectedFlight` | `FlightModel?` | null | |
| `selectedServiceType` | `ServiceTypeModel?` | null | |
| `selectedUnit` | `UnitModel?` | null | reset when serviceType changes |
| `priority` | `TaskPriority` | `medium` | |
| `scheduledStart` | `DateTime?` | null | |
| `scheduledEnd` | `DateTime?` | null | |
| `notes` | `String?` | null | |
| `error` | `AppError?` | null | |
| `isFormValid` | `bool` (computed) | false | all required fields set AND end > start |

### State Transitions

```
initial
  └─ loadFormData() ──────────────→ loadingFormData
                                          ├─ success ──→ formReady
                                          └─ failure ──→ failure (flights.isEmpty)

formReady
  ├─ selectFlight/ServiceType/Unit  → formReady (updated selection)
  ├─ setPriority/Start/End/Notes    → formReady (updated field)
  ├─ reset()                        → initial (then auto loadFormData → loadingFormData)
  └─ submit() [isFormValid=true]    → submitting
                                          ├─ success ──→ success  (→ UI pops)
                                          └─ failure ──→ failure (flights still populated)
```

---

## Shared Domain Models (read-only in this feature)

| Model | Source | Used for |
|---|---|---|
| `FlightModel` | `lib/core/shared/data/models/flight_model.dart` | Flight dropdown items |
| `ServiceTypeModel` | `lib/core/shared/data/models/service_type_model.dart` | Service type dropdown items |
| `UnitModel` | `lib/core/shared/data/models/unit_model.dart` | Unit dropdown items |
| `TaskPriority` (enum) | `lib/core/shared/data/models/task_model.dart` | Priority chip selection |
