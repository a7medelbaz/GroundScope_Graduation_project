# GROUNDSCOPE

## Airport Ground Services Coordination System

### Graduation Project Document

---

**University:** Zagazig National University
**Faculty:** Faculty of Computers and Informatics
**Program:** [TODO]
**Supervisor:** [TODO]
**Academic Year:** 2025 / 2026

**Developed by:**

- Ahmed Elbaz Talba Elbaz Sobah
- Mohamed Hosni Mohamed Hassan
- Amr Mohamed Abdelhamid Badr
- Abdullah Mohamed Abdullah Nour El-Din
- Shaimaa Mohamed Suleiman Ibrahim
- Alyaa Fayez Mohamed Mahmoud
- Mahetab Abdelwahed Abdelmonem
- Wissam Karam Shahata Ahmed El-Zuhairy
- Nada Mohamed Gamal El-Bayoumi Mohamed

**With the generous support of our friend and brother:** Mustafa Elbaz

---

# Abstract

Airport ground operations require precise coordination of multiple services — fueling, catering, cleaning, baggage handling, and passenger services — within tight turnaround windows. At most airports, this coordination relies on phone calls, paper logs, and radio communication, leading to real-time visibility gaps, untracked delays, and inefficient incident reporting.

GroundScope is a real-time airport ground services coordination system developed for Cairo International Airport (IATA: CAI). The system consists of three components sharing a common Supabase (PostgreSQL) backend: a **Flutter mobile application** for iOS and Android targeting Supervisors and Unit Managers, a **Next.js 14 web admin dashboard** for the airport administrator, and **GroundScope Vision**, a YOLO11s computer-vision module that detects ground service equipment in apron camera footage to provide camera-based validation of ground operations. Together they digitize the full flight turnaround lifecycle — from automated flight schedule ingestion through task creation, assignment, execution, incident reporting, and delay analytics.

The system enforces role-based data isolation at the database level using Supabase Row Level Security, supports bilingual operations in English and Arabic with full RTL layout, and delivers real-time task and unit status updates via Supabase Realtime streams. The mobile application follows a modular BLoC/Cubit architecture with GetIt dependency injection, while the web dashboard uses the Next.js App Router with server and client Supabase client strategies.

GroundScope replaces manual coordination workflows with a structured digital system, providing administrators with live operational visibility, supervisors with actionable task queues, and unit managers with guided task execution tools — reducing miscommunication, improving turnaround accountability, and enabling data-driven delay analysis.

---

# Acknowledgment

We would like to express our sincere gratitude to our supervisor **[Supervisor Name]** for their continuous guidance, support, and valuable feedback throughout the development of this project.

We also extend our thanks to the Faculty of Computers and Informatics at **Zagazig National University** for providing the academic environment and resources that made this work possible.

A special and heartfelt thank you to our friend and brother **Mustafa Elbaz**, whose generous support, technical insight, and dedication were invaluable to us throughout every stage of this journey.

Finally, we are grateful to our families and friends for their patience and encouragement throughout this journey.

— Ahmed Elbaz Talba Elbaz Sobah, Mohamed Hosni Mohamed Hassan, Amr Mohamed Abdelhamid Badr, Abdullah Mohamed Abdullah Nour El-Din, Shaimaa Mohamed Suleiman Ibrahim, Alyaa Fayez Mohamed Mahmoud, Mahetab Abdelwahed Abdelmonem, Wissam Karam Shahata Ahmed El-Zuhairy, Nada Mohamed Gamal El-Bayoumi Mohamed

---

# Chapter 1: Introduction

---

## 1.1 Problem Statement

Airport ground operations are complex and time-critical. Every flight turnaround — from arrival to departure — requires precise coordination of multiple ground services including fueling, catering, cleaning, baggage handling, and passenger services. At most airports, these operations are managed through phone calls, paper logs, and radio communication, creating several critical problems:

- **Lack of real-time visibility**: Supervisors and administrators have no live view of task progress across their units.
- **Manual task assignment**: Tasks are assigned by phone or paper, leading to delays and miscommunication.
- **Untracked delays**: Without digital timestamps, it is difficult to measure, analyze, or optimize turnaround times.
- **Inefficient incident reporting**: Issues found during ground handling are reported verbally or on paper, with no photo evidence or severity tracking.
- **No role-based data isolation**: All stakeholders see the same information, creating security and accountability risks.
- **Language barriers**: At bilingual airports, Arabic-speaking workers may struggle with English-only systems.

Without a coordination system, delays cascade, accountability is unclear, and operational efficiency suffers.

---

## 1.2 Objectives

GroundScope aims to solve these problems with the following objectives:

1. **Digitize the full turnaround process** — from flight schedule to task completion to incident reporting.
2. **Connect three key roles** — Admin, Supervisor, and Unit Manager (Worker) — each with a tailored interface and data access.
3. **Provide real-time task lifecycle management** — create, assign, start, pause, resume, complete, and report on tasks.
4. **Enable structured incident reporting** — with photo evidence, severity levels, and acknowledgment/resolution workflow.
5. **Enforce role-based data access** — using Supabase Row Level Security (RLS) at the database level.
6. **Support bilingual operations** — English and Arabic with RTL layout support.
7. **Integrate with flight data APIs** — automatically ingest flight schedules from AviationStack.
8. **Enable delay analytics** — compare scheduled vs actual timestamps per task per flight.
9. **Automate visual monitoring** — detect ground service equipment from apron cameras to provide an objective, camera-based reference for validating ground operations.

---

## 1.3 Scope and Limitations

### In Scope

- **Three user roles**: Admin (full system owner), Supervisor (manages one service type), Unit Manager (executes tasks)
- **Task management**: Create, assign, start, pause, complete — with checklist items and pause reasons
- **Incident reporting**: Submit reports with type, severity, description, and photo; supervisor acknowledge/resolve workflow
- **Real-time updates**: Supabase Realtime streams for live task and unit status
- **Flight data ingestion**: Automatic import from AviationStack API, manual entry option
- **Unit and crew management**: CRUD for units and unit members (display-only)
- **Responsive mobile design**: iOS and Android via Flutter, 390×844 design canvas
- **Bilingual**: English and Arabic with easy_localization
- **Web admin dashboard**: Next.js 14 web application for the airport administrator, providing real-time operations monitoring, flight import, CRUD management, analytics, and user account creation
- **GroundScope Vision (equipment detection)**: a trained YOLO11s model that detects 10 classes of ground service equipment in apron footage. The model is trained and verified standalone; the data-flow into the database is designed (the live camera-to-Supabase bridge is future work — see §1.3 Out of Scope)

### Out of Scope

- **Offline mode**: No local SQLite sync on mobile; requires active internet connection
- **Advanced ML analytics**: No machine learning for delay prediction or resource optimization
- **Live camera-to-database bridge**: The GroundScope Vision detector is trained and its integration designed, but the runtime service that streams camera feeds and writes detections into the database is not implemented in this iteration
- **Autonomous ground vehicles**: No integration with AGV fleet management
- **Voice/Smartwatch support**: App is touch-only, no voice commands
- **Multi-airport support**: System is scoped to Cairo International Airport (CAI) only

---

## 1.4 Project Structure

GroundScope follows a modular architecture with three layers:

### Code Organization

```Shell
lib/
├── core/                        # Shared infrastructure
│   ├── api/                     # Dio HTTP client (consumer, interceptors, factory)
│   ├── auth/                    # Authentication (login, auth gate, auth cubit)
│   ├── config/                  # AppConfig, FirebaseOptions
│   ├── di/                      # GetIt dependency injection
│   ├── error/                   # AppError, SupabaseErrorHandler
│   ├── localization/            # LocalizationManager
│   ├── networking/              # Supabase service client
│   ├── router/                  # Named routes + AppRouter
│   ├── service/                 # SecureStorage, SharedPrefs, UserService
│   ├── settings/                # AppSettingsCubit + AppSettingsState
│   ├── themes/                  # Colors, text styles, custom colors
│   ├── utils/                   # Spacing, extensions, helpers
│   ├── shared/data/models/      # Flight, Task, Unit, Report, etc.
│   ├── shared/data/remote/      # Shared Supabase data sources
│   ├── shared/data/repo/        # Shared repository interfaces
│   └── widgets/                 # Reusable UI components
├── modules/
│   ├── worker/                  # Unit Manager role (5 tabs)
│   ├── supervisor/              # Supervisor role (5 tabs)
│   └── admin/                   # Admin role (dashboard + feature cards)
├── ground_scope_app.dart
├── main_dev.dart
└── main_prod.dart
```

### Feature Module Layout

Every feature follows a consistent `data/logic/ui` structure:

```
feature/
├── data/
│   ├── remote/   # Supabase API calls (FeatureNameRemoteDs)
│   └── repo/     # Abstract interface (FeatureNameRepo) + implementation (FeatureNameRepoImpl)
├── logic/
│   └── cubit/    # FeatureNameCubit + FeatureNameState (state is part of cubit file)
└── ui/
    ├── feature_name_screen.dart
    └── widgets/
```

### Technology Stack

| Layer                | Technology                                   |
| -------------------- | -------------------------------------------- |
| Mobile Framework     | Flutter (Dart)                               |
| State Management     | Cubit / BLoC pattern                         |
| Dependency Injection | GetIt service locator                        |
| Backend              | Supabase (PostgreSQL + Auth + Storage + RLS) |
| Push Notifications   | Firebase Cloud Messaging                     |
| Flight Data          | AviationStack API                            |
| Design Canvas        | 390 × 844 px (flutter_screenutil)           |
| Localization         | English + Arabic (easy_localization)         |
| Fonts                | Manrope (EN) · Tajawal (AR)                 |

---

## 1.5 Web Admin Dashboard

The web admin dashboard (`groundscope-admin/`) is a Next.js 14 application that shares the same Supabase backend as the mobile app. It is the primary interface for the airport administrator on desktop browsers.

### Project Structure

```
groundscope-admin/
├── src/
│   ├── app/
│   │   ├── [locale]/
│   │   │   ├── (auth)/login/page.tsx          # Email / password sign-in
│   │   │   └── (dashboard)/
│   │   │       ├── page.tsx                   # Overview dashboard
│   │   │       ├── operations/page.tsx        # Live Kanban board
│   │   │       ├── flights/                   # Flights list + detail
│   │   │       ├── reports/                   # Reports list + detail
│   │   │       ├── analytics/page.tsx         # Analytics tabs
│   │   │       ├── service-types/page.tsx
│   │   │       ├── stands/page.tsx
│   │   │       ├── units/                     # Units list + detail
│   │   │       └── users/page.tsx
│   │   └── api/
│   │       ├── create-user/route.ts           # POST — user creation
│   │       └── import-flights/route.ts        # POST — AviationStack import
│   ├── components/
│   │   ├── layout/                            # Sidebar, topbar, mobile drawer
│   │   ├── ui/                                # Primitive components
│   │   ├── forms/                             # React Hook Form + Zod forms
│   │   ├── tables/                            # TanStack Table definitions
│   │   ├── sections/                          # Page-scoped composites
│   │   ├── charts/                            # Recharts wrappers
│   │   └── dialogs/                           # ConfirmDialog, CredentialsDialog
│   ├── lib/
│   │   ├── supabase/                          # Browser + server Supabase clients
│   │   ├── queries/                           # All data reads/writes per entity
│   │   ├── types/database.ts                  # Typed interfaces for all tables
│   │   ├── utils/                             # Status colors, credentials, cn
│   │   └── actions/auth.ts                    # Server actions for sign-in/out
│   └── messages/
│       ├── en.json                            # English strings
│       └── ar.json                            # Arabic strings
├── .env.local                                 # Environment variables
├── tailwind.config.ts
└── next.config.ts
```

### Technology Stack

| Layer                | Package                                                       | Version  |
| -------------------- | ------------------------------------------------------------- | -------- |
| Framework            | `next`                                                      | 14.2.35  |
| Language             | TypeScript                                                    | ^5       |
| Styling              | `tailwindcss`                                               | ^3.4.1   |
| Component primitives | `@radix-ui/react-dropdown-menu`, `@radix-ui/react-select` | ^2.x     |
| Animation            | `framer-motion`                                             | ^12.42.0 |
| Database client      | `@supabase/supabase-js`                                     | ^2.108.2 |
| SSR Supabase helpers | `@supabase/ssr`                                             | ^0.12.0  |
| Tables               | `@tanstack/react-table`                                     | ^8.21.3  |
| Charts               | `recharts`                                                  | ^3.9.0   |
| Forms                | `react-hook-form`                                           | ^7.80.0  |
| Schema validation    | `zod`                                                       | ^4.4.3   |
| i18n                 | `next-intl`                                                 | ^4.13.0  |
| Theming              | `next-themes`                                               | ^0.4.6   |
| Icons                | `lucide-react`                                              | ^1.21.0  |
| Date formatting      | `date-fns`                                                  | ^3.6.0   |
| Class merging        | `clsx` + `tailwind-merge`                                 | ^2 / ^3  |

---

# Chapter 2: Literature Review

---

## 2.1 Overview

Airport ground operations have been studied extensively in operations research, aviation management, and software engineering literature. This chapter reviews both academic publications and commercial systems relevant to the development of GroundScope. The review identifies the current state of the art, key challenges, and gaps that GroundScope addresses.

---

## 2.2 Academic Literature

### 2.2.1 Systematic Reviews of Ground Operations

**Dahanayaka, Prak, and Mes (2026)** published a comprehensive systematic review titled *"From gate to runway: A systematic review of airport ground operations optimization"* in the Journal of Air Transport Management [1]. The study employed bibliometric and network analysis tools to review 199 scientific papers, identifying seven key functional areas: airport gate assignment, boarding process and strategies, turnaround process, baggage handling, ground workforce planning and scheduling, aircraft taxiing and ground movements, and ground support equipment handling. The review found that heuristic approaches are predominant, particularly in airport gate assignment. The authors identified future research directions centered on algorithmic advancements, adaptability to uncertainty, and integration between subdomains. This review provides a broad foundation for understanding the landscape of ground operations optimization, though it focuses exclusively on operations research rather than mobile coordination systems.

**Zhou, Shen, Zheng, et al. (2025)** published *"A comprehensive review of ground support equipment scheduling for aircraft ground handling services"* in Transportation Research Part E [2]. This study examined nine types of ground support equipment (GSE) — ferry, baggage, refueling, garbage, sewage, freshwater, catering, de-icing, and towing vehicles — and their scheduling methodologies. The authors gave particular attention to the similarities and distinctive features shaped by unique service requirements. With the growing emphasis on Airport Collaborative Decision Making (A-CDM), recent studies on multi-type GSE coordination were reviewed. The study identified current research gaps including the need for integrated scheduling across GSE types and real-time adaptability.

### 2.2.2 Automation and Digitalization

**Tiur Basaria et al. (2024)** conducted a systematic literature review on trends of automation in the airport apron area [3]. Using the PRISMA methodology, the study analyzed papers on automation levels, cost-effectiveness, and decision-maker perspectives. The review found that while automation is rapidly evolving in the apron area, strategic conversations among stakeholders are still needed to align on implementation priorities. The study is limited to the apron area and does not address mobile coordination systems for ground handling staff.

**A systematic review on autonomous ground vehicles (AGVs) for airport operations (2025)** explored challenges, risks, and technological innovations in integrating AGVs into airport operations [7]. Published in Mechanical Engineering for Society and Industry, the study applied the PRISMA methodology to screen 206 peer-reviewed articles, with 14 selected for detailed analysis. Key findings highlighted the importance of advanced perception systems, multi-agent coordination, and AI-based algorithms. Emerging innovations such as sensor fusion, transfer learning, and simulation-based development were identified as effective in improving reliability and operational efficiency.

**Eitrheim, Nordfjærn, Log, and Tørset (2024)** published *"Towards solving the airport ground workforce dilemma: A literature review on hiring, scheduling, retention, and digitalization"* [4]. This study discussed the challenges exposed during the post-COVID-19 recovery of Summer 2022, when airlines and airports had to cut flights due to insufficient ground workforce. The review categorized challenges into four areas: hiring new talent, workforce scheduling, staff retention, and digitalization. The authors concluded that digitalization is a key lever for addressing workforce challenges, though their review covered more than 100 papers from scattered literature with no focus on mobile coordination tools.

### 2.2.3 Multi-Agent Planning and AI Approaches

**Kabongo, Ramos, Ferreira Leite, Ghedini Ralha, and Li** proposed *"A Multi-Agent Planning Model for Airport Ground Handling Management"* that uses a multi-agent planning (MAP) approach [5]. The model follows a refinement planning strategy compatible with the Airport Collaborative Decision Making (A-CDM) concept. The framework coordinates tasks and planning between distributed agents in order to reduce delays and operating costs. Preliminary results showed effectiveness in dealing with ground handling management planning, though the study was limited to simulation at Ciudad Real Central Airport and has not been tested in real mobile environments.

**Wu, Zhou, Xia, Zhang, Cao, and Zhang** developed a neural method for airport ground handling in their paper *"Neural airport ground handling"* [6]. They modeled airport ground handling as a multiple-fleet vehicle routing problem (VRP) with miscellaneous constraints including precedence, time windows, and capacity. The proposed construction framework decomposes AGH into sub-problems and uses an attention-based neural network trained with reinforcement learning. Extensive experiments demonstrated significant outperformance over classic meta-heuristics, construction heuristics, and specialized AGH methods. The method generalizes to instances with large numbers of flights and can be adapted for real-time AGH with stochastic flight arrivals. However, it requires training data and does not incorporate human-in-the-loop coordination.

---

## 2.3 Commercial Systems

Several commercial platforms address airport ground handling coordination:

