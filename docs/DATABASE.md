# Database Schema Documentation

> **Project:** Airport Ground Services Management App  
> **Database:** PostgreSQL (via Supabase)  
> **Last Updated:** June 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Entity Relationship Summary](#entity-relationship-summary)
3. [Enums](#enums)
4. [Tables](#tables)
   - [service_types](#service_types)
   - [units](#units)
   - [unit_members](#unit_members)
   - [stands](#stands)
   - [cameras](#cameras)
   - [users](#users)
   - [flights](#flights)
   - [tasks](#tasks)
   - [task_checklists](#task_checklists)
   - [task_pauses](#task_pauses)
   - [stand_events](#stand_events)
   - [reports](#reports)
   - [notifications](#notifications)
   - [delay_analysis](#delay_analysis)
   - [flight_turnaround_summary](#flight_turnaround_summary)
5. [Relationships Map](#relationships-map)

---

## Overview

This database supports an airport ground services management platform. It handles:

- **Flight tracking** — ingested from external APIs, assigned to airport stands
- **Task management** — ground service tasks assigned to units per flight
- **Unit & staff management** — service units, their members, and schedules
- **Camera & stand monitoring** — real-time event detection via stand cameras
- **Reporting & analytics** — delays, incidents, and turnaround summaries
- **Notifications** — push notifications (via FCM) to users

---

## Entity Relationship Summary

```
service_types ──< units ──< unit_members
     │               │
     │               └──< users
     │
stands ──── cameras
  │
flights ──< tasks ──< task_checklists
  │           │ ──< task_pauses
  │           │
stand_events ─┘
  │
reports
delay_analysis
flight_turnaround_summary
notifications ──> users
```

---

## Enums

These are custom PostgreSQL enums (`USER-DEFINED` types) used across the schema:

| Enum | Values |
|------|--------|
| `unit_status` | `available`, `busy`, `offline` *(inferred)* |
| `flight_status` | `scheduled`, `arrived`, `departed`, `cancelled` *(inferred)* |
| `task_status` | `pending`, `in_progress`, `completed`, `cancelled` *(inferred)* |
| `task_priority` | `low`, `medium`, `high` *(inferred)* |
| `event_source` | `camera`, `manual` *(inferred)* |
| `report_status` | `open`, `acknowledged`, `resolved` *(inferred)* |

> ℹ️ Exact enum values should be verified against the Supabase enum definitions.

---

## Tables

---

### `service_types`

Defines the types of ground services offered (e.g., fueling, catering, cleaning).

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `name` | `text` | NO | — | Unique service name |
| `description` | `text` | YES | — | Optional description |
| `default_duration_minutes` | `integer` | NO | `30` | Default task duration |
| `icon` | `text` | YES | — | Icon identifier for UI |
| `is_active` | `boolean` | NO | `true` | Soft delete flag |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |

**Constraints:** `name` is `UNIQUE`.

---

### `units`

Operational units (teams/vehicles) that perform ground services.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `name` | `text` | NO | — | Unit name |
| `service_type_id` | `uuid` | NO | — | FK → `service_types.id` |
| `status` | `unit_status` | NO | `available` | Current availability status |
| `compatible_aircraft` | `text[]` | YES | — | List of aircraft types this unit handles |
| `shift_start_time` | `time` | YES | — | Start of unit's working shift |
| `shift_end_time` | `time` | YES | — | End of unit's working shift |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |

**Foreign Keys:** `service_type_id` → `service_types(id)`

---

### `unit_members`

Individual staff members belonging to a unit. Not linked to auth users.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `unit_id` | `uuid` | NO | — | FK → `units.id` |
| `full_name` | `text` | NO | — | Member's full name |
| `phone` | `text` | YES | — | Contact number |
| `national_id` | `text` | YES | — | National ID number |
| `position` | `text` | NO | — | Job title/position |
| `image_url` | `text` | YES | — | Profile image URL |
| `is_active` | `boolean` | NO | `true` | Soft delete flag |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |

**Foreign Keys:** `unit_id` → `units(id)`

---

### `stands`

Airport gate/parking stands where aircraft park.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `code` | `text` | NO | — | Unique stand code (e.g., `A12`) |
| `terminal` | `text` | NO | — | Terminal identifier |
| `compatible_aircraft` | `text[]` | YES | — | Aircraft types this stand supports |
| `has_camera` | `boolean` | NO | `false` | Whether a camera is installed |
| `is_active` | `boolean` | NO | `true` | Soft delete flag |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |

**Constraints:** `code` is `UNIQUE`.

---

### `cameras`

Camera devices installed at stands for real-time monitoring.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `stand_id` | `uuid` | NO | — | FK → `stands.id` (one camera per stand) |
| `identifier` | `text` | NO | — | Unique device identifier |
| `stream_url` | `text` | YES | — | Live stream URL |
| `is_active` | `boolean` | NO | `true` | Whether camera is active |
| `last_ping` | `timestamptz` | YES | — | Last heartbeat timestamp |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |

**Constraints:** `stand_id` and `identifier` are both `UNIQUE` (one camera per stand).  
**Foreign Keys:** `stand_id` → `stands(id)`

---

### `users`

App users with role-based access. Linked to Supabase Auth.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `auth_id` | `uuid` | YES | — | FK → `auth.users(id)` (Supabase Auth) |
| `full_name` | `text` | NO | — | Display name |
| `email` | `text` | NO | — | Unique email address |
| `phone` | `text` | YES | — | Contact phone |
| `role` | `user_role` | NO | — | App role (e.g., admin, supervisor, operator) |
| `service_type_id` | `uuid` | YES | — | FK → `service_types.id` |
| `unit_id` | `uuid` | YES | — | FK → `units.id` |
| `fcm_token` | `text` | YES | — | Firebase push notification token |
| `is_active` | `boolean` | NO | `true` | Soft delete flag |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |

**Constraints:** `email` is `UNIQUE`.  
**Foreign Keys:**
- `service_type_id` → `service_types(id)`
- `unit_id` → `units(id)`
- `auth_id` → `auth.users(id)`

---

### `flights`

Flight records ingested from external APIs.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `flight_number` | `text` | NO | — | e.g., `EK202` |
| `airline` | `text` | NO | — | Airline name or IATA code |
| `origin` | `text` | NO | — | Origin airport (IATA) |
| `destination` | `text` | NO | — | Destination airport (IATA) |
| `aircraft_type` | `text` | YES | — | Aircraft model (e.g., `B737`) |
| `aircraft_registration` | `text` | YES | — | Tail number |
| `scheduled_arrival` | `timestamptz` | NO | — | Scheduled arrival time |
| `estimated_arrival` | `timestamptz` | YES | — | Updated estimate |
| `actual_arrival` | `timestamptz` | YES | — | Actual arrival time |
| `scheduled_departure` | `timestamptz` | YES | — | Scheduled departure |
| `actual_departure` | `timestamptz` | YES | — | Actual departure time |
| `stand_id` | `uuid` | YES | — | FK → `stands.id` |
| `status` | `flight_status` | NO | `scheduled` | Current flight status |
| `pax_count` | `integer` | YES | — | Passenger count |
| `api_source` | `text` | NO | — | Source system name |
| `external_id` | `text` | YES | — | ID from external API |
| `raw_data` | `jsonb` | YES | — | Full raw API payload |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |
| `updated_at` | `timestamptz` | NO | `now()` | Last update time |

**Foreign Keys:** `stand_id` → `stands(id)`

---

### `tasks`

Ground service tasks assigned to units for a specific flight.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `flight_id` | `uuid` | NO | — | FK → `flights.id` |
| `service_type_id` | `uuid` | NO | — | FK → `service_types.id` |
| `unit_id` | `uuid` | YES | — | FK → `units.id` (assigned unit) |
| `assigned_by` | `uuid` | YES | — | FK → `users.id` |
| `created_by` | `uuid` | YES | — | FK → `users.id` |
| `status` | `task_status` | NO | `pending` | Current task status |
| `priority` | `task_priority` | NO | `medium` | Task priority level |
| `scheduled_start` | `timestamptz` | NO | — | Planned start time |
| `scheduled_end` | `timestamptz` | NO | — | Planned end time |
| `actual_start` | `timestamptz` | YES | — | Actual start time |
| `actual_end` | `timestamptz` | YES | — | Actual completion time |
| `notes` | `text` | YES | — | Free-text notes |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |
| `updated_at` | `timestamptz` | NO | `now()` | Last update time |

**Foreign Keys:**
- `flight_id` → `flights(id)`
- `service_type_id` → `service_types(id)`
- `unit_id` → `units(id)`
- `assigned_by` → `users(id)`
- `created_by` → `users(id)`

---

### `task_checklists`

Ordered checklist items for a task, with completion tracking.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `task_id` | `uuid` | NO | — | FK → `tasks.id` |
| `item` | `text` | NO | — | Checklist item description |
| `is_checked` | `boolean` | NO | `false` | Completion flag |
| `checked_at` | `timestamptz` | YES | — | When item was checked |
| `checked_by` | `uuid` | YES | — | FK → `users.id` |
| `order_index` | `integer` | NO | — | Display order |

**Foreign Keys:**
- `task_id` → `tasks(id)`
- `checked_by` → `users(id)`

---

### `task_pauses`

Records whenever a task is paused and resumed, with reason tracking.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `task_id` | `uuid` | NO | — | FK → `tasks.id` |
| `paused_at` | `timestamptz` | NO | `now()` | When task was paused |
| `resumed_at` | `timestamptz` | YES | — | When task was resumed |
| `reason` | `text` | YES | — | Reason for pause |
| `paused_by` | `uuid` | YES | — | FK → `users.id` |

**Foreign Keys:**
- `task_id` → `tasks(id)`
- `paused_by` → `users(id)`

---

### `stand_events`

Events detected at a stand, from camera or manual input, optionally linked to tasks.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `stand_id` | `uuid` | NO | — | FK → `stands.id` |
| `flight_id` | `uuid` | NO | — | FK → `flights.id` |
| `camera_id` | `uuid` | YES | — | FK → `cameras.id` |
| `event_type` | `event_type` | NO | — | Type of event detected |
| `unit_id` | `uuid` | YES | — | FK → `units.id` (if unit-related) |
| `service_type_id` | `uuid` | YES | — | FK → `service_types.id` |
| `task_id` | `uuid` | YES | — | FK → `tasks.id` |
| `event_timestamp` | `timestamptz` | NO | — | When the event occurred |
| `source` | `event_source` | NO | `camera` | Detection source |
| `confidence_score` | `float8` | YES | — | AI/camera detection confidence (0–1) |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |

**Foreign Keys:**
- `stand_id` → `stands(id)`
- `flight_id` → `flights(id)`
- `camera_id` → `cameras(id)`
- `unit_id` → `units(id)`
- `service_type_id` → `service_types(id)`
- `task_id` → `tasks(id)`

---

### `reports`

Incident or issue reports filed during task execution.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `task_id` | `uuid` | NO | — | FK → `tasks.id` |
| `flight_id` | `uuid` | NO | — | FK → `flights.id` |
| `reported_by` | `uuid` | NO | — | FK → `users.id` |
| `type` | `report_type` | NO | — | Report category |
| `description` | `text` | NO | — | Detailed description |
| `severity` | `report_severity` | NO | — | Severity level |
| `status` | `report_status` | NO | `open` | Current status |
| `image_url` | `text` | YES | — | Attached photo URL |
| `acknowledged_by` | `uuid` | YES | — | FK → `users.id` |
| `acknowledged_at` | `timestamptz` | YES | — | When acknowledged |
| `resolved_by` | `uuid` | YES | — | FK → `users.id` |
| `resolved_at` | `timestamptz` | YES | — | When resolved |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |

**Foreign Keys:**
- `task_id` → `tasks(id)`
- `flight_id` → `flights(id)`
- `reported_by` / `acknowledged_by` / `resolved_by` → `users(id)`

---

### `notifications`

In-app and FCM push notifications sent to users.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `user_id` | `uuid` | NO | — | FK → `users.id` |
| `title` | `text` | NO | — | Notification title |
| `body` | `text` | NO | — | Notification body |
| `type` | `notification_type` | NO | — | Category of notification |
| `reference_id` | `uuid` | NO | — | ID of the referenced entity |
| `reference_type` | `text` | NO | — | Type name of the referenced entity |
| `is_read` | `boolean` | NO | `false` | Whether user has read it |
| `sent_via_fcm` | `boolean` | NO | `false` | Whether push was sent |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |

**Foreign Keys:** `user_id` → `users(id)`

> ℹ️ `reference_id` + `reference_type` form a polymorphic reference (e.g., to a task or report).

---

### `delay_analysis`

Computed delay metrics comparing scheduled vs. actual task times, with camera validation.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `flight_id` | `uuid` | NO | — | FK → `flights.id` |
| `task_id` | `uuid` | NO | — | FK → `tasks.id` |
| `service_type_id` | `uuid` | NO | — | FK → `service_types.id` |
| `unit_id` | `uuid` | YES | — | FK → `units.id` |
| `scheduled_start` | `timestamptz` | NO | — | Planned start |
| `actual_start` | `timestamptz` | YES | — | App-reported start |
| `scheduled_end` | `timestamptz` | NO | — | Planned end |
| `actual_end` | `timestamptz` | YES | — | App-reported end |
| `camera_unit_arrival` | `timestamptz` | YES | — | Camera-detected unit arrival |
| `camera_unit_departure` | `timestamptz` | YES | — | Camera-detected unit departure |
| `start_delay_minutes` | `integer` | YES | *computed* | `actual_start - scheduled_start` in minutes |
| `end_delay_minutes` | `integer` | YES | *computed* | `actual_end - scheduled_end` in minutes |
| `app_vs_camera_discrepancy` | `integer` | YES | — | Difference between app and camera times |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |

**Foreign Keys:**
- `flight_id` → `flights(id)`
- `task_id` → `tasks(id)`
- `service_type_id` → `service_types(id)`
- `unit_id` → `units(id)`

---

### `flight_turnaround_summary`

Aggregated summary of a flight's full ground turnaround. One record per flight.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | `uuid` | NO | `gen_random_uuid()` | Primary key |
| `flight_id` | `uuid` | NO | — | FK → `flights.id` (unique) |
| `stand_id` | `uuid` | YES | — | FK → `stands.id` |
| `flight_arrived_at` | `timestamptz` | YES | — | Actual arrival time |
| `flight_departed_at` | `timestamptz` | YES | — | Actual departure time |
| `total_turnaround_minutes` | `integer` | YES | *computed* | `departed - arrived` in minutes |
| `total_tasks` | `integer` | NO | `0` | Number of tasks created |
| `completed_tasks` | `integer` | NO | `0` | Number of completed tasks |
| `all_tasks_completed` | `boolean` | NO | `false` | Whether all tasks were completed |
| `had_delays` | `boolean` | NO | `false` | Whether any task had delays |
| `had_reports` | `boolean` | NO | `false` | Whether any incident was reported |
| `created_at` | `timestamptz` | NO | `now()` | Record creation time |
| `updated_at` | `timestamptz` | NO | `now()` | Last update time |

**Constraints:** `flight_id` is `UNIQUE` (one summary per flight).  
**Foreign Keys:**
- `flight_id` → `flights(id)`
- `stand_id` → `stands(id)`

---

## Relationships Map

```
auth.users
  └── users (auth_id)
        ├── tasks (assigned_by, created_by)
        ├── task_checklists (checked_by)
        ├── task_pauses (paused_by)
        ├── reports (reported_by, acknowledged_by, resolved_by)
        └── notifications (user_id)

service_types
  ├── units (service_type_id)
  ├── users (service_type_id)
  ├── tasks (service_type_id)
  ├── stand_events (service_type_id)
  └── delay_analysis (service_type_id)

units
  ├── unit_members (unit_id)
  ├── users (unit_id)
  ├── tasks (unit_id)
  ├── stand_events (unit_id)
  └── delay_analysis (unit_id)

stands
  ├── cameras (stand_id)
  ├── flights (stand_id)
  ├── stand_events (stand_id)
  └── flight_turnaround_summary (stand_id)

flights
  ├── tasks (flight_id)
  ├── stand_events (flight_id)
  ├── reports (flight_id)
  ├── delay_analysis (flight_id)
  └── flight_turnaround_summary (flight_id) [1:1]

tasks
  ├── task_checklists (task_id)
  ├── task_pauses (task_id)
  ├── stand_events (task_id)
  ├── reports (task_id)
  └── delay_analysis (task_id)
```
