# GROUNDSCOPE

Airport Ground Services Coordination System

*System Design **&** Architecture Reference Document*

Version 1.0 · Graduation Project

---

# 1. Project Overview

GroundScope is a real-time airport ground services coordination application. It digitizes and streamlines the entire turnaround process — from the moment a flight is scheduled to the moment it departs — by connecting three key roles: Admin, Supervisor, and Unit Manager (Worker).

> **Core Problem** Airport ground operations are complex and time-critical. Without a coordination system, tasks are assigned by phone or paper, delays are hard to track, and incidents are reported manually. GroundScope replaces this with a real-time digital workflow.

## 1.1 Technology Stack

| **Layer** | **Technology** |
|---|---|
| **Mobile App** | Flutter (Dart) — iOS & Android |
| **State Management** | Cubit / BLoC pattern |
| **Dependency Injection** | GetIt service locator |
| **Backend** | Supabase (PostgreSQL + Auth + Storage + RLS) |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **Flight Data** | AviationStack API |
| **Design Canvas** | 390 × 844 px (flutter_screenutil) |
| **Localization** | English + Arabic (easy_localization) |
| **Fonts** | Manrope (EN) · Tajawal (AR) |

---

# 2. User Roles

GroundScope has three user roles. Each role has a dedicated module in the Flutter app with its own navigation, screens, and data access controlled by Supabase Row Level Security (RLS).

---

> **Admin** Full system owner. Manages all data and monitors everything.

| **Sees** | **Can do** |
|---|---|
| • All flights (from API + manual) • All tasks across all service types • All units and their statuses • All reports across all units • Delay analytics and turnaround summaries • All users (supervisors + unit managers) | • Create / edit service types • Create / edit stands • Create / edit units and unit members • Create supervisor and unit manager accounts • Import flights from AviationStack API • Send service requests to supervisors per flight • View analytics and delay data |

---

> **Supervisor** Manages operations for ONE specific service type (e.g. Fueling).

| **Sees** | **Can do** |
|---|---|
| • Only flights that have a service request for their service type • Only units belonging to their service type • Only tasks assigned to their units • Reports submitted by their units | • View incoming service requests from admin • Pick an available unit and assign it to a task • Monitor live task status across their units • Acknowledge and resolve incident reports • View performance of their units |

---

> **Unit Manager (Worker)** Executes ground service tasks on behalf of their unit.

| **Sees** | **Can do** |
|---|---|
| • Only tasks assigned to their specific unit • Their own unit info and crew members • Reports they have submitted • Notifications from their supervisor | • View task details (flight, stand, checklist, timing) • Start, pause, and complete tasks • Work through task checklist items • Submit incident reports with photo and severity • View task timeline and history |

---

> **How Supervisor is Differentiated** Each supervisor is linked to ONE service type via the `service_type_id` column on the users table. A fueling supervisor only sees fueling requests, units, and tasks. A catering supervisor only sees catering data. This is enforced at the database level via RLS policies.

---

# 3. Full System Flow

The following steps describe the complete lifecycle of a single flight turnaround — from initial setup by the admin to task completion by a unit manager.

## Phase 1 — Admin Sets Up the System (One-Time)

| **1** | **Admin** | Creates a Service Type (e.g. Fueling, Catering, Cleaning) | Service type appears in the system — units and tasks can now reference it |
|---|---|---|---|

| **2** | **Admin** | Creates a Supervisor account and links it to the service type | Supervisor can log in and sees only data for their service type |
|---|---|---|---|

| **3** | **Admin** | Creates a Unit (e.g. Fuel Truck 01) and links it to the service type | Unit is available for task assignment |
|---|---|---|---|

| **4** | **Admin** | Creates a Unit Manager account and links it to the unit | Unit Manager can log in and sees only tasks for their unit |
|---|---|---|---|

| **5** | **Admin** | Creates Stands (airport parking positions) and links them to terminals | Flights can now be assigned to a stand |
|---|---|---|---|

## Phase 2 — Flight Arrives

| **6** | **API** | AviationStack API sends scheduled flight data (or admin enters manually) | Flight is stored in the flights table with all details |
|---|---|---|---|

| **7** | **Admin** | Reviews the flight in the dashboard and identifies required services | Admin knows which service types this flight needs |
|---|---|---|---|

## Phase 3 — Admin Sends Service Requests

| **8** | **Admin** | Creates a `flight_service_request` for each service needed | One request per service type per flight — supervisor is notified |
|---|---|---|---|

| **9** | **System** | Each request is automatically visible to the matching supervisor | Fueling request → fueling supervisor. Catering request → catering supervisor |
|---|---|---|---|

## Phase 4 — Supervisor Assigns a Unit

| **10** | **Supervisor** | Opens the service request and sees all available units for their service type | Supervisor views unit availability in real time |
|---|---|---|---|