**INFORM GroundStar (GS TeamWork)** is a real-time workforce and equipment management platform designed for aviation ground operations [8]. It empowers frontline managers at small to medium airport stations to efficiently assign tasks, adapt to changes, and optimize resource utilization from a mobile interface. According to INFORM's published case study, the system achieved a 90% reduction in task allocation time, a 25% decrease in minimum equipment list processing, and a 10% increase in work package completion rates at flydubai. The system is proprietary and enterprise-scale, requiring significant investment and deployment time.

**Neural Lab's OpsAssist** is an AI-powered smart assistant that assigns ground handling tasks in real time [9]. According to Neural Lab's published case study, the system reduced work hours by 20% while improving task coverage and driver capacity by 22% when implemented at Singapore Changi Airport for SATS. The system breaks flights into towing trips and matches them to the right driver based on timing, location, and workload. As a pilot case study, it lacks peer-reviewed validation.

**Airport Collaborative Decision Making (A-CDM)** solutions from vendors like **Naitec**, **Veovo**, and **IBS Software** provide web and mobile platforms that integrate with Eurocontrol's Network Manager [10][11][12]. These systems standardize turnaround milestones (TOBT, TSAT, etc.) and provide common situational awareness to all stakeholders. TAV Technologies' **TAMS** adds generative AI capabilities for natural language querying and predictive analytics [13]. **EPG's AES Resource Management System** automates workforce and shift planning with task-based invoicing [14]. **AirportLabs GCAM** provides an all-in-one platform including a mobile turn manager for task collection and progress tracking [15]. **Shifton** offers a mobile-first dispatch solution with GPS-verified check-in, SLA protection, and real-time turnaround tracking [16]. **Viargo** by Ozion connects planning, field execution, and operational oversight through adaptive real-time coordination [17].

---

## 2.4 Comparison Table

| #  | Source                     | Type                            | Method/Approach                       | Key Contribution                                   | Limitations / Gap                                |
| -- | -------------------------- | ------------------------------- | ------------------------------------- | -------------------------------------------------- | ------------------------------------------------ |
| 1  | Dahanayaka et al. (2026)   | Systematic Review (199 papers)  | Bibliometric + network analysis       | 7 functional areas identified; heuristic dominance | No mobile coordination apps or role-based access |
| 2  | Zhou et al. (2025)         | Comprehensive Review            | Taxonomy of 9 GSE types               | Detailed scheduling models; A-CDM integration gap  | Optimization-focused; no real-time UI/UX         |
| 3  | Tiur Basaria et al. (2024) | Systematic Review (PRISMA)      | Trends in apron automation            | Automation levels; cost-effectiveness              | Limited to apron; no coordination apps           |
| 4  | Eitrheim et al. (2024)     | Literature Review (100+ papers) | Workforce dilemma: digitalization     | Digitalization as key lever                        | No specific coordination system design           |
| 5  | Kabongo et al.             | Multi-Agent Planning            | MAP + A-CDM framework                 | Distributed coordination; refinement planning      | Simulation only; no mobile field app             |
| 6  | Wu et al.                  | Deep RL + Attention Network     | Neural VRP construction heuristic     | Outperforms meta-heuristics; generalizable         | Training data required; no human-in-loop         |
| 7  | AGV Review (2025)          | Systematic Review (206→14)     | AGV challenges review                 | Sensor fusion; transfer learning                   | Focus on autonomy; not human coordination        |
| 8  | INFORM GS TeamWork         | Commercial                      | Real-time workforce coordination      | 90% allocation time reduction (vendor-reported)    | Proprietary; enterprise-only; no peer review     |
| 9  | Neural Lab OpsAssist       | Commercial + AI                 | AI task assignment + mobile app       | 20% work hour reduction (vendor-reported)          | Case study only; no academic validation          |
| 10 | A-CDM (Naitec, Veovo, IBS) | Commercial Standards            | Eurocontrol A-CDM milestones + mobile | Standardized turnaround milestones                 | Airport-level; not unit-level task execution     |

---

## 2.5 GroundScope's Positioning

GroundScope occupies a unique position in the landscape of airport ground operations systems:

- **Role-based mobile coordination**: Unlike enterprise systems designed for central control rooms, GroundScope tailors the experience to three distinct roles (Admin, Supervisor, Unit Manager) with appropriate data access and functionality for each.
- **Real-time task lifecycle**: Beyond scheduling and allocation, GroundScope tracks the entire task lifecycle — start, pause, resume, complete — with checklist items and pause reasons.
- **Database-level data isolation**: Supabase RLS enforces data access at the database level, ensuring that each role sees only authorized data.
- **Flight data integration**: Automatic ingestion from AviationStack API with manual fallback.
- **Structured incident reporting**: Reports with type, severity, photo evidence, and acknowledgment/resolution workflow.
- **Bilingual support**: Full English and Arabic localization with RTL layout.

GroundScope fills the gap between airport-level A-CDM systems (which focus on departure milestones) and proprietary enterprise tools (which require significant investment). It provides a lightweight, mobile-first coordination system suitable for medium-sized airports or specific service type departments at larger airports.

---

# Chapter 3: System Requirements & Analysis

---

## 3.1 System Overview

GroundScope is a real-time airport ground services coordination application. It digitizes and streamlines the entire turnaround process — from the moment a flight is scheduled to the moment it departs — by connecting three key roles: Admin, Supervisor, and Unit Manager (Worker).

GroundScope consists of two client components that share a single Supabase backend:

| Component                                    | Technology                      | Audience                       |
| -------------------------------------------- | ------------------------------- | ------------------------------ |
| Mobile app (`ground_scope/`)               | Flutter (Dart) — iOS & Android | Supervisors & Unit Managers    |
| Web admin dashboard (`groundscope-admin/`) | Next.js 14 — desktop browser   | Airport administrator          |
| Computer vision (`groundscope-vision`)     | Python · Ultralytics YOLO11s   | Apron camera feeds (automated) |

The shared infrastructure consists of:

- **Backend**: Supabase (PostgreSQL + Auth + Storage + Row Level Security)
- **Flight Data**: AviationStack API for automatic flight ingestion
- **Push Notifications**: Firebase Cloud Messaging (FCM) — mobile only

Data flows through a defined lifecycle: Admin imports flights via the web dashboard and creates pending tasks → Supervisor assigns units to pending tasks via the mobile app → Unit Manager executes tasks and submits reports → Supervisor acknowledges/resolves reports → Admin reviews analytics on the web dashboard.

---

## 3.2 Functional Requirements

### 3.2.1 Admin Functional Requirements

| ID        | Requirement               | Description                                                                                                                           | Platform      |
| --------- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| FR-ADM-01 | Manage Service Types      | Create, edit, and deactivate ground service types (e.g., Fueling, Catering, Cleaning)                                                 | Web Dashboard |
| FR-ADM-02 | Manage Stands             | Create, edit, and deactivate airport parking positions with terminal and aircraft compatibility                                       | Web Dashboard |
| FR-ADM-03 | Manage Units              | Create, edit, and deactivate operational units with service type, shift times, and aircraft compatibility                             | Web Dashboard |
| FR-ADM-04 | Manage Unit Members       | Create, edit, and deactivate crew members within a unit (display-only, no login)                                                      | Web Dashboard |
| FR-ADM-05 | Manage Users              | Create supervisor and unit manager accounts with role assignment and auto-generated credentials                                       | Web Dashboard |
| FR-ADM-06 | Import Flights            | Import scheduled flights from AviationStack API or enter manually                                                                     | Web Dashboard |
| FR-ADM-07 | Send Service Requests     | Create pending tasks (unassigned) per flight per service type for supervisors to action                                               | Mobile & Web  |
| FR-ADM-08 | View Analytics            | View flight turnaround summaries and delay analytics across all service types with date-range filtering                               | Web Dashboard |
| FR-ADM-09 | View All Reports          | View, acknowledge, and resolve incident reports across all units and service types                                                    | Web Dashboard |
| FR-ADM-10 | Monitor Live Operations   | View a real-time Kanban board of all tasks across pending, in-progress, and completed states; update task status inline               | Web Dashboard |
| FR-ADM-11 | Auto-generate Credentials | System auto-generates email and password for new supervisor/manager accounts; credentials shown once via dialog and not stored        | Web Dashboard |
| FR-ADM-12 | Export Reports            | Export filtered incident reports to CSV directly from the reports list                                                                | Web Dashboard |
| FR-ADM-13 | Real-time Overview        | View live stat cards (flights today, active tasks, pending requests, open reports) updated via Supabase Realtime without page refresh | Web Dashboard |

### 3.2.2 Supervisor Functional Requirements

| ID        | Requirement             | Description                                                                                          |
| --------- | ----------------------- | ---------------------------------------------------------------------------------------------------- |
| FR-SUP-01 | View Service Requests   | View pending tasks (unassigned) for their assigned service type on the dashboard                     |
| FR-SUP-02 | Assign Unit to Task     | Select an available unit and assign it to a pending task, setting scheduled start/end                |
| FR-SUP-03 | Monitor Tasks           | View live task status (pending, in_progress, paused, completed, cancelled) across all assigned units |
| FR-SUP-04 | Acknowledge Reports     | Acknowledge incident reports submitted by unit managers                                              |
| FR-SUP-05 | Resolve Reports         | Mark acknowledged reports as resolved                                                                |
| FR-SUP-06 | View Units in Real-Time | See live unit availability status via Supabase Realtime streams                                      |
| FR-SUP-07 | File Standalone Report  | Submit an incident report without associating it with a specific task or flight                      |
| FR-SUP-08 | Select Report Target    | Choose whether a standalone report is sent to Admin or Worker                                        |
| FR-SUP-09 | Attach Photo Evidence   | Capture or upload photo evidence with incident reports                                               |

### 3.2.3 Unit Manager (Worker) Functional Requirements

| ID        | Requirement            | Description                                                                  |
| --------- | ---------------------- | ---------------------------------------------------------------------------- |
| FR-WRK-01 | View Task List         | See all tasks assigned to their unit, filterable by status                   |
| FR-WRK-02 | Start Task             | Begin a task, changing its status from pending to in_progress                |
| FR-WRK-03 | Pause Task             | Pause an active task with a reason, recording pause duration                 |
| FR-WRK-04 | Resume Task            | Resume a paused task                                                         |
| FR-WRK-05 | Complete Task          | Mark a task as completed with actual_end timestamp                           |
| FR-WRK-06 | Work Checklist         | Check off task checklist items one by one                                    |
| FR-WRK-07 | View Task Details      | See flight info, stand, timing, priority, service type, and notes            |
| FR-WRK-08 | View Task Timeline     | See task history including pauses, checklist completions, and status changes |
| FR-WRK-09 | Submit Incident Report | Submit a report with type, severity, description, and optional photo         |
| FR-WRK-10 | View Unit Info         | See unit name, service type, shift times, and crew members                   |
| FR-WRK-11 | Receive Notifications  | Receive push notifications from supervisor                                   |

---

### 3.2.4 GroundScope Vision (Computer Vision) Functional Requirements

> These requirements describe the designed behaviour of the vision module. The model is trained and verified; the live database bridge is future work.

| ID       | Requirement                | Description                                                                                 |
| -------- | -------------------------- | ------------------------------------------------------------------------------------------- |
| FR-CV-01 | Detect Equipment           | Detect and classify 10 classes of ground service equipment in apron camera frames           |
| FR-CV-02 | Generate Stand Events      | Emit a`stand_events` record (source = camera) for each detected unit, with a service type |
| FR-CV-03 | Estimate Arrival/Departure | Use multi-object tracking to estimate camera-observed unit arrival and departure timestamps |
| FR-CV-04 | Attach Confidence          | Record the detection confidence score (0–1) on each generated event                        |

## 3.3 Non-Functional Requirements

| ID     | Requirement                    | Implementation                                                                                                       |
| ------ | ------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| NFR-01 | Role-based Data Isolation      | Supabase RLS policies on all tables ensure each role sees only authorized data                                       |
| NFR-02 | Real-time Updates              | Supabase Realtime streams push task and unit status changes to connected clients                                     |
| NFR-03 | Responsive Design              | flutter_screenutil ensures consistent layout across device sizes (390×844 base canvas)                              |
| NFR-04 | Bilingual Support              | easy_localization provides English and Arabic with RTL layout via context.isArabic                                   |
| NFR-05 | Secure Authentication          | Supabase Auth with JWT tokens stored in flutter_secure_storage                                                       |
| NFR-06 | Soft Delete                    | All entities use`is_active` boolean; no hard deletes preserve historical data integrity                            |
| NFR-07 | Structured Error Handling      | AppError factory constructors with SupabaseErrorHandler preserve server error messages                               |
| NFR-08 | Optimistic UI Updates          | Supervisor reports tab uses local state updates before server confirmation                                           |
| NFR-09 | Stream Subscription Management | All Cubit.close() methods cancel Supabase Realtime subscriptions to prevent memory leaks                             |
| NFR-10 | Detection Accuracy             | The vision model achieves ≥ 99 % mAP@50 on its validation set to keep camera-based events trustworthy               |
| NFR-11 | Vision Throughput              | Real-time per-camera inference requires a GPU (~100+ FPS); CPU-only operation is limited to offline/strided analysis |

---

## 3.4 Hardware & Software Requirements

### Mobile Device Requirements

| Requirement      | Minimum                     | Recommended           |
| ---------------- | --------------------------- | --------------------- |
| Operating System | iOS 13+ / Android 6+        | iOS 16+ / Android 12+ |
| RAM              | 2 GB                        | 4 GB+                 |
| Storage          | 50 MB free                  | 100 MB+ free          |
| Screen Size      | 4.7" (iPhone SE)            | 6.1"+                 |
| Camera           | Required for photo evidence | 12 MP+                |
| Network          | 4G LTE                      | 5G / WiFi             |

### Backend Requirements

| Component          | Specification                       |
| ------------------ | ----------------------------------- |
| Supabase Project   | PostgreSQL 15+, 500 MB+ storage     |
| Auth Provider      | Supabase Auth (email/password)      |
| Storage Bucket     | report-images (for incident photos) |
| Push Notifications | Firebase project with FCM enabled   |
| External API       | AviationStack API key               |

### Computer Vision Requirements

| Component             | Specification                                                      |
| --------------------- | ------------------------------------------------------------------ |
| Runtime               | Python 3.9+, Ultralytics (YOLO11s), OpenCV                         |
| Inference (real-time) | NVIDIA GPU with TensorRT; see Vision Edge Device table below       |
| Inference (offline)   | CPU supported (~4.57 FPS at 640×640)                              |
| Camera                | USB camera re-streamed via GStreamer as RTSP                       |
| Export targets        | ONNX (verified), TensorRT (JetPack built-in), TFLite/CoreML (edge) |

### Vision Edge Device (Production Hardware)

The production deployment of GroundScope Vision runs on a **NVIDIA Jetson** embedded board installed at the airport stand. The specific unit in deployment has the following verified specifications:

| Component         | Specification                                                                                  |
| ----------------- | ---------------------------------------------------------------------------------------------- |
| Board             | NVIDIA Jetson (t186ref) — JetPack / L4T R32.7.6                                               |
| OS                | Ubuntu 18.04.6 LTS (kernel 4.9.337-tegra, aarch64)                                             |
| CPU               | ARM Cortex-A57, 6 cores (4 online, 2 offline in current config), up to 2035 MHz, Little Endian |
| RAM               | 3.7 GB total system RAM (unified with GPU — Tegra t186ref unified memory architecture)        |
| Storage (OS)      | 14.7 GB eMMC (`/dev/mmcblk0`)                                                                |
| Storage (data)    | 119.2 GB NVMe SSD (`nvme0n1`) — model weights and video buffer                              |
| GPU               | NVIDIA Tegra GPU — CUDA via`nvidia-l4t-cuda` (L4T 32.7.6)                                   |
| Inference runtime | TensorRT (JetPack built-in) — primary; ONNX Runtime (aarch64) — fallback                     |
| Camera            | USB camera (IMC Networks, ID 13d3:3549) re-streamed via GStreamer                              |
| Network           | Wi-Fi (`wlan0`) or Ethernet (`eth0`) to reach Supabase                                     |
| Container support | Docker installed — vision service can be containerized                                        |

### Development Environment

| Tool         | Version                  |
| ------------ | ------------------------ |
| Flutter SDK  | 3.x                      |
| Dart SDK     | 3.x                      |
| Supabase CLI | Latest                   |
| Firebase CLI | Latest                   |
| IDE          | VS Code / Android Studio |

---

## 3.5 Use Case Diagrams

### 3.5.1 Admin Use Cases

```
                    ┌─────────────────────────────┐
                    │         Admin                │
                    └─────────────┬───────────────┘
                                  │
          ┌───────────────────────┼───────────────────────┐
          │           │           │           │           │
          ▼           ▼           ▼           ▼           ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
    │  Manage  │ │  Manage  │ │  Manage  │ │  Import  │ │  View    │
    │ Service  │ │  Stands  │ │  Units & │ │  Flights │ │Analytics │
    │  Types   │ │          │ │  Members │ │          │ │          │
    └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
        │                           │
        ▼                           ▼
    ┌──────────┐              ┌──────────┐
    │  Manage  │              │  Create  │
    │  Users   │              │ Pending  │
    │ (CRUD)   │              │  Tasks   │
    └──────────┘              └──────────┘
```

### 3.5.2 Supervisor Use Cases

```
                   ┌──────────────────────────────┐
                   │        Supervisor             │
                   └──────────────┬───────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │           │           │           │           │
         ▼           ▼           ▼           ▼           ▼
   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
   │  View    │ │  Assign  │ │  Monitor │ │Acknowledge│ │  File    │
   │ Pending  │ │  Unit to │ │   Task   │ │ / Resolve │Standalone │
   │  Tasks   │ │  Task    │ │ Progress │ │  Reports  │  Report   │
   └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
```

### 3.5.3 Unit Manager (Worker) Use Cases

```
                   ┌──────────────────────────────┐
                   │      Unit Manager (Worker)    │
                   └──────────────┬───────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │           │           │           │           │
         ▼           ▼           ▼           ▼           ▼
   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
   │  View    │ │ Start /  │ │  Work    │ │  Submit  │ │  View    │
   │Assigned  │ │Pause /   │ │ Check-   │ │ Incident │ │  Unit    │
   │  Tasks   │ │Complete  │ │  list    │ │  Report  │ │  Info    │
   └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
```

---

## 3.6 Data Flow Diagrams

### 3.6.1 Flight Turnaround Lifecycle

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FLIGHT TURNAROUND                             │
└─────────────────────────────────────────────────────────────────────┘

          ┌──────────────────┐
          │  AviationStack   │
          │  API / Manual    │
          └────────┬─────────┘
                   │ Flight data
                   ▼
          ┌──────────────────┐
          │    flights       │
          │    table         │
          └────────┬─────────┘
                   │ Admin creates pending task (unit_id = NULL)
                   ▼
          ┌──────────────────┐
          │  tasks table     │
          │ (status=pending, │
          │  unit_id=NULL)   │
          └────────┬─────────┘
                   │ Supervisor sees on Dashboard, assigns unit
                   ▼
          ┌──────────────────┐
          │ tasks.unit_id    │
          │ assigned →       │
          │ Worker sees task │
          └────────┬─────────┘
                   │ Worker executes
                   ▼
          ┌──────────────────┐
          │  Start → Pause   │
          │  → Complete      │
          └────────┬─────────┘
                   │ If issue found
                   ▼
          ┌──────────────────┐
          │   reports        │
          └────────┬─────────┘
                   │ Supervisor acknowledge/resolve
                   ▼
          ┌──────────────────┐
          │ delay_analysis   │
          │ turnaround_summary│
          └──────────────────┘
```

### 3.6.2 Report Submission Flow

```
Worker taps "Add Report"
         │
         ▼
┌──────────────────────────┐
│  Select task (optional)  │
│  Enter description       │
│  Select type             │
│  Select severity         │
│  Attach photo (optional) │
└──────────┬───────────────┘
           │ Submit
           ▼
┌──────────────────────────┐
│  Supabase: upload photo  │
│  to report-images bucket │
│  Insert into reports     │
│  table                   │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│  Supervisor dashboard    │
│  → Report appears        │
└──────────────────────────┘
```

### 3.6.3 Supervisor Add Report Flow (Standalone)

```
Supervisor taps FAB on Reports tab
         │
         ▼
┌──────────────────────────┐
│  Select target:          │
│  ┌─────┐   ┌───────┐   │
│  │Admin│   │ Worker │   │
│  │(red)│   │ (blue) │   │
│  └─────┘   └───────┘   │
│  Select type             │
│  Select severity         │
│  Enter description       │
│  Attach photo (optional) │
└──────────┬───────────────┘
           │ Submit
           ▼
┌──────────────────────────┐
│  Insert into reports     │
│  (no task_id/flight_id)  │
│  reported_to = 'admin'   │
│  or 'worker'             │
└──────────────────────────┘
```

---

### 3.6.4 GroundScope Vision Detection Pipeline

```
Stand camera (RTSP)
        │ frames
        ▼
   YOLO11s detect (conf 0.25, iou 0.45, imgsz 640)
        │ per-frame detections
        ▼
   BotSORT tracking (persist track IDs)
        │ first/last seen per unit
        ▼
   Event / dwell builder
        │ writes
        ├────────────▶ stand_events (source=camera, confidence_score, service_type_id)
        └────────────▶ delay_analysis (camera_unit_arrival, camera_unit_departure)
```

> Designed integration — see §6.8. The runtime service is future work.

## 3.7 Data Analysis & Preprocessing

### Database Schema Overview

The database consists of 15 core tables across four functional groups:

**Foundation Tables:**

- `service_types` — Ground service categories (fueling, catering, cleaning, etc.)
- `stands` — Airport parking positions with terminal and aircraft compatibility
- `users` — App users linked to Supabase Auth with role assignment
- `units` — Operational teams/vehicles linked to service types
- `unit_members` — Crew members within a unit (display-only, no login)

**Operations Tables:**

- `flights` — Flight records ingested from AviationStack API or manual entry
- `tasks` — Central operational record tracking full task lifecycle; `unit_id` is nullable — tasks with `unit_id IS NULL` and `status='pending'` represent unassigned service requests visible on the Supervisor Dashboard
- `task_checklists` — Ordered checklist items per task
- `task_pauses` — Pause/resume records with reasons

**Monitoring Tables:**

- `cameras` — Camera devices linked to stands
- `stand_events` — Events detected by cameras

**Reporting & Analytics Tables:**

- `reports` — Incident reports with type, severity, image, and status workflow. Requires a database migration (see §4.2.5) to support standalone supervisor reports with nullable `task_id`/`flight_id` and a `reported_to` column.
- `notifications` — Push notification records per user
- `delay_analysis` — Computed delay metrics per task
- `flight_turnaround_summary` — Aggregated per-flight summary

### Key Relationship: service_type_id

The `service_type_id` column is the central link in the database:

- A supervisor belongs to one service type
- A unit belongs to one service type
- A task belongs to a service type

This single foreign key routes data to the correct supervisor and unit.

### Supervisor Service Request Model

The supervisor dashboard shows service requests as tasks that have been created by the admin with `unit_id IS NULL` and `status = 'pending'`. The supervisor assigns a unit, which updates `tasks.unit_id` and `tasks.assigned_by`. There is no separate `flight_service_requests` table in the current implementation.

---

## 3.8 Algorithms, Models, and Workflow

### 3.8.1 Task Lifecycle State Machine

```
         ┌────────────────────────────────────────────┐
         │              TASK LIFECYCLE                 │
         └────────────────────────────────────────────┘

                    ┌──────────┐
                    │  PENDING │ (initial state)
                    └────┬─────┘
                         │ Supervisor assigns unit
                         │ (unit_id set, status stays pending)
                         │ Worker taps Start
                         ▼
                    ┌──────────┐
           ┌───────│IN_PROGRESS│────────┐
           │       └──────────┘        │
           │ Pause            Complete │
           ▼                           ▼
     ┌─────────┐               ┌───────────┐
     │  PAUSED │               │ COMPLETED │
     └────┬────┘               └───────────┘
          │ Resume                      │
          ▼                             ▼
     ┌──────────┐              ┌────────────────┐
     │IN_PROGRESS│              │ actual_end     │
     └──────────┘              │ timestamp set  │
                                └────────────────┘

     ┌──────────┐
     │CANCELLED │ (alternative end state)
     └──────────┘
```

### 3.8.2 Report Status Workflow

```
┌──────┐    Acknowledge    ┌──────────────┐    Resolve    ┌──────────┐
│ OPEN │ ────────────────→ │ ACKNOWLEDGED │ ────────────→ │ RESOLVED │
└──────┘                   └──────────────┘               └──────────┘
```

### 3.8.3 Realtime Stream Merge Strategy

Supabase `.stream()` does not support joins. The system uses a two-phase strategy:

1. **Initial fetch**: Perform a full query with `.select('*, related(*)')` to get all data with joins
2. **Stream merge**: Incoming stream data contains only the primary table fields. Merge with existing joined data from the Cubit state

```dart
// Initial fetch with joins
final units = await supabase
    .from('units')
    .select('*, unit_members(*)')
    .eq('service_type_id', serviceTypeId);

// Realtime stream (no joins)
_subscription = supabase
    .from('units')
    .stream(primaryKey: ['id'])
    .listen((updates) {
        // Merge stream updates with existing member data
        final merged = updates.map((unit) {
            final existing = state.units.firstWhereOrNull(
                (u) => u.id == unit['id'],
            );
            return unit.copyWith(members: existing?.members);
        }).toList();
        emit(state.copyWith(units: merged));
    });
```

> Note: Use `firstWhereOrNull` from the `collection` package rather than `firstWhere` with `orElse: () => null`, which causes a Dart type error since `firstWhere` requires a non-nullable return type.

### 3.8.4 Sentinel-Object Pattern for Nullable copyWith

When a Cubit state field must be clearable to `null` via `copyWith`, a sentinel-object pattern prevents ambiguity:

```dart
const _clear = Object();

SomeState copyWith({ Object? actionReportId = _clear }) {
  return SomeState(
    actionReportId: identical(actionReportId, _clear)
        ? this.actionReportId
        : actionReportId as String?,
  );
}
```

---

### 3.8.5 Equipment Detection & Tracking (GroundScope Vision)

The vision module turns apron camera frames into operational events in three stages:

1. **Detection** — each frame is passed through the YOLO11s network, producing bounding boxes, class labels (one of 10 equipment types), and confidence scores at three spatial scales (strides 8/16/32).
2. **Tracking** — BotSORT associates detections across frames into stable tracks (`persist=True`), so the same fuel truck is recognised continuously rather than as independent per-frame hits.
3. **Event derivation** — for each track, the first and last frames in which it appears at a stand yield camera-observed arrival and departure times; the equipment class is mapped to a GroundScope service type (§6.3) to produce a `stand_events` record.

This design lets the system compute `app_vs_camera_discrepancy` — the gap between a worker's self-reported task time and the camera-observed time — which is the core of GroundScope's objective delay verification.

---

# Chapter 4: System Design

---

## 4.1 System Architecture

### 4.1.1 Architecture Pattern

GroundScope follows a **Modular Architecture** combined with **MVVM (Model-View-ViewModel)** using the **BLoC (Business Logic Component)** pattern with **Cubits** for state management.

```
┌─────────────────────────────────────────────────────────────┐
│                    GROUNDSCOPE ARCHITECTURE                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Worker   │  │Supervisor│  │  Admin   │  │  Shared  │   │
│  │ Module   │  │ Module   │  │ Module   │  │ Widgets  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────────┘   │
└───────┼───────────────┼────────────┼────────────────────────┘
        │               │            │
┌───────┼───────────────┼────────────┼────────────────────────┐
│       ▼               ▼            ▼                         │
│                   BUSINESS LOGIC LAYER                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Cubits  │  │  States  │  │  Auth    │  │ Settings │   │
│  │(per feat)│  │(part of) │  │  Cubit   │  │  Cubit   │   │
│  └────┬─────┘  └──────────┘  └──────────┘  └──────────┘   │
└───────┼────────────────────────────────────────────────────┘
        │
┌───────┼────────────────────────────────────────────────────┐
│       ▼                                                      │
│                     DATA LAYER                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │   Repos  │  │  Remote  │  │  Models  │                  │
│  │(abstract │  │    DS    │  │  (shared)│                  │
│  │ + impl)  │  │(Supabase)│  │          │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE LAYER                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Supabase │  │ Firebase │  │   Dio    │  │  GetIt   │   │
│  │  Service │  │    FCM   │  │   HTTP   │  │    DI    │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 4.1.2 Module Structure

```
lib/
├── core/                        # Shared infrastructure across all modules
│   ├── api/                     # Dio HTTP client (consumer, interceptors, factory)
│   ├── auth/
│   │   ├── data/                # UserModel, AuthRemoteDs, AuthRepo + Impl
│   │   ├── logic/cubit/         # AuthCubit + AuthState
│   │   └── ui/                  # LoginScreen, UserAuthenticatedCheck, widgets
│   ├── config/                  # AppConfig, FirebaseOptions
│   ├── di/                      # DependencyInjection (GetIt registrations)
│   ├── error/                   # AppError, SupabaseErrorHandler
│   ├── localization/            # LocalizationManager
│   ├── networking/              # SupabaseService
│   ├── onboarding/ui/           # OnBoardingScreen + widgets
│   ├── router/                  # Routes (constants) + AppRouter (switch-case)
│   ├── service/                 # SecureStorage, SharedPrefs, UserService
│   ├── settings/                # AppSettingsCubit + AppSettingsState
│   ├── shared/data/
│   │   ├── models/              # Flight, Report, ServiceType, Task, Unit, etc.
│   │   ├── remote/              # Shared Supabase data sources
│   │   └── repo/                # Shared repository interfaces
│   ├── themes/                  # AppColors, AppTextStyles, CustomColors
│   ├── utils/                   # Spacing, extensions, validators, helpers
│   └── widgets/                 # Reusable UI components
├── modules/
│   ├── worker/                  # Role: unit_manager
│   ├── supervisor/              # Role: supervisor
│   └── admin/                   # Role: admin
├── ground_scope_app.dart
├── main_dev.dart
└── main_prod.dart
```

### 4.1.3 Feature Module Layout

Every feature follows a consistent three-layer structure:

```
feature/
├── data/
│   ├── remote/   # Supabase API calls (FeatureNameRemoteDs)
│   └── repo/     # Abstract interface (FeatureNameRepo) + implementation (FeatureNameRepoImpl)
├── logic/
│   └── cubit/    # FeatureNameCubit + FeatureNameState (state is part of cubit file)
└── ui/
    ├── feature_name_screen.dart   # → FeatureNameScreen widget
    └── widgets/                   # Screen-specific widgets
```

### 4.1.4 Dependency Injection

All services, remote data sources, repositories, and cubits are registered in `lib/core/di/dependency_injection.dart` using GetIt:

- **Singletons** (`registerLazySingleton`): Services (SecureStorage, SupabaseService, UserService), all RemoteDSes, all Repos
- **Factories** (`registerFactory`): All Cubits — a fresh instance on each `getIt<XxxCubit>()` call

```dart
void setupDependencies() {
  // Services
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorageImpl());
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseServiceImpl());
  getIt.registerLazySingleton<UserService>(() => UserServiceImpl());

  // Remote Data Sources
  getIt.registerLazySingleton<HomeRemoteDs>(() => HomeRemoteDsImpl());

  // Repositories
  getIt.registerLazySingleton<HomeRepo>(() => HomeRepoImpl());

  // Cubits (factories)
  getIt.registerFactory<HomeCubit>(() => HomeCubit());
}
```

---

## 4.2 Database Design

### 4.2.1 Entity Relationship Diagram

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

### 4.2.2 Core Tables

#### users

Stores all user accounts across all roles.

| Column          | Type        | Notes                                           |
| --------------- | ----------- | ----------------------------------------------- |
| id              | uuid PK     | Auto-generated                                  |
| auth_id         | uuid FK     | Links to Supabase Auth (auth.users)             |
| full_name       | text        | User's display name                             |
| email           | text UNIQUE | Login email                                     |
| phone           | text        | Optional contact number                         |
| role            | user_role   | `admin` \| `supervisor` \| `unit_manager` |
| service_type_id | uuid FK     | Links supervisor to their service type          |
| unit_id         | uuid FK     | Links unit manager to their unit                |
| fcm_token       | text        | Firebase push notification token                |
| is_active       | boolean     | Soft delete flag                                |
| created_at      | timestamptz | Account creation timestamp                      |

#### service_types

Defines the categories of ground services available.

| Column                   | Type        | Notes                                |
| ------------------------ | ----------- | ------------------------------------ |
| id                       | uuid PK     | Auto-generated                       |
| name                     | text UNIQUE | e.g., Fueling, Catering, Cleaning    |
| description              | text        | Optional description                 |
| default_duration_minutes | integer     | Expected task duration (default: 30) |
| icon                     | text        | Icon identifier for UI               |
| is_active                | boolean     | Soft delete flag                     |
| created_at               | timestamptz | Creation timestamp                   |

#### units

Physical ground service teams or vehicles.

| Column              | Type        | Notes                                    |
| ------------------- | ----------- | ---------------------------------------- |
| id                  | uuid PK     | Auto-generated                           |
| name                | text        | e.g., Fuel Truck 01                      |
| service_type_id     | uuid FK     | Links unit to its service type           |
| status              | unit_status | `available` \| `busy` \| `offline` |
| compatible_aircraft | text[]      | Aircraft types this unit can serve       |
| shift_start_time    | time        | Unit's daily shift start                 |
| shift_end_time      | time        | Unit's daily shift end                   |
| created_at          | timestamptz | Creation timestamp                       |

#### unit_members

Crew members within a unit (display-only, no app login).

| Column      | Type        | Notes                                        |
| ----------- | ----------- | -------------------------------------------- |
| id          | uuid PK     | Auto-generated                               |
| unit_id     | uuid FK     | Links member to their unit                   |
| full_name   | text        | Member's full name                           |
| phone       | text        | Optional contact number                      |
| national_id | text        | Staff identification number                  |
| position    | text        | Job title (driver, technician, helper, etc.) |
| image_url   | text        | Optional profile photo                       |
| is_active   | boolean     | Soft delete flag                             |
| created_at  | timestamptz | Creation timestamp                           |

#### stands

Airport parking positions.

| Column              | Type        | Notes                              |
| ------------------- | ----------- | ---------------------------------- |
| id                  | uuid PK     | Auto-generated                     |
| code                | text UNIQUE | Stand code (e.g., A12, B05)        |
| terminal            | text        | Terminal identifier                |
| compatible_aircraft | text[]      | Aircraft types that fit this stand |
| has_camera          | boolean     | Whether a camera is installed      |
| is_active           | boolean     | Soft delete flag                   |
| created_at          | timestamptz | Creation timestamp                 |

#### flights

Flight records from AviationStack API or manual entry.