| **11** | **Supervisor** | Picks the best available unit and creates a Task assigned to that unit | Task appears in the unit manager's home screen immediately |
|---|---|---|---|

## Phase 5 — Unit Manager Executes

| **12** | **Unit Manager** | Opens the task, reviews flight info, stand, checklist, and timing | Task details screen shows everything needed |
|---|---|---|---|

| **13** | **Unit Manager** | Taps Start — task status changes to `in_progress` | Supervisor and admin can see the task is active |
|---|---|---|---|

| **14** | **Unit Manager** | Works through checklist items one by one | Each item is checked off with a timestamp |
|---|---|---|---|

| **15** | **Unit Manager** | Taps Complete — task status changes to `completed` | `actual_end` timestamp is recorded. Delay is calculated. |
|---|---|---|---|

| **16** | **Unit Manager** | If issue found — submits a Report with description, severity, and optional photo | Report appears in supervisor dashboard immediately |
|---|---|---|---|

## Phase 6 — Supervisor Monitors and Closes

| **17** | **Supervisor** | Monitors live task status across all their units in the dashboard | Can see which units are busy, available, or delayed |
|---|---|---|---|

| **18** | **Supervisor** | Reviews any submitted reports and acknowledges or resolves them | Report status updates to `acknowledged` or `resolved` |
|---|---|---|---|

## Phase 7 — Admin Reviews Analytics

| **19** | **Admin** | Views flight turnaround summary — all tasks, delays, reports per flight | Full turnaround picture in one screen |
|---|---|---|---|

| **20** | **Admin** | Reviews delay analytics — scheduled vs actual start/end per task | Identifies patterns and performance issues across all units |
|---|---|---|---|

---

# 4. Database Schema

All data is stored in Supabase PostgreSQL. Row Level Security (RLS) is enabled on all tables to enforce role-based data access at the database level.

## 4.1 Core Tables

### users

Stores all user accounts across all roles.

| **public.users** | | |
|---|---|---|
| **Column** | **Type** | **Notes** |
| id | uuid PK | Auto-generated unique identifier |
| full_name | text | User's display name |
| email | text UNIQUE | Login email address |
| phone | text | Optional phone number |
| role | enum | `admin` │ `supervisor` │ `unit_manager` |
| service_type_id | uuid FK | Links supervisor to their service type |
| unit_id | uuid FK | Links unit manager to their unit |
| fcm_token | text | Firebase push notification token |
| is_active | boolean | Soft disable without deleting |
| auth_id | uuid FK | Links to Supabase Auth (auth.users) |
| created_at | timestamptz | Account creation timestamp |

### service_types

Defines the categories of ground services available at the airport.

| **public.service_types** | | |
|---|---|---|
| **Column** | **Type** | **Notes** |
| id | uuid PK | Auto-generated |
| name | text UNIQUE | e.g. Fueling, Catering, Cleaning |
| description | text | Optional description |
| default_duration_minutes | integer | Expected task duration for scheduling |
| icon | text | Emoji or icon identifier for the UI |
| is_active | boolean | Soft delete — inactive types are hidden |
| created_at | timestamptz | Creation timestamp |

### units

Physical ground service teams or vehicles. Each unit belongs to one service type.

| **public.units** | | |
|---|---|---|
| **Column** | **Type** | **Notes** |
| id | uuid PK | Auto-generated |
| name | text | e.g. Fuel Truck 01 |
| service_type_id | uuid FK | Links unit to its service type |
| status | enum | `available` │ `busy` │ `offline` |
| compatible_aircraft | text[] | Array of aircraft types this unit can serve |
| shift_start_time | time | Unit's daily shift start |
| shift_end_time | time | Unit's daily shift end |
| created_at | timestamptz | Creation timestamp |

### unit_members

Crew members within a unit. These are NOT app users — they are display-only crew data managed by admin/supervisor.

| **public.unit_members** | | |
|---|---|---|
| **Column** | **Type** | **Notes** |
| id | uuid PK | Auto-generated |
| unit_id | uuid FK | Links member to their unit |
| full_name | text | Member's full name |
| phone | text | Optional phone number |
| national_id | text | Staff identification number |
| position | enum | `driver` │ `technician` │ `helper` │ `safety_officer` |
| image_url | text | Optional photo stored in Supabase Storage |
| is_active | boolean | Soft delete |
| created_at | timestamptz | Creation timestamp |

### stands

Airport parking positions where aircraft park. Each flight is assigned to a stand.

| **public.stands** | | |
|---|---|---|
| **Column** | **Type** | **Notes** |
| id | uuid PK | Auto-generated |
| code | text UNIQUE | Stand identifier e.g. A12, B05 |
| terminal | text | Terminal name or number |
| compatible_aircraft | text[] | Aircraft types that fit this stand |
| has_camera | boolean | Whether a camera is mounted at this stand |
| is_active | boolean | Soft delete |
| created_at | timestamptz | Creation timestamp |