| Column                | Type          | Notes                                                         |
| --------------------- | ------------- | ------------------------------------------------------------- |
| id                    | uuid PK       | Auto-generated                                                |
| flight_number         | text          | e.g., EK203                                                   |
| airline               | text          | Airline name or IATA code                                     |
| origin                | text          | Departure airport IATA code                                   |
| destination           | text          | Arrival airport IATA code                                     |
| aircraft_type         | text          | Aircraft model (e.g., B777)                                   |
| aircraft_registration | text          | Tail number                                                   |
| scheduled_arrival     | timestamptz   | Planned arrival time                                          |
| estimated_arrival     | timestamptz   | Updated estimate from API                                     |
| actual_arrival        | timestamptz   | Real arrival time                                             |
| scheduled_departure   | timestamptz   | Planned departure time                                        |
| actual_departure      | timestamptz   | Real departure time                                           |
| stand_id              | uuid FK       | Assigned parking stand                                        |
| status                | flight_status | `scheduled` \| `arrived` \| `departed` \| `cancelled` |
| pax_count             | integer       | Passenger count                                               |
| api_source            | text          | Source system name                                            |
| external_id           | text          | ID from external API                                          |
| raw_data              | jsonb         | Full raw API payload                                          |
| created_at            | timestamptz   | Record creation timestamp                                     |
| updated_at            | timestamptz   | Last update timestamp                                         |

#### tasks

The central operational record. Tasks with `unit_id IS NULL` and `status = 'pending'` represent unassigned service requests visible on the Supervisor Dashboard.

| Column          | Type          | Notes                                                                          |
| --------------- | ------------- | ------------------------------------------------------------------------------ |
| id              | uuid PK       | Auto-generated                                                                 |
| flight_id       | uuid FK       | Which flight this task serves                                                  |
| service_type_id | uuid FK       | Which service type                                                             |
| unit_id         | uuid FK       | Nullable — assigned unit (NULL = unassigned)                                  |
| assigned_by     | uuid FK       | Supervisor who assigned the unit                                               |
| created_by      | uuid FK       | Who created the task                                                           |
| status          | task_status   | `pending` \| `in_progress` \| `paused` \| `completed` \| `cancelled` |
| priority        | task_priority | `low` \| `medium` \| `high`                                              |
| scheduled_start | timestamptz   | When the task should begin                                                     |
| scheduled_end   | timestamptz   | When the task should finish                                                    |
| actual_start    | timestamptz   | When unit manager tapped Start                                                 |
| actual_end      | timestamptz   | When unit manager tapped Complete                                              |
| notes           | text          | Supervisor notes for the unit                                                  |
| created_at      | timestamptz   | Task creation                                                                  |
| updated_at      | timestamptz   | Last modification                                                              |

#### reports

Incident or issue reports. The base schema has `task_id` and `flight_id` as NOT NULL. The migration in §4.2.5 makes them nullable to support standalone supervisor reports.

| Column          | Type            | Notes                                             |
| --------------- | --------------- | ------------------------------------------------- |
| id              | uuid PK         | Auto-generated                                    |
| task_id         | uuid FK         | Nullable after migration — associated task       |
| flight_id       | uuid FK         | Nullable after migration — associated flight     |
| reported_by     | uuid FK         | Who filed the report                              |
| type            | report_type     | Category of report                                |
| description     | text            | Detailed description                              |
| severity        | report_severity | `low` \| `medium` \| `high` \| `critical` |
| status          | report_status   | `open` \| `acknowledged` \| `resolved`      |
| image_url       | text            | Attached photo URL                                |
| reported_to     | text            | Added by migration:`admin` \| `worker`        |
| acknowledged_by | uuid FK         | Who acknowledged                                  |
| acknowledged_at | timestamptz     | When acknowledged                                 |
| resolved_by     | uuid FK         | Who resolved                                      |
| resolved_at     | timestamptz     | When resolved                                     |
| created_at      | timestamptz     | Record creation                                   |

### 4.2.3 Enums

| Enum              | Values                                                                 |
| ----------------- | ---------------------------------------------------------------------- |
| `user_role`     | `admin`, `supervisor`, `unit_manager`                            |
| `unit_status`   | `available`, `busy`, `offline`                                   |
| `flight_status` | `scheduled`, `arrived`, `departed`, `cancelled`                |
| `task_status`   | `pending`, `in_progress`, `paused`, `completed`, `cancelled` |
| `task_priority` | `low`, `medium`, `high`                                          |
| `report_status` | `open`, `acknowledged`, `resolved`                               |
| `event_source`  | `camera`, `manual`                                                 |

> Note: `task_status` includes `paused` as a valid value used in the task lifecycle state machine and UI badge coloring, even though it is not listed in the DATABASE.md enums section — verify against the live Supabase enum definition before deployment.

### 4.2.4 Row Level Security (RLS) Policies

Supabase RLS enforces role-based data access at the database level:

**Supervisor policies:**

- Can SELECT only flights whose tasks match their `service_type_id`
- Can SELECT only units belonging to their `service_type_id`
- Can SELECT only tasks belonging to their `service_type_id`
- Can SELECT only reports submitted by their units

**Unit Manager policies:**

- Can SELECT only tasks assigned to their specific `unit_id`
- Can SELECT only their own unit info and crew members
- Can INSERT reports (their own)
- Can SELECT only their own reports

### 4.2.5 Required Database Migration

To support the Supervisor Add Report feature, run this migration once in Supabase:

```sql
ALTER TABLE reports ALTER COLUMN task_id DROP NOT NULL;
ALTER TABLE reports ALTER COLUMN flight_id DROP NOT NULL;
ALTER TABLE reports ADD COLUMN IF NOT EXISTS reported_to TEXT;
```

---

### 4.2.6 Tables Populated by GroundScope Vision

Three existing tables are designed to receive camera-derived data from the vision module (see §6.8 for the full mapping):

| Table              | Columns populated by vision                                                       |
| ------------------ | --------------------------------------------------------------------------------- |
| `cameras`        | `stream_url`, `identifier`, `last_ping` (the feed source per stand)         |
| `stand_events`   | `event_type`, `source = 'camera'`, `confidence_score`, `service_type_id`  |
| `delay_analysis` | `camera_unit_arrival`, `camera_unit_departure`, `app_vs_camera_discrepancy` |

The schema therefore already anticipates the vision layer; no migration is required to store its output. The `event_source` enum's `camera` value and the `confidence_score` column exist specifically for this purpose.

## 4.3 UI/UX Design

### 4.3.1 Design System

GroundScope uses a comprehensive design system. Key specifications:

#### Canvas & Sizing

| Property        | Value                                            |
| --------------- | ------------------------------------------------ |
| Base canvas     | 390 × 844                                       |
| Sizing system   | `flutter_screenutil`                           |
| Width           | `rw(n)` → `n.w`                             |
| Height          | `rh(n)` → `n.h`                             |
| Radius          | `rr(n)` → `n.r`                             |
| Font size       | `rf(n)` → `n.sp`                            |
| Spacing widgets | `verticalSpacing(n)`, `horizontalSpacing(n)` |

#### Color Palette (AppColors)

**Primary (Blue):**

| Constant   | Hex            |
| ---------- | -------------- |
| primary50  | #D5EDF7        |
| primary100 | #82CAE7        |
| primary200 | #2FA4D7 (main) |
| primary300 | #247DA4        |
| primary400 | #18526C        |

**Secondary (Pink/Red):**

| Constant     | Hex            |
| ------------ | -------------- |
| secondary200 | #D12052 (main) |

**Neutral:**
grey50 through grey800, white (#FFFFFF), black (#000000)

**Semantic:**
green200 (#22C55E), red200 (#EF4444), amber200 (#F59E0B), blue200 (#3B82F6)

**Gradient:**

```dart
AppColors.primaryGradient
// LinearGradient: topLeft→bottomRight, stops: [primary100, primary200, primary300]
```

#### Semantic Tokens (CustomColors)

Access via `context.customColors` (theme-aware light/dark):

| Token         | Light           | Dark           |
| ------------- | --------------- | -------------- |
| textPrimary   | black           | white          |
| textSecondary | grey600         | grey300        |
| textHint      | grey400         | grey500        |
| textDisabled  | grey300         | grey600        |
| background    | backgroundLight | backgroundDark |
| surface       | white           | grey800        |
| border        | grey200         | grey600        |
| divider       | grey100         | grey700        |

#### Typography (AppTextStyles)

All styles have **no color** — apply via `.copyWith(color: ...)` at call site:

| Constant        | Size | Weight |
| --------------- | ---- | ------ |
| font24ExtraBold | 24   | w800   |
| font24SemiBold  | 24   | w600   |
| font24Light     | 24   | w300   |
| font22ExtraBold | 22   | w800   |
| font20ExtraBold | 20   | w800   |
| font20SemiBold  | 20   | w600   |
| font18ExtraBold | 18   | w800   |
| font18SemiBold  | 18   | w600   |
| font16ExtraBold | 16   | w800   |
| font16SemiBold  | 16   | w600   |
| font16Light     | 16   | w300   |
| font14ExtraBold | 14   | w800   |
| font14SemiBold  | 14   | w600   |
| font14Light     | 14   | w300   |
| font12ExtraBold | 12   | w800   |
| font12SemiBold  | 12   | w600   |
| font12Light     | 12   | w300   |

**Usage:**

- Screen titles: font24ExtraBold, font22ExtraBold
- App bar title: font18SemiBold
- Card headings: font18ExtraBold, font16SemiBold
- Body: font16Light, font14Light
- Captions: font12Light
- Buttons: font16ExtraBold (medium/large), font14ExtraBold (small)

### 4.3.2 Core UI Components

#### CustomAppBar

- Back button: `Icons.arrow_back_ios_new` → `context.pop()`
- Title: centered, font18SemiBold
- Padding: horizontal rw(16), vertical rh(24)
- Layout: [back icon] [Spacer] [title] [Spacer] [optional trailing]

#### CustomTextButton

Three constructors: `.filled()`, `.outlined()`, `.text()`

| Size   | Height | Padding H | Text style      |
| ------ | ------ | --------- | --------------- |
| small  | 40     | 16        | font14ExtraBold |
| medium | 52     | 24        | font16ExtraBold |
| large  | 56     | 24        | font16ExtraBold |

- Border radius: rr(12), Elevation: 0
- Loading: CircularProgressIndicator 22×22

#### CustomTextForm

- Border radius: rr(12)
- Input style: font16Light, textPrimary
- Hint style: font16Light, textHint
- Border states: default (border) / focused (primary50) / error (red200) / disabled (border at 0.4)

#### InfoCard + InfoRowData

- Card: surface, radius rr(14), border border at 0.5
- Row padding: rw(14) h, rh(12) v
- Icon container: rw(32)×rw(32), radius rr(8), bg primary200 at 0.08
- Label: font12Light, textHint
- Value: font12SemiBold

#### FilterPills

- Selected: bg primary200, text white
- Unselected: bg surfaceVariant, border border, text textSecondary
- Padding: rw(14) h, rh(6) v, Radius: rr(20), Text: font12SemiBold
- Animation: 200ms

#### Card Spec

```dart
Container(
  margin: EdgeInsets.only(bottom: rh(12)),
  decoration: BoxDecoration(
    color: cc.surface,
    borderRadius: BorderRadius.circular(rr(16)),
    border: Border.all(color: cc.border.withValues(alpha: 0.6)),
    boxShadow: [BoxShadow(color: black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0,2))],
  ),
)
```

#### Badge Color Coding

**Task Priority Colors:**

| Priority | Color        |
| -------- | ------------ |
| critical | red200       |
| high     | secondary200 |
| medium   | amber200     |
| low      | green200     |

**Task Status Colors:**

| Status     | Color        |
| ---------- | ------------ |
| inProgress | primary200   |
| completed  | green200     |
| pending    | amber200     |
| assigned   | blue200      |
| paused     | secondary200 |
| cancelled  | textDisabled |

**Report Severity Colors:**

| Severity | Color        |
| -------- | ------------ |
| low      | green200     |
| medium   | amber200     |
| high     | secondary200 |
| critical | red200       |

### 4.3.3 Role-Specific Navigation

#### Worker Module (5 tabs, PersistentTabView)

| Tab | Feature              | Cubit          |
| --- | -------------------- | -------------- |
| 0   | Home (task list)     | HomeCubit      |
| 1   | Reports (my reports) | ReportsCubit   |
| 2   | Add Report           | AddReportCubit |
| 3   | Notifications        | —             |
| 4   | Profile              | ProfileCubit   |

**Pushed routes:** taskDetailsScreen, taskDetailsInfoScreen, addReportScreen, reportsScreen, reportsDetailsScreen, workerManagerAndMembersScreen, workerMemberDetailScreen

**Key note:** AddReportScreen is both tab 2 (not poppable) and a pushed route — guard all back-nav with `Navigator.canPop(context)`.

#### Supervisor Module (5 tabs, IndexedStack + BottomNavigationBar)

| Tab | Feature   | Screen                    | Cubit                            |
| --- | --------- | ------------------------- | -------------------------------- |
| 0   | Dashboard | SupervisorDashboardScreen | DashboardCubit + AssignUnitCubit |
| 1   | Tasks     | SupervisorTasksScreen     | SupervisorTasksCubit             |
| 2   | Units     | SupervisorUnitsScreen     | SupervisorUnitsCubit             |
| 3   | Reports   | SupervisorReportsScreen   | SupervisorReportsCubit           |
| 4   | Profile   | SupervisorProfileScreen   | SupervisorProfileCubit           |

All 5 cubits are provided via MultiBlocProvider in UserAuthenticatedCheck (not the Scaffold).

#### Admin Module (Dashboard + Feature Cards)

| Feature          | Routes                                                       | Cubits                                                          |
| ---------------- | ------------------------------------------------------------ | --------------------------------------------------------------- |
| Dashboard        | adminDashboardScreen                                         | AdminDashboardCubit                                             |
| Flights          | adminFlightsScreen, adminFlightDetailScreen                  | FlightsListCubit, FlightImportCubit                             |
| Service Types    | adminServiceTypesScreen, adminServiceTypeFormScreen          | ServiceTypesListCubit, ServiceTypeFormCubit                     |
| Stands           | adminStandsScreen, adminStandFormScreen                      | StandsListCubit, StandFormCubit                                 |
| Units            | adminUnitsScreen, adminUnitDetailScreen, adminUnitFormScreen | UnitsListCubit, UnitDetailCubit, UnitFormCubit, UnitMemberCubit |
| Users            | adminUsersScreen                                             | UsersListCubit, UserResetCubit                                  |
| Service Requests | adminFlightServiceRequestScreen                              | ServiceRequestCubit                                             |

### 4.3.4 Navigation System

All navigation uses named route constants:

```dart
class Routes {
  // Auth
  static const onBoardingScreen   = '/onBoardingScreen';
  static const loginScreen        = '/loginScreen';

  // Worker
  static const workerScaffold                = '/workerScaffold';
  static const taskDetailsScreen             = '/taskDetailsScreen';
  static const taskDetailsInfoScreen         = '/taskDetailsInfoScreen';
  static const addReportScreen               = '/addReportScreen';
  static const reportsScreen                 = '/reportsScreen';
  static const reportsDetailsScreen          = '/reportsDetailsScreen';
  static const workerManagerAndMembersScreen = '/workerManagerAndMembersScreen';
  static const workerMemberDetailScreen      = '/workerMemberDetailScreen';

  // Supervisor
  static const supervisorScaffold            = '/supervisorScaffold';
  static const supervisorTaskListScreen      = '/supervisorTaskListScreen';

  // Admin
  static const adminDashboardScreen          = '/adminDashboardScreen';
  static const adminUnitsScreen              = '/adminUnitsScreen';
  static const adminUnitDetailScreen         = '/adminUnitDetailScreen';
  static const adminUnitFormScreen           = '/adminUnitFormScreen';
  static const adminServiceTypesScreen       = '/adminServiceTypesScreen';
  static const adminServiceTypeFormScreen    = '/adminServiceTypeFormScreen';
  static const adminStandsScreen             = '/adminStandsScreen';
  static const adminStandFormScreen          = '/adminStandFormScreen';
  static const adminFlightsScreen            = '/adminFlightsScreen';
  static const adminFlightDetailScreen       = '/adminFlightDetailScreen';
  static const adminUsersScreen              = '/adminUsersScreen';
  static const adminFlightServiceRequestScreen = '/adminFlightServiceRequestScreen';
}
```

Route switching is handled by `AppRouter.generateRoute()` using a switch-case pattern.

---

## 4.4 Web Dashboard Architecture

### 4.4.1 App Router & Route Layout

The dashboard uses the Next.js 14 **App Router** with two route groups under `src/app/[locale]/`:

| Group           | Prefix              | Purpose                       |
| --------------- | ------------------- | ----------------------------- |
| `(auth)`      | `/[locale]/login` | Unauthenticated pages         |
| `(dashboard)` | `/[locale]/*`     | All authenticated admin pages |

All routes are locale-prefixed (`localePrefix: "always"`), so `/` redirects to `/en` and `/ar/flights` is the Arabic version of the flights screen. Supported locales: `en`, `ar`.

**Route table:**

| URL Pattern                 | Description                                                                |
| --------------------------- | -------------------------------------------------------------------------- |
| `/[locale]/login`         | Email / password sign-in                                                   |
| `/[locale]/`              | Overview dashboard — real-time stat cards + recent flights + open reports |
| `/[locale]/operations`    | Live Kanban board (pending / in_progress / completed)                      |
| `/[locale]/flights`       | Flights list with AviationStack import                                     |
| `/[locale]/flights/[id]`  | Flight detail + service requests                                           |
| `/[locale]/reports`       | Incident reports list with filter and CSV export                           |
| `/[locale]/reports/[id]`  | Report detail + acknowledge / resolve workflow                             |
| `/[locale]/analytics`     | Delay analysis, turnaround summary, unit performance                       |
| `/[locale]/service-types` | Service types CRUD                                                         |
| `/[locale]/stands`        | Airport stands CRUD                                                        |
| `/[locale]/units`         | Ground units list                                                          |
| `/[locale]/units/[id]`    | Unit detail + members                                                      |
| `/[locale]/users`         | Supervisors & unit managers                                                |

### 4.4.2 Supabase Client Strategy

Two Supabase clients are used. Using the wrong client causes session-cookie mismatches or missing data under RLS:

| Client         | File                       | Usage                                                                                                 |
| -------------- | -------------------------- | ----------------------------------------------------------------------------------------------------- |
| Server client  | `lib/supabase/server.ts` | Server Components, Route Handlers, Server Actions — reads/writes session via`next/headers` cookies |
| Browser client | `lib/supabase/client.ts` | Client Components that need Realtime or interactive mutations after page load                         |

### 4.4.3 Middleware

`src/middleware.ts` runs on every non-static request and performs two tasks in sequence:

1. **Locale routing** — delegates to `next-intl/middleware` with locales `["en", "ar"]`, default `"en"`, always-prefix strategy
2. **Session refresh** — calls `supabase.auth.getUser()` and writes any rotated tokens back to the response cookies, preventing silent JWT expiry that would cause RLS to return empty result sets

### 4.4.4 Authentication Flow

1. Admin submits email and password on `/[locale]/login`
2. `signInWithPassword()` calls `supabase.auth.signInWithPassword()`
3. On success, the system fetches the `users` row matched by `auth_id` and verifies `role === "admin"`
4. If the role check fails, `supabase.auth.signOut()` is called immediately and an error is returned — supervisors and unit managers cannot access the web dashboard
5. On success, the session cookie is written and the browser navigates to the overview dashboard

### 4.4.5 API Routes

Two server-side API routes handle operations that require secret keys never exposed to the browser:

| Route                        | Purpose                                                                                                                                         |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `POST /api/create-user`    | Creates a Supabase Auth user using the service role key (bypasses RLS), then inserts a row into the`users` table with the assigned role       |
| `POST /api/import-flights` | Fetches up to 100 arrivals and 100 departures for IATA code`CAI` from AviationStack and upserts into the `flights` table on `external_id` |

### 4.4.6 Realtime Subscriptions

The overview dashboard maintains two Supabase Realtime `postgres_changes` subscriptions:

| Channel              | Table Watched | Effect                                                 |
| -------------------- | ------------- | ------------------------------------------------------ |
| `tasks-realtime`   | `tasks`     | Re-fetches active task count and pending request count |
| `reports-realtime` | `reports`   | Re-fetches open report count and recent reports list   |

Realtime payloads do not carry joined data. On every change event the dashboard re-calls server-action query helpers to keep stat cards consistent with full joins intact.

---

## 4.5 Web Dashboard UI/UX Design

### 4.5.1 Design System & Tokens

All colors are CSS custom properties defined in `src/app/globals.css` and mapped to Tailwind utility classes. No hardcoded hex values are used in components — the token system is how dark mode works automatically.

**Brand palette (invariant across light/dark):**

| Token               | Value       | Role                                      |
| ------------------- | ----------- | ----------------------------------------- |
| `--primary-200`   | `#2fa4d7` | Primary actions, active nav, links        |
| `--primary-300`   | `#247da4` | Hover state for primary                   |
| `--secondary-200` | `#d12052` | Destructive / high-priority indicators    |
| `--success`       | `#22c55e` | Completed, available, low severity        |
| `--warning`       | `#f59e0b` | Pending, medium severity, busy units      |
| `--error`         | `#ef4444` | Cancelled, critical severity, open issues |
| `--info`          | `#3b82f6` | Scheduled flights, acknowledged reports   |

**Surface tokens (swap automatically between light and dark):**

| Token                | Light       | Dark        |
| -------------------- | ----------- | ----------- |
| `--background`     | `#f9fafb` | `#121212` |
| `--surface`        | `#ffffff` | `#262730` |
| `--text-primary`   | `#000000` | `#ffffff` |
| `--text-secondary` | `#36394a` | `#a4acb9` |

**Border radius tokens:**

| Token                | Value    | Usage                      |
| -------------------- | -------- | -------------------------- |
| `--radius-card`    | `16px` | Card containers            |
| `--radius-control` | `12px` | Inputs, buttons, nav items |
| `--radius-chip`    | `8px`  | Badges, tags               |

### 4.5.2 Layout Shell

The dashboard shell is composed of four components:

```
DashboardShell (client — owns drawer open/close state)
├── Sidebar          permanent flex column at lg+ (≥ 1024px); hidden below
├── MobileDrawer     slide-in panel; visible below lg; body-scroll locked when open
└── Content column   flex-1, min-w-0
    ├── Topbar        h-16; hamburger (mobile); page title; theme + locale toggles
    └── <main>        p-4 sm:p-6 lg:p-8
```

Navigation is grouped into **Main** (Overview, Operations, Flights, Reports, Analytics) and **Master Data** (Service Types, Stands, Units, Users). The active item is highlighted with a spring-animated rail via Framer Motion and `text-primary-200 bg-primary-200/10`. The rail uses `start-0` so it appears on the correct side in both LTR and RTL layouts.

### 4.5.3 Primitive Components

All shared UI primitives live in `src/components/ui/`:

| Component                                | Description                                                       |
| ---------------------------------------- | ----------------------------------------------------------------- |
| `Badge`                                | Inline status chip with tone, background, border, and dot props   |
| `Button`                               | Themed button with size and variant props                         |
| `Card` / `CardBody` / `CardHeader` | Surface container with optional accent stripe                     |
| `ConfirmDialog`                        | Modal confirmation required before every destructive action       |
| `DataTable`                            | TanStack Table v8 wrapper; horizontally scrollable on mobile      |
| `EmptyState`                           | Illustrated empty list placeholder                                |
| `FilterPills`                          | Multi-select pill group for filter UIs                            |
| `PageHeader`                           | Screen title with optional description and icon                   |
| `SlideOverSheet`                       | Right-side panel for create/edit forms                            |
| `StatCard`                             | KPI card with icon, tone, and animated value                      |
| `TagInput`                             | Free-form tag entry for array columns (e.g., compatible aircraft) |

### 4.5.4 Theming & Internationalisation

`next-themes` manages light/dark mode using the `.dark` class strategy on the `<html>` element. The selected preference is persisted in `localStorage` across sessions.

`next-intl` v4 handles all i18n with locales `["en", "ar"]`, default `"en"`, and always-prefix URL strategy. The `<html>` element's `dir` attribute is set to `ltr` for English and `rtl` for Arabic. All layout uses CSS logical properties (`ms-`, `me-`, `ps-`, `pe-`, `start-`, `end-`) — never `left` or `right` — ensuring full RTL support without conditional classes.

### 4.5.5 Responsiveness

| Width             | Layout                                                                                |
| ----------------- | ------------------------------------------------------------------------------------- |
| 375 px (phone)    | Mobile drawer, stacked single-column grids, horizontally scrollable tables and Kanban |
| 768 px (tablet)   | Two-column grids, Kanban switches to three columns                                    |
| 1280 px (desktop) | Permanent sidebar, full three-column layouts                                          |

---

# Chapter 5: Implementation

---

## 5.1 Technology Stack

### 5.1.1 Packages and Versions

| Category             | Package                   | Version  | Purpose                                    |
| -------------------- | ------------------------- | -------- | ------------------------------------------ |
| State Management     | flutter_bloc              | ^9.1.1   | BLoC/Cubit pattern for reactive state      |
| Persistent State     | hydrated_bloc             | ^11.0.0  | Persisted Cubit state across app restarts  |
| Dependency Injection | get_it                    | ^9.0.5   | Service locator for DI                     |
| Backend Client       | supabase_flutter          | ^2.10.3  | Supabase database, auth, storage, realtime |
| Firebase Core        | firebase_core             | ^4.2.1   | Firebase initialization and FCM            |
| Responsive Sizing    | flutter_screenutil        | ^5.9.3   | Adaptive sizing (rw/rh/rr/rf)              |
| Navigation           | persistent_bottom_nav_bar | ^6.2.1   | Persistent tab navigation                  |
| Localization         | easy_localization         | ^3.0.8   | Internationalization (EN/AR)               |
| Environment          | flutter_dotenv            | ^6.0.0   | Environment variable management            |
| Secure Storage       | flutter_secure_storage    | ^10.0.0  | Encrypted token storage                    |
| SVG Rendering        | flutter_svg               | ^2.2.2   | SVG asset rendering                        |
| Image Caching        | cached_network_image      | ^3.4.1   | Network image caching                      |
| Animations           | flutter_animate           | ^4.5.2   | Declarative animation framework            |
| Equality             | equatable                 | ^2.0.8   | Value equality for Dart objects            |
| Image Picking        | image_picker              | (latest) | Camera/gallery photo capture               |

### 5.1.2 Fonts

- **English (default):** Manrope — 7 weights (Light through ExtraBold)
- **Arabic:** Tajawal — for RTL text rendering

### 5.1.3 Design Canvas

All UI is designed for a base canvas of **390 × 844 pixels** and adapted using flutter_screenutil helpers:

- `rw(n)` → responsive width
- `rh(n)` → responsive height
- `rr(n)` → responsive radius
- `rf(n)` → responsive font size

---

### 5.1.4 Computer Vision Stack (GroundScope Vision)

| Component       | Technology          | Purpose                                 |
| --------------- | ------------------- | --------------------------------------- |
| Detection model | Ultralytics YOLO11s | Ground service equipment detection      |
| Tracking        | BotSORT             | Cross-frame track IDs for dwell-time    |
| Runtime         | Python 3.9, PyTorch | Model loading and inference             |
| Vision I/O      | OpenCV              | Frame capture and annotation            |
| Export          | ONNX Runtime        | Faster/edge inference (verified export) |

The full model reference (architecture, training arguments, inference recipes, and known issues) is provided in **Appendix A**.

## 5.2 Module Breakdown

### 5.2.1 Worker Module (`lib/modules/worker/`)

**Role key:** `unit_manager`

**Navigation:** WorkerScaffold uses `PersistentTabView` with 5 tabs:

| Tab | Feature       | Cubit              | Description                                  |
| --- | ------------- | ------------------ | -------------------------------------------- |
| 0   | Home          | `HomeCubit`      | Task list with status filter chips           |
| 1   | Reports       | `ReportsCubit`   | Submitted reports with filter strip          |
| 2   | Add Report    | `AddReportCubit` | Report submission form (also a pushed route) |
| 3   | Notifications | —                 | Push notification inbox                      |
| 4   | Profile       | `ProfileCubit`   | Unit info, crew members, settings            |

**Pushed routes:** taskDetailsScreen, taskDetailsInfoScreen, addReportScreen, reportsScreen, reportsDetailsScreen, workerManagerAndMembersScreen, workerMemberDetailScreen

**Key design decision:** AddReportScreen is both a tab (not poppable) and a pushed route. All back navigation is guarded with `Navigator.canPop(context)` to prevent accidentally closing the app.

**Localization namespaces:**

| Namespace                 | Coverage                                                |
| ------------------------- | ------------------------------------------------------- |
| `worker_home.*`         | Greeting, "On Shift", filter chips, empty states        |
| `worker_add_report.*`   | Form labels, image picker, task selector, success/error |
| `worker_reports.*`      | App bar, filters, empty states, detail row labels       |
| `worker_task_details.*` | Header, meta, checklist, pause history, action buttons  |

### 5.2.2 Supervisor Module (`lib/modules/supervisor/`)

**Role key:** `supervisor`

**Navigation:** IndexedStack + BottomNavigationBar with 5 tabs.
Tab state managed by `SupervisorNavCubit`.

| Tab | Feature   | Screen                    | Cubit                            |
| --- | --------- | ------------------------- | -------------------------------- |
| 0   | Dashboard | SupervisorDashboardScreen | DashboardCubit + AssignUnitCubit |
| 1   | Tasks     | SupervisorTasksScreen     | SupervisorTasksCubit             |
| 2   | Units     | SupervisorUnitsScreen     | SupervisorUnitsCubit             |
| 3   | Reports   | SupervisorReportsScreen   | SupervisorReportsCubit           |
| 4   | Profile   | SupervisorProfileScreen   | SupervisorProfileCubit           |

All 5 cubits are provided via `MultiBlocProvider` in `UserAuthenticatedCheck` (not the Scaffold).

#### Supervisor Add Report Feature

Full data/logic/ui feature at `lib/modules/supervisor/features/add_report/`:

```
add_report/
├── data/
│   ├── remote/supervisor_add_report_remote_ds.dart
│   └── repo/
│       ├── supervisor_add_report_repo.dart             # Abstract interface
│       └── supervisor_add_report_repo_impl.dart        # Delegates to remote DS
├── logic/cubit/
│   ├── supervisor_add_report_cubit.dart                # selectTarget, selectType, selectSeverity, pickImage, removeImage, submit, resetForm
│   └── supervisor_add_report_state.dart                # SupervisorAddReportStatus enum + state
└── ui/
    └── supervisor_add_report_screen.dart               # Full form screen
```

**Key design decisions:**

- `reportedTo: 'admin' | 'worker'` — animated two-card selector
- Admin card = AppColors.secondary200 (red); Worker card = AppColors.primary200 (blue)
- No `task_id` or `flight_id` in the insert — standalone reports
- Requires DB migration (§4.2.5) for nullable task_id/flight_id and new reported_to column
- Image picker widgets self-contained inline in the screen

**DI registration:**

```dart
getIt.registerLazySingleton<SupervisorAddReportRemoteDs>(() => SupervisorAddReportRemoteDsImpl());
getIt.registerLazySingleton<SupervisorAddReportRepo>(() => SupervisorAddReportRepoImpl());
getIt.registerFactory<SupervisorAddReportCubit>(() => SupervisorAddReportCubit());
```

#### Supervisor Feature Details

**Dashboard:**

- Stats grid: active tasks, pending requests, units available
- Service requests section: lists tasks with `status='pending'` and `unit_id IS NULL`
- Assign unit flow: `AssignUnitBottomSheet` → updates `tasks.unit_id`, `tasks.assigned_by`

**Tasks Tab:**

- Realtime + manual refresh; FilterPills + SearchWithCounter
- Filters: all, pending, in_progress, completed, cancelled
- Card: left accent bar (rw(4)) colored by status; priority badge; wrapped in IntrinsicHeight

**Units Tab:**

- Realtime stream (SupervisorUnitsCubit._subscription); no RefreshIndicator
- Stream doesn't support joins → initial fetch gets members, stream merges with existing data
- UnitStatusCard → UnitDetailBottomSheet (shift, service type, compatible aircraft, crew list)
- `_subscription?.cancel()` in cubit.close()

**Reports Tab:**

- FilterPills: all, open, acknowledged, resolved
- Optimistic updates on acknowledge/resolve — changes local state immediately
- Per-card loading spinner via `actionReportId: String?` in state
- `actionReportId` uses sentinel-object pattern in copyWith for nullable clearing
- AppDialogs.showConfirm required before all actions
- Top accent bar (rh(4)) colored by severity
- FAB navigates to SupervisorAddReportScreen

**Profile Tab:**

- Reads from UserService.getUser() — cache only, no network call
- Header: gradient matching dashboard, avatar with initials (max 2 letters)
- Settings: language (switchLanguage), dark mode (switchTheme), notifications (no-op), logout

### 5.2.3 Admin Module (`lib/modules/admin/`)

**Role key:** `admin`

**Navigation:** Single AdminDashboardScreen with feature cards that push named routes.

| Feature          | Routes                                                       | Cubits                                                          |
| ---------------- | ------------------------------------------------------------ | --------------------------------------------------------------- |
| Dashboard        | adminDashboardScreen                                         | AdminDashboardCubit                                             |
| Flights          | adminFlightsScreen, adminFlightDetailScreen                  | FlightsListCubit, FlightImportCubit                             |
| Service Types    | adminServiceTypesScreen, adminServiceTypeFormScreen          | ServiceTypesListCubit, ServiceTypeFormCubit                     |
| Stands           | adminStandsScreen, adminStandFormScreen                      | StandsListCubit, StandFormCubit                                 |
| Units            | adminUnitsScreen, adminUnitDetailScreen, adminUnitFormScreen | UnitsListCubit, UnitDetailCubit, UnitFormCubit, UnitMemberCubit |
| Users            | adminUsersScreen                                             | UsersListCubit, UserResetCubit                                  |
| Service Requests | adminFlightServiceRequestScreen                              | ServiceRequestCubit                                             |

---

## 5.3 Core Components

### 5.3.1 Dependency Injection (GetIt)

All services, remote data sources, repositories, and cubits are registered in `lib/core/di/dependency_injection.dart`:

```dart
void setupDependencies() {
  // ── Services (Singletons) ──
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorageImpl());
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseServiceImpl());
  getIt.registerLazySingleton<UserService>(() => UserServiceImpl());

  // ── Remote Data Sources (Singletons) ──
  getIt.registerLazySingleton<AuthRemoteDs>(() => AuthRemoteDsImpl());
  getIt.registerLazySingleton<HomeRemoteDs>(() => HomeRemoteDsImpl());
  // ... all feature remote DSes

  // ── Repositories (Singletons) ──
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepoImpl());
  getIt.registerLazySingleton<HomeRepo>(() => HomeRepoImpl());
  // ... all feature repos

  // ── Cubits (Factories) ──
  getIt.registerFactory<AuthCubit>(() => AuthCubit());
  getIt.registerFactory<HomeCubit>(() => HomeCubit());
  // ... all feature cubits
}
```

**Rules:**

- Services, RemoteDS, Repo → `registerLazySingleton` (same instance throughout app lifecycle)
- Cubits → `registerFactory` (fresh instance per `getIt<XxxCubit>()` call)

### 5.3.2 Router

All navigation uses named route constants defined in `lib/core/router/routes.dart`. Route switching is handled by `AppRouter.generateRoute()` using a switch-case pattern. Cubits are provided at the route level in the router, not inside screen widgets.

### 5.3.3 State Handling Patterns

**Pattern A — Status enum:**

```dart
loading/initial → CircularProgressIndicator(color: AppColors.primary200)
failure         → cloud_off icon + error message + retry TextButton
empty           → EmptyState widget
loaded          → RefreshIndicator(color: primary200) + ListView
```

**Pattern B — Sealed states:**

```dart
Loading → CircularProgressIndicator
Failure → font14Light text, red300
Loaded  → RefreshIndicator + content
```

Error text: always `state.error?.messageKey` — never hardcoded.

### 5.3.4 Error Handling

```dart
try {
  final result = await repo.someCall();
  emit(state.copyWith(status: MyStatus.success, data: result));
} on AppError catch (e) {
  emit(state.copyWith(status: MyStatus.failure, error: e));
} catch (e) {
  // Always use SupabaseErrorHandler — never swallow with catch (_)
  emit(state.copyWith(
    status: MyStatus.failure,
    error: SupabaseErrorHandler.handle(e),
  ));
}

// AppError factory constructors:
AppError.unknown([String? message])
AppError.noInternet()
AppError.timeout()
AppError.unauthorized()
AppError.serverError()
```

**Critical rule:** Never use `catch (_)` — it discards real server errors. Always `catch (e)` + `SupabaseErrorHandler.handle(e)` so `serverMessage` is preserved and shown to the user.

### 5.3.5 Localization

All user-facing strings use `easy_localization` with `.tr()`. JSON files are stored in `assets/lang/en.json` and `assets/lang/ar.json`.

**Key namespaces:**

| Namespace                 | Module | Description                            |
| ------------------------- | ------ | -------------------------------------- |
| `errors.*`              | Global | Network / auth / server error messages |
| `app_dialogs.*`         | Global | Dialog button labels                   |
| `image_picker.*`        | Global | take_photo, choose_from_gallery        |
| `auth.*`                | Auth   | Login form strings                     |
| `worker_home.*`         | Worker | Greeting, filter chips, empty states   |
| `worker_add_report.*`   | Worker | Report form labels, messages           |
| `worker_reports.*`      | Worker | Reports list labels                    |
| `worker_task_details.*` | Worker | Task detail header, meta, actions      |
| `worker_profile.*`      | Worker | Profile screen                         |

**Named args pattern:**

```dart
'worker_home.no_status_tasks'.tr(namedArgs: {'status': status.label})
'worker_task_details.stand'.tr(namedArgs: {'code': task.standCode!})
```

**Section headers (uppercase display):**

```dart
title: 'primary_info'.tr().toUpperCase()
title: 'timeline'.tr().toUpperCase()
```

---

## 5.4 Key Flows

### 5.4.1 Authentication Flow

```
UserAuthenticatedCheck watches AuthCubit state
         │
         ▼
    ┌─────────┐
    │  Auth   │
    │ Success │
    └────┬────┘
         │
    switch userModel.role
         │
    ┌────┼────────────┐
    │    │            │
    ▼    ▼            ▼
unit_  super-       admin
manager visor
    │    │            │
    ▼    ▼            ▼
Multi  Multi        Admin
Bloc   Bloc        Dashboard
Provider Provider   Screen
  │      │
  ▼      ▼
Worker  Supervisor
Scaffold Scaffold
```

### 5.4.2 Task Lifecycle Flow

```
1. Admin imports flight from AviationStack API or manually
         │
2. Admin creates a task (status: pending, unit_id: NULL) per service type needed
         │
3. Supervisor sees unassigned tasks on Dashboard
         │
4. Supervisor selects available unit → assigns to task (unit_id set)
         │
5. Worker sees assigned task on Home screen
         │
6. Worker taps Start → task status → in_progress (actual_start recorded)
         │
7. Worker works through checklist items (is_checked, checked_at, checked_by)
         │
8. [Optional] Worker taps Pause → task_pause record (paused_at, reason)
         │
9. [Optional] Worker taps Resume → task status → in_progress (resumed_at)
         │
10. Worker taps Complete → task status → completed (actual_end recorded)
         │
11. If issue found → Worker submits report (type, severity, description, photo)
         │
12. Supervisor acknowledges report (status → acknowledged)
         │
13. Supervisor resolves report (status → resolved)
```

### 5.4.3 Supervisor Add Report Flow

```
1. Supervisor taps FAB on Reports tab
         │
2. SupervisorAddReportScreen opens
         │
3. Select target: Admin (red) or Worker (blue) — animated card selector
         │
4. Select report type, severity
         │
5. Enter description
         │
6. [Optional] Pick photo from camera or gallery
         │
7. Tap Submit
         │
8. System validates → inserts into reports table (no task_id/flight_id)
         │
9. If photo: upload to report-images Supabase Storage bucket
         │
10. Report appears in target's dashboard
```

### 5.4.4 Real-time Stream Flow

```
Supabase Realtime Channel
         │
         ▼
Cubit subscription listens to table changes
         │
         ▼
Stream emits updated rows
         │
         ▼
[If no joins needed] → Replace state data directly
         │
         ▼
[If joins needed] → Merge stream data with existing joined data from previous fetch
         │
         ▼
emit(state.copyWith(data: mergedData))
```

---

## 5.5 Conventions and Patterns

### 5.5.1 Naming Conventions

| Element         | Convention                                            | Example                                |
| --------------- | ----------------------------------------------------- | -------------------------------------- |
| Cubit           | `FeatureNameCubit`                                  | `HomeCubit`                          |
| State           | `FeatureNameState`                                  | `HomeState` (part of cubit file)     |
| Screen          | `feature_name_screen.dart` → `FeatureNameScreen` | `home_screen.dart` → `HomeScreen` |
| Remote DS       | `FeatureNameRemoteDs`                               | `HomeRemoteDs`                       |
| Repo (abstract) | `FeatureNameRepo`                                   | `HomeRepo`                           |
| Repo (impl)     | `FeatureNameRepoImpl`                               | `HomeRepoImpl`                       |
| Route constant  | lowercase camelCase                                   | `taskDetailsScreen`                  |

### 5.5.2 Sizing Rules

- Always use `flutter_screenutil` helpers: `.sp/.w/.h/.r` or `rw/rh/rr/rf`
- Never use raw pixel values

### 5.5.3 String Rules

- All user-facing strings via `.tr()` with namespaced keys
- Add strings to both `assets/lang/en.json` and `assets/lang/ar.json`
- Reuse existing top-level keys before creating new ones

### 5.5.4 Dialog Rules

- Always use `AppDialogs.showConfirm(context, message:, onConfirm:)` for confirmations
- Never use raw `showDialog`

### 5.5.5 Realtime Stream Rules

```dart
StreamSubscription? _subscription;

@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}
```

Supabase `.stream()` does not support joins:

- Initial fetch: `.select('*, related(*)')` with full joins
- Stream merge: merge incoming data with existing joined data from state using `firstWhereOrNull` (from the `collection` package)

### 5.5.6 Nullable copyWith Pattern

When a Cubit state field must be clearable to `null` via `copyWith`, use the sentinel-object pattern:

```dart
const _clear = Object();

SomeState copyWith({ Object? actionReportId = _clear }) {
  return SomeState(
    actionReportId: identical(actionReportId, _clear)
        ? this.actionReportId
        : actionReportId as String?,
  );
}
```

### 5.5.7 Do's and Don'ts

**Do:**

- Follow `data/logic/ui` folder structure for every feature
- Register every new cubit, repo, and DS in dependency_injection.dart
- Add every new route to routes.dart and handle in app_routers.dart
- Use AppError factory constructors for all exception handling
- Use SupabaseErrorHandler.handle(e) in every catch block
- Use AppTextStyles, AppColors, or context.customColors
- Reuse shared models before creating new ones
- Use AppDialogs.showConfirm before destructive actions
- Use TaskUiHelpers for task/priority colors
- Use context_ext.dart helpers — never raw Navigator.push

**Don't:**

- Hardcode pixel values — always rw/rh/rr/rf
- Hardcode strings — always .tr()
- Use catch (_) — always catch (e)
- Access Supabase directly — always via SupabaseService or repo
- Put feature logic in global cubits (AuthCubit, AppSettingsCubit)
- Skip the repository layer
- Mix Worker/Supervisor/Admin UI across modules
- Use raw Navigator.push with widget constructors
- Inline TextStyle or Color — use AppTextStyles and AppColors
- Call context.pop() unconditionally on dual-context screens
- Use raw showDialog for confirmations

---

## 5.6 Web Dashboard Implementation

### 5.6.1 Data Layer

All Supabase reads and writes are encapsulated in `lib/queries/`. Components never import the Supabase client directly for data fetching.

| File                  | Responsibility                                                                                               |
| --------------------- | ------------------------------------------------------------------------------------------------------------ |
| `auth.ts`           | `getCurrentSession`, `getCurrentUser`, `signInWithPassword`, `signOut`                               |
| `overview.ts`       | Stat card counts (flights today, active tasks, pending requests, open reports), recent flights, open reports |
| `flights.ts`        | Flight list, flight detail, stand assignment                                                                 |
| `operations.ts`     | Task list with joins,`updateTaskStatus`                                                                    |
| `reports.ts`        | Report list and detail with full joins                                                                       |
| `reports-client.ts` | Client-side report status mutations (acknowledge, resolve)                                                   |
| `analytics.ts`      | `getDelayAnalysis`, `getFlightTurnaroundSummary`, `getUnitPerformance`                                 |
| `service-types.ts`  | `getServiceTypes`, create, update, soft-delete                                                             |
| `stands.ts`         | Stand list, create, update                                                                                   |
| `units.ts`          | Unit list and detail                                                                                         |
| `unit-members.ts`   | Member list per unit, create, update, soft-delete                                                            |
| `users.ts`          | User list, update                                                                                            |

Initial page data is fetched via Server Components using the server Supabase client. Interactive mutations and Realtime subscriptions use the browser client inside Client Components.

### 5.6.2 Screens & Key Features

**Overview Dashboard (`/[locale]/`)**
Four real-time stat cards (Flights Today, Active Tasks, Pending Requests, Open Reports) kept live via Supabase Realtime `postgres_changes` subscriptions on the `tasks` and `reports` tables. Below the cards: last 10 recent flights and last 5 open reports, both refreshing automatically on database changes.

**Operations Monitor (`/[locale]/operations`)**
Three-column Kanban board showing tasks in `pending`, `in_progress`, and `completed` states. Each card displays the task ID, service type, and priority badge. An inline status selector lets the admin move tasks between states without opening a detail panel. On mobile, columns are horizontally scrollable with fixed-width cards; at `md+` the board renders as a CSS grid.

**Flights (`/[locale]/flights` and `/[locale]/flights/[id]`)**
List view with a DataTable showing flight number, airline, origin/destination, aircraft type, scheduled arrival, status badge, and stand assignment. An **Import Flights** button triggers `POST /api/import-flights`, which fetches up to 100 arrivals and 100 departures for IATA code `CAI` from AviationStack and upserts them into the `flights` table. The detail page shows the full flight metadata grid, status timeline, and service requests for that flight.

**Reports (`/[locale]/reports` and `/[locale]/reports/[id]`)**
List with filter pills for status (`open`, `acknowledged`, `resolved`) and client-side CSV export of the filtered rows. The detail page renders the reporter, flight association, severity badge, description, photo (if present), and action buttons to move the report through the `open → acknowledged → resolved` workflow, each guarded by a `ConfirmDialog`.

**Analytics (`/[locale]/analytics`)**
Three tabs backed by pre-computed analytics tables:

| Tab                | Data Source                         | Visualisation                               |
| ------------------ | ----------------------------------- | ------------------------------------------- |
| Delay Analysis     | `delay_analysis` table            | Bar chart (Recharts) with date-range filter |
| Turnaround Summary | `flight_turnaround_summary` table | Data table with date-range filter           |
| Unit Performance   | Aggregate over`tasks`             | Data table with service-type filter         |

**Master Data (Service Types, Stands, Units, Users)**
All four screens follow the same CRUD pattern: DataTable list → SlideOverSheet create/edit form validated with Zod via React Hook Form → soft-delete (`is_active = false`) guarded by ConfirmDialog. Units have a detail page showing crew members with photo upload to Supabase Storage. Users shows supervisors and unit managers only — admin accounts cannot be created from this screen.

### 5.6.3 Credential Generation

When creating a new supervisor or unit manager, the dashboard auto-generates login credentials without admin input:

**Email patterns:**

```
Supervisor of "Fuelling & Hydrant" → supervisor.fuelling_&_hydrant@groundscope.com
Manager of "Fuel Truck A1"        → manager.fuel_truck_a1@groundscope.com
```

Spaces are replaced with underscores; the full string is lowercased.

**Password pattern:**

```
GroundScope{4 random zero-padded digits}{1 random char from !@#$%}
Example: GroundScope0347!
```

Generated credentials are displayed once in a `CredentialsDialog` after account creation and are **not stored** in the database. The admin must securely hand them to the new user.

### 5.6.4 Non-Negotiable Conventions

| Rule                                                                                               | Reason                                                           |
| -------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| No Supabase calls inside components — all reads/writes go through`lib/queries/*`                | Keeps query logic testable and prevents credential exposure      |
| No hardcoded hex colors — use Tailwind token classes only                                         | Token system is how dark mode works                              |
| No hardcoded user-facing strings — use`next-intl` keys, add to both JSON files                  | Arabic locale would display raw key strings                      |
| No hardcoded`left`/`right` — use logical CSS (`ms-`, `me-`, `start-`, `end-`)         | RTL support breaks without logical properties                    |
| No destructive action without a`ConfirmDialog`                                                   | Prevents accidental data loss                                    |
| Soft delete only —`is_active = false`; never hard-delete                                        | Mobile app holds FK references; hard delete would break them     |
| `SUPABASE_SERVICE_ROLE_KEY` and `AVIATIONSTACK_API_KEY` must never use `NEXT_PUBLIC_` prefix | These keys bypass RLS and would be exposed in the browser bundle |

### 5.6.5 Deployment

The dashboard is deployed to **Vercel**. Required environment variables:

```
NEXT_PUBLIC_SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY
AVIATIONSTACK_API_KEY
```

The middleware refreshes the Supabase auth session on every request by calling `supabase.auth.getUser()`, writing rotated tokens back to cookies automatically and preventing the ~1-hour JWT expiry that would otherwise cause RLS to return empty rows without an error.

---

# Chapter 6: GroundScope Vision — Apron Equipment Detection

---

## 6.1 Overview & Role in the System

GroundScope Vision is the third component of the GroundScope platform, alongside the Flutter mobile application and the Next.js web admin dashboard. It is a computer-vision module that automatically detects and classifies airport ground service equipment in apron camera footage, providing an objective, sensor-based view of what is physically happening at each stand during a flight turnaround.

> **Core Problem** GroundScope's task lifecycle relies on unit managers manually tapping *Start* and *Complete*. These self-reported timestamps drive the delay analytics, yet they cannot be independently verified. GroundScope Vision closes this gap: by visually recognising which equipment is present at a stand, and when, it supplies a *ground-truth* reference against which the app-reported times can be cross-checked.

**Integration status.** The detection model has been fully **trained and verified as a standalone artifact**, achieving 99.34 % mAP@50 on its validation set and successfully processing real airport footage (see §6.7). The **data-flow design** that maps detections onto the GroundScope database is specified in §6.8. The **live runtime bridge** that writes detections into Supabase (`stand_events`, `delay_analysis`) is **designed but not yet implemented** — it is documented here as the integration blueprint and listed as future work in Chapter 8.

GroundScope Vision is positioned as the verification layer that distinguishes GroundScope from coordination-only systems: airport-level A-CDM platforms track milestones, and enterprise tools schedule resources, but neither confirms — from the apron itself — that a fuelling truck actually arrived at the stand and how long it stayed.

---

## 6.2 Model Summary

The detector is a **YOLO11s** (small-scale) single-stage object-detection network trained with the Ultralytics framework. All figures below were verified by loading the checkpoint directly and by running live inference; none are assumed.

| Property             | Value                                        |
| -------------------- | -------------------------------------------- |
| Architecture         | YOLO11s (scale`s`, depth 0.5 / width 0.5)  |
| Task                 | Object detection                             |
| Training framework   | Ultralytics v8.4.53                          |
| Base model           | `yolo11s.pt` (ImageNet-pretrained)         |
| Input resolution     | 640 × 640 px                                |
| Number of classes    | 10                                           |
| Total parameters     | ~9.43 M (9,416,670 after fusion)             |
| Weight precision     | FP16 (float16)                               |
| GFLOPs               | 21.3                                         |
| Detection strides    | 8, 16, 32 (three scales)                     |
| Output tensor        | `(1, 14, 8400)` — 14 = 4 box + 10 classes |
| Deployment file size | 18.30 MB (`.pt`), 36.18 MB (ONNX)          |

### Validation Metrics

| Metric                   | Value                 |
| ------------------------ | --------------------- |
| Precision (B)            | **99.14 %**     |
| Recall (B)               | **99.59 %**     |
| mAP@50 (B)               | **99.34 %**     |
| mAP@50–95 (B)           | **88.35 %**     |
| Box / Cls / DFL val loss | 0.424 / 0.241 / 0.860 |

The combination of very high precision and recall indicates the model rarely misses equipment and rarely raises false detections on the validation distribution — a desirable property for a verification layer, where false events would corrupt the delay analytics.

---

## 6.3 Detected Classes and Service-Type Mapping

The model recognises ten classes of ground service equipment. Crucially, these classes map onto GroundScope's `service_types`, which is what allows a visual detection to validate a specific service task.

| # | Class (`model.names`) | Arabic                             | Maps to GroundScope service |
| - | ----------------------- | ---------------------------------- | --------------------------- |
| 0 | `baggage_truck`       | شاحنة الأمتعة          | Baggage handling            |
| 1 | `catering_truck`      | شاحنة التموين          | Catering                    |
| 2 | `fuel_truck`          | شاحنة الوقود            | Fuelling                    |
| 3 | `ground_power`        | مولد الطاقة الأرضي | Ground power                |
| 4 | `jet_bridge`          | جسر الانسياب            | Passenger boarding / access |
| 5 | `ramp_loader`         | رافعة التحميل          | Baggage / cargo loading     |
| 6 | `rolling_stairway`    | سلّم متحرك                | Passenger access            |
| 7 | `stairway`            | سلّم ثابت                  | Passenger access            |
| 8 | `tank_hose`           | خرطوم الوقود            | Fuelling                    |
| 9 | `tug`                 | جرار الطائرة            | Pushback / towing           |

A detection of `fuel_truck` or `tank_hose` at a stand, for example, is evidence that a **Fuelling** task is underway; `catering_truck` corroborates a **Catering** task; `baggage_truck` and `ramp_loader` corroborate **Baggage** handling. This mapping is the conceptual bridge between raw pixels and GroundScope's operational records.

---

## 6.4 Dataset and Training Configuration

The model was trained on a Kaggle GPU environment from the `yolo11s.pt` pretrained base. Training was configured for 500 epochs but stopped early at **epoch 204** when the validation fitness failed to improve for 20 consecutive epochs (patience = 20). The best mAP@50 (0.99443) was reached at epoch 90. Total wall-clock training time was approximately 1.3 hours.

| Setting                    | Value                   |
| -------------------------- | ----------------------- |
| Optimizer                  | AdamW                   |
| Initial / final LR         | 0.001 / 1e-5 (lrf 0.01) |
| Momentum / weight decay    | 0.937 / 0.0005          |
| Batch size                 | 16 (nominal batch 64)   |
| Image size                 | 640                     |
| Warmup epochs              | 3.0                     |
| Mixed precision (AMP)      | Enabled                 |
| Loss weights (box/cls/dfl) | 7.5 / 0.5 / 1.5         |

**Augmentation.** Training used mosaic (disabled for the final 10 epochs), RandAugment, HSV jitter, 50 % horizontal flip, scaling (0.5), translation (0.1), and random erasing (0.4). Rotation, shear, perspective, mixup, and copy-paste were disabled.

> **Honest note on provenance.** The checkpoint does not embed the source dataset slug or the per-class training distribution, and the dataset YAML path (`/kaggle/working/data.yaml`) is a Kaggle-specific location no longer available locally. These items are recorded as *unconfirmed* and should be recovered from the original Kaggle notebook before final submission.

---

## 6.5 Model Architecture (Overview)

YOLO11s follows the modern single-stage detector design: a CSP (Cross-Stage Partial) backbone, a Path-Aggregation-Network (PAN) neck, and three decoupled detection heads operating at strides 8, 16, and 32 for small, medium, and large objects respectively.

- **Backbone** — stacked `Conv` downsampling layers interleaved with `C3k2` cross-stage bottlenecks, terminated by an `SPPF` (Spatial Pyramid Pooling – Fast) block and a `C2PSA` block that adds cross-stage self-attention at the top of the backbone.
- **Neck** — a top-down FPN path (upsample + concat) followed by a bottom-up PAN path, fusing multi-scale features.
- **Head** — three parallel `Detect` heads. Each splits into a box-regression branch (DFL-based, 16 distribution bins) and a classification branch (10 classes). The model produces 8,400 anchor proposals per pass (80² + 40² + 20²), emitted as a `(1, 14, 8400)` tensor.

The complete layer-by-layer architecture, detection-head internals, and scale configuration are reproduced in **Appendix A**.

---

## 6.6 Inference and Tracking Pipeline

For deployment the model runs with confidence threshold 0.25, IoU (NMS) threshold 0.45, and input size 640, in streaming mode so that frames are processed one at a time rather than buffered in memory.

To move from per-frame detections to *temporal* events — which is what GroundScope needs — the pipeline applies **BotSORT** multi-object tracking (already referenced in the checkpoint's training arguments). With `persist=True`, each detected unit is assigned a stable track ID across frames, enabling the system to measure how long a given piece of equipment remains at a stand. This dwell-time is the basis for deriving camera-observed arrival and departure timestamps (§6.8).

**Production camera setup (NVIDIA Jetson + USB camera):**

On the production Jetson edge device, the stand camera is a USB camera re-streamed via the Jetson's built-in GStreamer stack (`nvidia-l4t-gstreamer`) before being consumed by the YOLO pipeline. The GStreamer pipeline captures from the V4L2 device and exposes it as an RTSP endpoint that the tracker reads:

```bash
# Prerequisite — rtspclientsink requires gst-rtsp-server, which is NOT pre-installed on L4T R32.7.6.
# Install it once on the Jetson before running the pipeline below:
sudo apt-get install gstreamer1.0-rtsp

# Step 1 — re-stream the USB camera as RTSP via GStreamer (run once at device startup)
gst-launch-1.0 v4l2src device=/dev/video0 ! \
  video/x-raw,width=1280,height=720,framerate=30/1 ! \
  nvvidconv ! video/x-raw(memory:NVMM) ! \
  nvv4l2h264enc ! h264parse ! \
  rtspclientsink location=rtsp://localhost:8554/stand-camera
```

```python
# Step 2 — per-frame detection feeding the event builder
model.track(source="rtsp://localhost:8554/stand-camera", tracker="botsort.yaml",
            conf=0.25, iou=0.45, imgsz=640, persist=True, stream=True)
```

For development or offline analysis without GStreamer, a direct V4L2 source (`source="/dev/video0"`) or a pre-recorded video file can be substituted.

---

## 6.7 Verified Standalone Results

The model was evaluated on a real airport timelapse — *"Belgrade Airport Ground Crew Timelapse — Airplane Loading Refueling Catering"* (1,201 frames, ~720p) — to confirm behaviour on genuine apron footage rather than only the validation set.

| Metric                               | Value                    |
| ------------------------------------ | ------------------------ |
| Frames processed                     | 1,201                    |
| Total detections                     | 3,931                    |
| Average detections / frame           | 3.27                     |
| Inference speed (CPU, Ryzen 5 5500U) | 4.57 FPS (~219 ms/frame) |

### Per-Class Detections (full video)

| Class            | Detections | Avg confidence |
| ---------------- | ---------- | -------------- |
| jet_bridge       | 1,201      | 0.86           |
| fuel_truck       | 992        | 0.68           |
| ramp_loader      | 577        | 0.63           |
| ground_power     | 458        | 0.31           |
| tank_hose        | 481        | 0.80           |
| tug              | 155        | 0.48           |
| baggage_truck    | 26         | 0.39           |
| catering_truck   | 13         | 0.37           |
| stairway         | 22         | 0.43           |
| rolling_stairway | 6          | 0.53           |

The persistently-detected `jet_bridge` (present in every frame, high confidence) and the strong `fuel_truck` / `tank_hose` signals match the catering/refuelling scenario in the test footage. Lower average confidence on classes such as `ground_power` (0.31) reflects smaller, partially-occluded equipment and is discussed in §6.11.

---

## 6.8 Integration Design with GroundScope

GroundScope's schema already anticipates a camera-based source: the `cameras`, `stand_events`, and `delay_analysis` tables, the `event_source = 'camera'` enum value, and the `confidence_score` column were all designed for exactly this module. GroundScope Vision populates them as follows.

| Detection / tracking output      | GroundScope target                              | Notes                                                                                                                               |
| -------------------------------- | ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Detection confidence (0–1)      | `stand_events.confidence_score`               | Direct 1:1 mapping                                                                                                                  |
| Class → service type (§6.3)    | `stand_events.service_type_id`                | Routes the event to the right service                                                                                               |
| A tracked equipment appearance   | `stand_events` row, `source = 'camera'`     | One event per tracked unit at a stand                                                                                               |
| Camera feed reference            | `cameras.stream_url` / `cameras.identifier` | GStreamer RTSP endpoint (`rtsp://localhost:8554/stand-camera`) from the Jetson edge device; gated by `stands.has_camera = true` |
| BotSORT first-seen timestamp     | `delay_analysis.camera_unit_arrival`          | Equipment arrival at stand                                                                                                          |
| BotSORT last-seen timestamp      | `delay_analysis.camera_unit_departure`        | Equipment departure                                                                                                                 |
| Camera time vs app-reported time | `delay_analysis.app_vs_camera_discrepancy`    | The verification payoff                                                                                                             |

### Vision Data-Flow

```
 ┌─────────────────────────────────────────────────────────────┐
 │                  NVIDIA Jetson (on-stand edge device)        │
 │                                                              │
 │  ┌──────────────┐  V4L2   ┌───────────────┐  RTSP stream   │
 │  │ USB Camera   │────────▶│  GStreamer     │────────────┐   │
 │  │ (IMC Networks│         │ (nvidia-l4t-   │            │   │
 │  │ 13d3:3549)   │         │  gstreamer)    │            │   │
 │  └──────────────┘         └───────────────┘            │   │
 │                                                         │   │
 │           ┌─────────────────────────────────────────────┘   │
 │           ▼                                                  │
 │  ┌──────────────┐  detections  ┌──────────────┐            │
 │  │  YOLO11s     │────────────▶│  BotSORT     │            │
 │  │  (TensorRT   │              │  tracker     │            │
 │  │   engine)    │              └──────┬───────┘            │
 │  └──────────────┘                     │ track IDs +        │
 │                                       │ first/last seen    │
 │                                       ▼                    │
 │                              ┌──────────────────┐          │
 │                              │ Event/dwell      │          │
 │                              │ builder          │          │
 │                              └────────┬─────────┘          │
 └───────────────────────────────────────┼────────────────────┘
                                         │ writes (HTTPS to Supabase)
                      ┌──────────────────┼─────────────────┐
                      ▼                                      ▼
             ┌──────────────────┐                ┌──────────────────┐
             │  stand_events    │                │  delay_analysis  │
             │ (source=camera,  │                │ (camera arrival/ │
             │  confidence)     │                │  departure)      │
             └──────────────────┘                └──────────────────┘
```

> **Status — designed, not yet implemented.** The mapping and data-flow above are the integration blueprint. The service that consumes camera feeds and writes these rows into Supabase has not been built; see Chapter 8 (Future Work).

---

## 6.9 Deployment Considerations

### Production Deployment — NVIDIA Jetson Edge Device

GroundScope Vision is deployed on a **NVIDIA Jetson** board (t186ref, JetPack L4T R32.7.6) installed directly at each airport stand. This edge-first architecture avoids streaming raw video across the network — inference runs on-device, and only structured detection events are written to Supabase.

**Throughput on the production Jetson:**

| Runtime                                        | Expected throughput                                            | Notes                                                                                           |
| ---------------------------------------------- | -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Jetson CPU only (Cortex-A57)                   | < 4.57 FPS                                                     | Insufficient for live feed — offline/strided analysis only                                     |
| Jetson Tegra GPU (native PyTorch)              | ~30–60 FPS*(estimated — not yet benchmarked on this device)* | Suitable for single-camera real-time use; must be verified with`yolo benchmark` on the Jetson |
| Jetson Tegra GPU + TensorRT (JetPack built-in) | ~100+ FPS*(estimated — not yet benchmarked on this device)*   | Recommended production configuration; benchmark after TensorRT engine compilation               |

**Recommended production setup:**

1. Export the YOLO11s `.pt` checkpoint to a TensorRT engine using the Jetson's built-in TensorRT libraries:

```python
from ultralytics import YOLO
model = YOLO("groundscope_vision.pt")
model.export(format="engine", device=0, half=True)  # FP16 TensorRT engine
```

2. Run the tracker against the GStreamer RTSP endpoint (see §6.6 for the full GStreamer setup):

```python
model = YOLO("groundscope_vision.engine")  # TensorRT engine
model.track(source="rtsp://localhost:8554/stand-camera", tracker="botsort.yaml",
            conf=0.25, iou=0.45, imgsz=640, persist=True, stream=True)
```

**Alternative — ONNX Runtime (aarch64 fallback):**

If TensorRT compilation is unavailable, the verified ONNX export (36.18 MB) runs on the Jetson's aarch64 CPU via `onnxruntime`. Use `vid_stride=7` to process 1 of every 7 frames from a **pre-recorded** source, reducing the analysis rate to ~4 frames/second. This is **not suitable for live feeds** — on a live 30 FPS stream, each frame still takes ~219 ms to infer on the Cortex-A57, so the pipeline queue grows unbounded even with striding. Reserve this path for post-hoc offline review of recorded footage.

```python
model = YOLO("groundscope_vision.onnx")  # ONNX Runtime on aarch64
model.track(source="rtsp://localhost:8554/stand-camera", tracker="botsort.yaml",
            conf=0.25, iou=0.45, imgsz=640, vid_stride=7, persist=True, stream=True)
```

**Storage on the Jetson:**

The 119.2 GB NVMe SSD (`nvme0n1`) is available for model weights, TensorRT engine cache, and local video recording. The 14.7 GB eMMC hosts the OS. All inference artifacts and logs should be written to the NVMe SSD.

**Connectivity:**

The Jetson connects to Supabase over Wi-Fi (`wlan0`) or Ethernet (`eth0`). The vision bridge service writes `stand_events` and `delay_analysis` rows over HTTPS using the Supabase service-role key, which must be stored securely on the device (e.g. in a `.env` file readable only by the service user, not exposed in the Docker image).

---

## 6.10 Output Schema for Downstream Use

Each detection serialises to a flat, database-friendly structure (real values shown):

```json
{
  "frame_id": 1,
  "timestamp_sec": 0.04,
  "detections": [
    {
      "class_id": 4,
      "class_name": "jet_bridge",
      "confidence": 0.8745,
      "bbox_x1": 1099.85, "bbox_y1": 0.5,
      "bbox_x2": 1280.0,  "bbox_y2": 295.17
    }
  ]
}
```

Coordinates are absolute pixels relative to the letterboxed 640 × 640 input; to recover original-resolution coordinates, scale by `original_width / 640`. The `class_name` and `confidence` fields map directly onto `stand_events.service_type_id` (via §6.3) and `stand_events.confidence_score`.

---

## 6.11 Current Limitations and Integration Status

- **No live bridge yet.** The runtime service writing detections into Supabase is not implemented; the integration in §6.8 is a design, not a deployed pipeline.
- **TensorRT engine required for real-time on Jetson.** The Jetson Tegra GPU running native PyTorch is estimated at ~30–60 FPS (not yet benchmarked on this device — see §6.9); to sustain real-time throughput under load, the model must be compiled to a TensorRT engine. The ONNX fallback on the Cortex-A57 CPU gives < 4.57 FPS and is limited to offline/strided use on pre-recorded footage.
- **GStreamer pipeline dependency.** The USB camera (IMC Networks, ID 13d3:3549) must be re-streamed as RTSP via `nvidia-l4t-gstreamer` before the YOLO tracker can consume it. The GStreamer service must be started and stable before the vision bridge is launched (see §6.6).
- **Variable per-class confidence.** Small or occluded equipment (e.g. `ground_power` at 0.31 average) detects less confidently; a per-class confidence threshold and tracking-based smoothing are recommended before events are trusted.
- **Single-airport scope.** The detector was trained for general apron equipment; per-airport fine-tuning may be needed for Cairo International Airport camera angles and lighting conditions.
- **Unconfirmed dataset provenance.** Source dataset and class distribution are not embedded in the checkpoint (see §6.4).

---

# Chapter 7: Results and Discussion

---

## 7.1 System Screenshots

The following screenshots demonstrate the implemented system across all three user roles and both platforms (Flutter mobile app and Next.js web dashboard). Each screen is captioned with its role, platform, and a brief description.

---

### 7.1.1 Authentication

**Screenshot 1 — Login Screen (Mobile)**

> 📸 *[TODO: Insert screenshot of the mobile login screen]*
>
> *Role: All roles — Platform: Mobile (Flutter)*
> The entry point for all users. Displays the GroundScope logo, email and password fields, and the sign-in button. The app routes the user to their role-specific interface after authentication.

---

### 7.1.2 Worker (Unit Manager) Screens

**Screenshot 2 — Task List (Home Tab)**

> 📸 *[TODO: Insert screenshot of the worker home screen showing the task list with status filter chips]*
>
> *Role: Unit Manager — Platform: Mobile (Flutter)*
> Shows all tasks assigned to the worker's unit. Status filter chips (All, Pending, In Progress, Paused, Completed) allow quick filtering. Each card shows the task ID, service type, priority badge, and flight number.

**Screenshot 3 — Task Detail with Checklist**

> 📸 *[TODO: Insert screenshot of the task detail screen with checklist items visible]*
>
> *Role: Unit Manager — Platform: Mobile (Flutter)*
> Displays the full task metadata (flight, stand, scheduled time, notes) and the ordered checklist. Workers check off items one by one as they complete each step.

**Screenshot 4 — Task in Paused State**

> 📸 *[TODO: Insert screenshot of a task in paused state showing the pause reason and resume button]*
>
> *Role: Unit Manager — Platform: Mobile (Flutter)*
> Demonstrates the pause/resume lifecycle. The pause reason entered by the worker is recorded and displayed, with the total paused duration tracked for delay analysis.

**Screenshot 5 — Add Report Form**

> 📸 *[TODO: Insert screenshot of the Add Report screen with report type, severity, and description filled in]*
>
> *Role: Unit Manager — Platform: Mobile (Flutter)*
> The incident report submission form. Workers select a report type, severity level (Low / Medium / High / Critical), enter a description, and optionally attach a photo from camera or gallery.

**Screenshot 6 — Worker Reports List**

> 📸 *[TODO: Insert screenshot of the worker's reports list showing severity badges and status]*
>
> *Role: Unit Manager — Platform: Mobile (Flutter)*
> Lists all reports submitted by the worker's unit, filterable by status. Each card shows severity color coding and the current acknowledgment status.

---

### 7.1.3 Supervisor Screens

**Screenshot 7 — Supervisor Dashboard (Service Requests)**

> 📸 *[TODO: Insert screenshot of the supervisor dashboard showing unassigned service requests]*
>
> *Role: Supervisor — Platform: Mobile (Flutter)*
> The supervisor's primary screen. Displays live statistics (active tasks, pending requests, available units) and the list of unassigned service requests (tasks with `unit_id IS NULL`) that require action.

**Screenshot 8 — Assign Unit Bottom Sheet**

> 📸 *[TODO: Insert screenshot of the assign unit bottom sheet open over the dashboard]*
>
> *Role: Supervisor — Platform: Mobile (Flutter)*
> The unit assignment flow. The supervisor selects an available unit from the list and sets the scheduled start and end times before confirming the assignment.

**Screenshot 9 — Tasks Tab with Status Color Bars**

> 📸 *[TODO: Insert screenshot of the supervisor tasks tab showing task cards with left accent color bars]*
>
> *Role: Supervisor — Platform: Mobile (Flutter)*
> Live task monitoring view. Each card has a colored left accent bar matching the task status (blue for in progress, amber for pending, green for completed) for instant visual scanning.

**Screenshot 10 — Reports Tab with Acknowledge/Resolve Actions**

> 📸 *[TODO: Insert screenshot of the supervisor reports tab showing an open report with action buttons]*
>
> *Role: Supervisor — Platform: Mobile (Flutter)*
> Shows the report workflow from the supervisor's perspective. Each report card displays the severity accent bar and action buttons to acknowledge or resolve, each requiring confirmation before proceeding.

---

### 7.1.4 Web Admin Dashboard Screens

**Screenshot 11 — Overview Dashboard (Stat Cards)**

> 📸 *[TODO: Insert screenshot of the web admin overview dashboard showing 4 stat cards and recent flights]*
>
> *Role: Admin — Platform: Web Dashboard (Next.js)*
> The administrator's home screen. Four real-time stat cards display Flights Today, Active Tasks, Pending Requests, and Open Reports — all updating live via Supabase Realtime without page refresh.

**Screenshot 12 — Operations Kanban Board**

> 📸 *[TODO: Insert screenshot of the full Kanban board with all three columns visible]*
>
> *Role: Admin — Platform: Web Dashboard (Next.js)*
> The most operationally critical screen. Three columns (Pending, In Progress, Completed) display all active tasks. The admin can move tasks between states inline using the status selector on each card.

**Screenshot 13 — Flights List with Import Button**

> 📸 *[TODO: Insert screenshot of the flights list DataTable with the Import Flights button visible]*
>
> *Role: Admin — Platform: Web Dashboard (Next.js)*
> Lists all flights with their status badges and stand assignments. The Import Flights button triggers the AviationStack API integration, fetching up to 200 flights (100 arrivals + 100 departures) for Cairo International Airport.

**Screenshot 14 — Report Detail with Workflow Buttons**

> 📸 *[TODO: Insert screenshot of a report detail page showing the Acknowledge and Resolve buttons]*
>
> *Role: Admin — Platform: Web Dashboard (Next.js)*
> The full report detail view showing reporter information, flight association, severity badge, description, photo (if attached), and action buttons to advance the report through the `open → acknowledged → resolved` workflow.

**Screenshot 15 — Analytics — Delay Analysis Chart**

> 📸 *[TODO: Insert screenshot of the analytics tab showing the delay analysis bar chart]*
>
> *Role: Admin — Platform: Web Dashboard (Next.js)*
> The delay analysis tab showing start and end delay metrics per flight as a bar chart (Recharts). A date-range filter allows the admin to focus on a specific operational period.

**Screenshot 16 — Credentials Dialog after User Creation**

> 📸 *[TODO: Insert screenshot of the CredentialsDialog showing a generated email and password]*
>
> *Role: Admin — Platform: Web Dashboard (Next.js)*
> After creating a new supervisor or unit manager account, the system displays the auto-generated credentials once in a modal dialog. The credentials are not stored in the database and must be handed to the user securely at this point.

---

### 7.1.5 Cross-Cutting Features

**Screenshot 17 — Arabic RTL Layout**

> 📸 *[TODO: Insert screenshot of any screen in Arabic locale showing full RTL layout]*
>
> *Role: Any — Platform: Mobile or Web*
> Demonstrates full bilingual support. The layout mirrors correctly in Arabic — navigation, text alignment, and directional icons all flip to right-to-left without any conditional logic, achieved through CSS logical properties and Flutter's RTL-aware widgets.

**Screenshot 18 — Dark Mode vs Light Mode**

> 📸 *[TODO: Insert side-by-side screenshot of the same screen in light and dark mode]*
>
> *Role: Any — Platform: Web Dashboard (Next.js)*
> Demonstrates the theming system. All surface and text colors are CSS custom properties that swap automatically when the `.dark` class is applied to the HTML element, with no hardcoded color values in components.

---

### 7.1.6 GroundScope Vision Detections

**Screenshot 19 — Annotated Apron Detection**

> 📸 *[TODO: Insert an annotated frame from GroundScope Vision showing labelled bounding boxes (jet_bridge, fuel_truck, tank_hose, ramp_loader) on real apron footage]*
>
> *Component: GroundScope Vision — Platform: Python (Ultralytics YOLO11s)*
> Demonstrates the detector on the Belgrade Airport test footage, with bounding boxes and confidence scores for each detected equipment class.

**Screenshot 20 — Per-Class Detection Summary**

> 📸 *[TODO: Insert the per-class detection bar chart from the 1,201-frame test run]*
>
> *Component: GroundScope Vision — Platform: Python*
> Summarises total detections and average confidence per equipment class across the full test video (see §6.7).

---

*Sections 7.2–7.5 will be completed after system testing and deployment.*

- 7.2 Performance Metrics (API latency, sync delay, UI responsiveness)
- 7.3 System Reliability (uptime, error rates, FCM delivery rates)
- 7.4 User Acceptance Testing (if conducted)
- 7.5 Comparison with Manual Process (time savings, error reduction)

---

# Chapter 8: Conclusions & Future Work

---

## 8.1 Key Design Decisions

Throughout the development of GroundScope, several architectural and design decisions were made that shaped the final system:

### 8.1.1 Soft Delete Only

No record is ever hard-deleted from the database. All entities (service types, units, users, stands) have an `is_active` boolean column. Inactive records are hidden from the UI but preserved for historical data integrity. This ensures that reports and tasks referencing a deactivated unit or user remain readable and auditable.

### 8.1.2 Supervisor Scoped to One Service Type

A supervisor is linked to exactly one service type via the `service_type_id` column on the users table. This keeps each supervisor's workload focused and ensures clear accountability. Data isolation is enforced at the database level via Supabase RLS policies — a fueling supervisor only sees fueling data, never catering or cleaning data.

### 8.1.3 Unit Members Are Not App Users

Unit members (crew) stored in the `unit_members` table do not have login accounts. Only the Unit Manager has an app account. This simplifies authentication by reducing the number of app users, prevents scope creep, and ensures that crew data remains display-only for the unit profile screen.

### 8.1.4 Tasks Are the Central Coordination Object

The `tasks` table serves as both the service request mechanism and the execution tracking record. Unassigned tasks (`unit_id IS NULL`, `status = 'pending'`) represent service requests that supervisors can see and act on. Once a supervisor assigns a unit, the task becomes the worker's execution record. This single-table design simplifies the data model and keeps the supervisor's dashboard focused on actionable items.

### 8.1.5 Supervisor Standalone Reports

Supervisors can file incident reports without associating them with a specific task or flight. The `reported_to` field (`admin` or `worker`) determines the target audience. This required a database migration making `task_id` and `flight_id` nullable on the `reports` table and adding the `reported_to` column.

### 8.1.6 Error Handling Discipline

Every `catch` block uses `SupabaseErrorHandler.handle(e)` to preserve server error messages. The `catch (_)` pattern is explicitly forbidden because it silently discards meaningful error information that would help users understand what went wrong.

### 8.1.7 Modular Architecture with Feature Isolation

Each role module (worker, supervisor, admin) is fully independent with its own data sources, repositories, cubits, and screens. Shared code lives in `core/` — including shared models, widgets, utilities, and infrastructure. This prevents cross-role coupling and makes the codebase easier to navigate and maintain.

### 8.1.8 Camera as an Objective Ground Truth

Rather than trusting self-reported task times alone, GroundScope was designed to admit a camera-based verification layer (GroundScope Vision). The database schema reserves `stand_events` and `delay_analysis` columns for camera-observed data from the outset, so the visual detector can later corroborate — or contradict — what workers report, turning delay analytics from self-reported figures into independently verifiable measurements.

---

## 8.2 Achievements

GroundScope successfully delivers:

1. **Role-based mobile coordination**: Three distinct interfaces (Worker, Supervisor, Admin) each tailored to their operational needs with appropriate data access and functionality.
2. **Real-time task lifecycle management**: Complete digital workflow from task creation through assignment, execution (start/pause/resume/complete), and incident reporting.
3. **Database-level security**: Supabase Row Level Security ensures each role sees only authorized data, enforced at the database level rather than application level.
4. **Structured incident reporting**: Reports with type, severity, photo evidence, and an acknowledgment/resolution workflow.
5. **Flight data integration**: Automatic ingestion from the AviationStack API with manual entry fallback.
6. **Bilingual support**: Full English and Arabic localization with RTL layout through easy_localization.
7. **Responsive mobile design**: Consistent user experience across iOS and Android devices using flutter_screenutil with a 390×844 base canvas.
8. **Comprehensive design system**: A unified set of colors, typography, components, and patterns used consistently across all three role modules.
9. **Real-time updates**: Supabase Realtime streams push task and unit status changes to connected clients without polling.
10. **Standalone supervisor reports**: Supervisors can file reports without task/flight association, targeting admin or other workers.
11. **Web admin dashboard**: A full-featured Next.js 14 web application giving the airport administrator a desktop-optimised interface for real-time operations monitoring, flight import, CRUD management of all master data, analytics, report resolution, and automated credential generation — all sharing the same Supabase backend as the mobile app.
12. **GroundScope Vision detector**: A YOLO11s model trained to detect 10 classes of ground service equipment, achieving 99.34 % mAP@50 and verified on real airport footage (1,201 frames, 3,931 detections), with a complete design for integrating its output into the GroundScope database as camera-based validation.

---

## 8.3 Future Enhancements

### 8.3.1 Native Mobile App for Admin

The current admin interface is delivered exclusively through the web dashboard. A dedicated native mobile app for the administrator would allow on-the-go monitoring, flight imports, and report resolution without requiring a desktop browser — useful for admins who move across the airport floor during operations.

### 8.3.2 Offline Mode

Implementing local SQLite storage with synchronization would allow workers to continue operating in areas with poor connectivity. Task starts, checklist completions, and report submissions could be queued locally and synced when connectivity is restored.

### 8.3.3 Machine Learning for Delay Prediction

Historical task performance data could train models to predict delays based on factors such as:

- Unit availability at time of assignment
- Historical turnaround times for specific flight/stand combinations
- Weather data integration
- Time-of-day patterns

Predictions could be surfaced to supervisors during task assignment to inform unit selection.

### 8.3.4 Autonomous Ground Vehicle Integration

As airports adopt autonomous ground support equipment, GroundScope could integrate with AGV fleet management systems to automatically dispatch vehicles and track their status through the same task lifecycle.

### 8.3.5 Advanced Analytics and Reporting

Expanding the delay_analysis and flight_turnaround_summary tables with:

- Trend analysis across time periods (weekly, monthly, seasonal)
- Performance benchmarking across units and service types
- Exportable reports for stakeholders (PDF, CSV)
- Dashboard visualizations (charts, graphs, heat maps)

### 8.3.6 Multi-Airport Support

Extending the data model with an `airport_id` dimension would allow a single GroundScope deployment to serve multiple airports, each with its own service types, stands, units, and users.

### 8.3.7 Integration with Airport A-CDM Systems

Connecting to Eurocontrol-compliant A-CDM platforms would enable GroundScope to participate in the standardized turnaround milestone tracking (TOBT, TSAT) and contribute to airport-wide collaborative decision making.

### 8.3.8 Push Notification Enhancements

Beyond the current FCM integration, future work could include:

- Configurable notification preferences per user role
- In-app notification history with search and filter
- Notification grouping by flight or task
- Escalation notifications for overdue acknowledgments

---

### 8.3.9 Live GroundScope Vision Bridge

The most immediate extension is to implement the runtime service that connects GroundScope Vision to the live database. This involves deploying the model on a GPU (or TensorRT/edge device) for real-time inference, consuming each stand's RTSP camera feed, running BotSORT tracking to derive arrival/departure times, and writing the resulting `stand_events` and `delay_analysis` rows into Supabase. Once live, the system could automatically flag discrepancies between worker-reported and camera-observed task times, and alert when expected equipment fails to appear at a stand.

---

# References

---

## Academic Papers

[1] Dahanayaka, M., Prak, D., & Mes, M. (2026). From gate to runway: A systematic review of airport ground operations optimization. *Journal of Air Transport Management*, 135, 103013. https://doi.org/10.1016/j.jairtraman.2026.103013

[2] Zhou, P., Shen, Y., Zheng, Y., Zheng, Y., Guo, B., & Du, Y. (2025). A comprehensive review of ground support equipment scheduling for aircraft ground handling services. *Transportation Research Part E: Logistics and Transportation Review*, 203. https://doi.org/10.1016/j.tre.2025

[3] Tiur Basaria, F., et al. (2024). Trends of Automation in Airport Apron Area: A Systematic Literature Review. *HvA Research Database*.

[4] Eitrheim, M. H. R., Nordfjærn, T., Log, M. M., & Tørset, T. (2024). Towards solving the airport ground workforce dilemma: A literature review on hiring, scheduling, retention, and digitalization in the airport industry. *ScienceDirect*. https://doi.org/10.1016/j.jairtraman.2024

[5] Kabongo, P., Ramos, T., Ferreira Leite, A., Ghedini Ralha, C., & Li, W. A Multi-Agent Planning Model for Airport Ground Handling Management. *IEEE*.

[6] Wu, Y., Zhou, J., Xia, Y., Zhang, X., Cao, Z., & Zhang, J. Neural airport ground handling. *Singapore Management University*. https://ink.library.smu.edu.sg/sis_research/

[7] Systematic literature review on autonomous ground vehicles for airport operations: Challenges, risks, and technological innovations. (2025). *Mechanical Engineering for Society and Industry*. https://doi.org/10.31603/mesi.14635

---

## Commercial Systems

[8] INFORM Software. GS TeamWork — Smart Workforce Coordination for Agile Ground Operations. https://www.inform-software.com/en/lp/gs-teamwork

[9] Neural Lab. OpsAssist — AI Real-Time Task Assignment for Airport Ground Handling. https://neurallab.io/opsassist-sats/

[10] Naitec. Airport Collaborative Decision Making (A-CDM). https://www.naitec.aero/solutions/flights-and-resource-management/airport-collaborative-decision-making/

[11] Veovo. A-CDM Airport — Airport Collaborative Decision Making. https://veovo.com/platform/acdm

[12] IBS Software. iAirport Airport Collaborative Decision Making (ACDM). https://platform.softwareone.com/product/iairport-airport-collaborative-decision-making-acdm/

[13] TAV Technologies. TAMS and Generative AI — Total Airport Management Suite. https://tavtechnologies.aero/en-EN/review/pages/tams-generativeai

[14] EPG. AES Resource Management System — Aviation Execution Suite. https://epg.com/us/aviation/resource-management/

[15] AirportLabs. GCAM — Ground Handling Operations Platform. https://airportlabs.com/product-tours/gcam

[16] Shifton. Airport Ground Handling Operations and Dispatch Software. https://shifton.com/service/industries/airport-ground-handling/

[17] Ozion. Viargo — Ground Handling Operations Software. https://www.ozion.com/viargo

---

## Technical Documentation

[18] Supabase Documentation. https://supabase.com/docs

[19] Flutter Documentation. https://docs.flutter.dev

[20] AviationStack API Documentation. https://aviationstack.com/documentation

[21] Firebase Cloud Messaging Documentation. https://firebase.google.com/docs/cloud-messaging

[22] flutter_bloc Documentation. https://bloclibrary.dev

[23] easy_localization Documentation. https://pub.dev/packages/easy_localization

[24] Ultralytics. YOLO11 Documentation. https://docs.ultralytics.com

[25] Jocher, G., et al. Ultralytics YOLO (YOLO11). https://github.com/ultralytics/ultralytics

[26] Aharon, N., Orfaig, R., & Bobrovsky, B.-Z. (2022). BoT-SORT: Robust Associations Multi-Pedestrian Tracking. https://arxiv.org/abs/2206.14651

[27] ONNX Runtime Documentation. https://onnxruntime.ai/docs

---

# Appendix A: GroundScope Vision — Full Model Reference

The summary in Chapter 6 covers the model at a level appropriate to this report. The complete technical reference for the GroundScope Vision detector is maintained in the companion file **`AI_MODEL.md`**, which documents:

- The full layer-by-layer architecture (backbone layers 0–10, neck/head layers 11–23, detection-head internals, and scale configuration).
- The complete set of embedded training arguments extracted from the checkpoint.
- Verified environment and dependency versions.
- Inference recipes (image, video, webcam, CLI), ONNX export, and other export formats.
- Known issues and gotchas (checkpoint re-zip step, ONNX dependencies, CPU performance, version mismatch, path handling).

Refer to `AI_MODEL.md` for reproduction-level detail when re-running or extending the model.