### flights

Incoming and outgoing flights. Data is fetched from the AviationStack API and stored here for offline access and task linking.

| **public.flights** | | |
|---|---|---|
| **Column** | **Type** | **Notes** |
| id | uuid PK | Auto-generated |
| flight_number | text | e.g. EK203 |
| airline | text | e.g. Emirates |
| origin | text | Departure airport code |
| destination | text | Arrival airport code |
| aircraft_type | text | e.g. Boeing 777 |
| aircraft_registration | text | Tail number |
| scheduled_arrival | timestamptz | Planned arrival time |
| estimated_arrival | timestamptz | Updated estimate from API |
| actual_arrival | timestamptz | Real arrival time |
| scheduled_departure | timestamptz | Planned departure time |
| actual_departure | timestamptz | Real departure time |
| stand_id | uuid FK | Assigned parking stand |
| status | enum | `scheduled` │ `active` │ `departed` │ `cancelled` |
| pax_count | integer | Passenger count |
| api_source | text | Source of the data (`aviationstack` / `manual`) |
| created_at | timestamptz | Record creation timestamp |

### flight_service_requests

**NEW TABLE** — The bridge between Admin and Supervisor. Admin creates one request per service type per flight. The matching supervisor sees it and uses it to create a task.

> **Why this table is needed** Without this table, the admin has no way to notify a specific supervisor about a flight. This table creates the handoff point between admin (who decides what services are needed) and supervisor (who decides which unit to send).

| **public.flight_service_requests** | | |
|---|---|---|
| **Column** | **Type** | **Notes** |
| id | uuid PK | Auto-generated |
| flight_id | uuid FK | The flight needing service |
| service_type_id | uuid FK | Which service type is needed |
| requested_by | uuid FK | Admin who created the request |
| assigned_supervisor_id | uuid FK | Auto-populated from service_type.supervisor |
| status | enum | `pending` │ `assigned` │ `completed` |
| notes | text | Optional notes from admin to supervisor |
| created_at | timestamptz | Request creation timestamp |

### tasks

The central operational record. Created by supervisor after choosing a unit. Tracks the full lifecycle of a ground service task.

| **public.tasks** | | |
|---|---|---|
| **Column** | **Type** | **Notes** |
| id | uuid PK | Auto-generated |
| flight_id | uuid FK | Which flight this task serves |
| service_type_id | uuid FK | Which service type |
| unit_id | uuid FK | Which unit is assigned |
| assigned_by | uuid FK | Supervisor who created the task |
| created_by | uuid FK | Same as assigned_by (supervisor) |
| status | enum | `pending` │ `in_progress` │ `paused` │ `completed` │ `cancelled` |
| priority | enum | `low` │ `medium` │ `high` │ `critical` |
| scheduled_start | timestamptz | When the task should begin |
| scheduled_end | timestamptz | When the task should finish |
| actual_start | timestamptz | When unit manager tapped Start |
| actual_end | timestamptz | When unit manager tapped Complete |
| notes | text | Optional supervisor notes for the unit |
| created_at | timestamptz | Task creation timestamp |
| updated_at | timestamptz | Last modification timestamp |

### Supporting Tables

| **Table** | **Purpose** |
|---|---|
| task_checklists | Individual checklist items per task. Unit manager checks them off one by one during execution. |
| task_pauses | Records each time a task is paused — stores reason, pause time, and resume time. |
| reports | Incident reports submitted by unit managers. Has type, severity, status, image, and acknowledgment tracking. |
| notifications | Push notification records per user. Tracks read status and FCM delivery. |
| cameras | Camera devices linked to stands. Used for video verification of unit arrival/departure. |
| stand_events | Events captured by cameras — unit arrival, departure, etc. Used for delay analysis. |
| delay_analysis | Computed delay data per task — scheduled vs actual, camera vs app discrepancy. |
| flight_turnaround_summary | Aggregated summary per flight — total tasks, completed, delays, reports. |

---

# 5. Flutter Module Breakdown

The Flutter app is divided into three role-based modules under `lib/modules/`. Each module has its own navigation, screens, and feature folders. All shared logic, models, and utilities live in `lib/core/`.

## 5.1 Worker Module (Unit Manager)

- Navigation: `PersistentTabView` with 5 tabs

- Tab 0 — **Home**: task list with status filter chips

- Tab 1 — **Reports**: submitted reports with filter

- Tab 2 — **Add Report**: report submission form

- Tab 3 — **Notifications**: push notification inbox

- Tab 4 — **Profile**: unit info, crew members, settings

- Pushed routes (not tabs):

  - Task Details Screen — start/pause/complete a task, work through checklist

  - Task Info Screen — full timeline, flight details, stand details

  - Members Screen — full list of unit crew

  - Member Detail Screen — individual crew member info

## 5.2 Supervisor Module

- Navigation: bottom nav with 5 tabs

- Tab 0 — **Dashboard**: live stats, service requests, unit statuses

- Tab 1 — **Tasks**: all tasks for their service type

- Tab 2 — **Units**: unit status board

- Tab 3 — **Reports**: incident reports from their units

- Tab 4 — **Profile**: supervisor profile + settings

- Key interactions:

  - View incoming service requests from admin

  - Select a unit and create a task

  - Monitor task progress in real time

  - Acknowledge and resolve reports

## 5.3 Admin Module

- Navigation: dashboard-with-feature-grid (no bottom nav)

- Dashboard: welcome, 4 stat cards (live data), feature grid

- Feature grid (one card per feature, pushed route):

  - Service Types — CRUD for service categories

  - Stands — CRUD for airport parking positions

  - Units — CRUD for ground service teams

  - Users — create/manage supervisors and unit managers

  - Flights — view API flights, manual entry, assign stands

  - Reports — view all reports across all service types

- Settings: gear icon in AppBar → bottom sheet (language, theme, about, logout)

---

# 6. Key Data Relationships

> **Service Type is the Central Link** Everything in GroundScope traces back to a service type. A supervisor belongs to one service type. A unit belongs to one service type. A task belongs to a service type. A flight service request belongs to a service type. This single foreign key is what routes data to the right supervisor and the right unit.

| **From** | **To** | **Relationship** |
|---|---|---|
| service_types | users (supervisor) | One service type → one supervisor account |
| service_types | units | One service type → many units |
| units | users (unit_manager) | One unit → one unit manager app account |
| units | unit_members | One unit → many crew members (display only) |
| flights | stands | One flight → one stand |
| flights | flight_service_requests | One flight → many service requests (one per service type needed) |
| flight_service_requests | tasks | One service request → one task (after supervisor assigns unit) |
| tasks | task_checklists | One task → many checklist items |
| tasks | task_pauses | One task → many pause records |
| tasks | reports | One task → many reports |
| stands | cameras | One stand → one camera (optional) |

---

# 7. Admin Feature Build Order

Features must be built in this order because each one depends on the data created by the previous one.

| **#** | **Feature** | **Why this order** | **Status** |
|---|---|---|---|
| **1** | **Service Types** | Everything else depends on service types existing | ✅ Built |
| **2** | **Stands** | Flights need stands to land on | ⏳ Next |
| **3** | **Units** | Units need service types to reference | 🔲 Pending |
| **4** | **Unit Members** | Members need units to belong to | 🔲 Pending |
| **5** | **Users** | Supervisors need service types. Unit managers need units. | 🔲 Pending |
| **6** | **Flights** | Flights need stands. API integration here. | 🔲 Pending |
| **7** | **Flight Service Requests** | Admin sends requests to supervisors per flight | 🔲 Pending |
| **8** | **Admin Dashboard** | Build last — pulls real data from all the above | ⚡ Partial (stats wired) |
| **9** | **Reports Overview** | Admin monitors reports across all units | 🔲 Pending |
| **10** | **Delay Analytics** | Computed from task actual vs scheduled timestamps | 🔲 Pending |

---

# 8. Key Design Decisions

## Soft Delete Only

No record is ever hard-deleted from the database. All entities (service types, units, users, etc.) have an `is_active` boolean. Inactive records are hidden from the UI but preserved for historical data integrity — reports and tasks referencing a deleted unit must still be readable.

## Supervisor Scoped to One Service Type

A supervisor cannot oversee multiple service types. This is by design — it keeps each supervisor's workload focused and ensures clear accountability. The `service_type_id` on the users table enforces this at the DB level via RLS.

## Unit Members Are Not App Users

Unit members (crew) are stored in the `unit_members` table but do NOT have login accounts. Only the Unit Manager has an app account. This simplifies authentication and prevents scope creep. Crew data is for display only (unit profile screen).

## Tasks Are Created by Supervisors, Not Admins

The admin sends a service request per flight per service type. The supervisor then decides which unit to assign and creates the task. This two-step handoff ensures the supervisor has visibility and control over their units' workload — the admin cannot bypass the supervisor.

## flight_service_requests Is the Handoff Table

This table (new, not in the original SRS) is the critical link between admin and supervisor. Without it, there is no formal way for the admin to request a service and for the supervisor to see it. It also provides an audit trail of who requested what for which flight.

---

> **For New Team Members** If you are joining the project: start by reading this document, then look at the database schema in Supabase, then read the `CLAUDE.md` file in the project root to understand coding conventions before writing any code.

---

*GroundScope — System Design Reference · Version 1.0*
