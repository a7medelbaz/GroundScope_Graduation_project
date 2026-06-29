# GroundScope — Admin Web Dashboard

> **Build Plan & Architecture Reference**
> This document is the single source of truth for building the GroundScope Admin Web Dashboard.
> It is written to be handed directly to an AI builder. Build phases **in order**. Each phase is self-contained and testable.

---

## 0. How To Use This Document (read first)

**For the human (project owner):**
- To change something, find the phase, edit the relevant section, and tell the AI: *"In Phase X, change/add/remove ..."*.
- Each phase has a **Goal**, **Build Steps**, **Data**, **UI Spec**, **Animations**, and **Done When** (acceptance checklist). You can edit any of these independently.
- Phases are numbered and independent enough that you can reorder, skip, or expand them.

**For the AI builder:**
- Build **one phase at a time**, in order. Do not start a later phase until the current one passes its **Done When** checklist.
- Never break the rules in [Section 7 — Global Rules](#7-global-rules-non-negotiable).
- Anything marked `🔖 REMINDER` is a deferred task the human must revisit later. Keep these visible — do not silently implement around them.
- After each phase, summarize what was built and confirm the **Done When** items.
- Do not modify the Flutter app. This web app only talks to the shared Supabase backend.

---

## 1. Project Overview

GroundScope is a real-time airport ground-services coordination system. A Flutter mobile app already serves three roles: **Admin**, **Supervisor**, and **Unit Manager (Worker)**, backed by Supabase (PostgreSQL + Auth + Storage + RLS).

This project adds a **web Admin Dashboard** that **complements** (does not replace) the mobile admin module. The admin uses the web for command-center work — live operations monitoring, analytics, bulk data management — and keeps the mobile app for quick actions on the go.

**Key principle:** The web dashboard is just another client on the **same Supabase project** as the mobile app. Anything the admin does on web is instantly visible to mobile users via the shared database, and vice versa. **No changes are made to the Flutter app.**

### 1.1 Decisions Locked

| Decision | Choice |
|---|---|
| Framework | **Next.js 14+ (App Router) + TypeScript** |
| Styling | **Tailwind CSS + shadcn/ui** |
| Animation | **Framer Motion** (light, fast, purposeful) |
| Database/Auth | **Supabase** — same project as mobile |
| Charts | **Recharts** |
| Tables | **TanStack Table v8** |
| Forms | **React Hook Form + Zod** validation |
| Hosting | **Vercel** |
| Languages | **English + Arabic (RTL)** — full parity |
| Theme | **Light + Dark toggle** — full parity |
| AviationStack API | **Live — mirror the existing Flutter integration** (see [Section 13](#13-aviationstack-reference--live-flight-import)) |
| Goal | Demo-quality now, production-ready foundation |
| Location | `c:\1_Flutter_Projects\GroundScope_Graduation_project\groundscope-admin\` (sibling to the Flutter app) |

---

## 2. Connection To Mobile App & Supabase

### 2.1 Shared Backend
- **Supabase URL** and **Anon Key** are the same values the Flutter app uses (in the Flutter `.env`). Copy them into the web app's `.env.local`.
- The anon key is safe to ship to the browser — security is enforced by **Row Level Security (RLS)** at the database level, not by hiding the key.

```
# groundscope-admin/.env.local
NEXT_PUBLIC_SUPABASE_URL=https://xegigwfjsxwpmgqyhijf.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<same anon key as the Flutter .env>

# AviationStack — the key ALREADY EXISTS in the Flutter app (AppConstants.aviationStackKey).
# Copy that same value here. See Section 13 for the full integration.
AVIATIONSTACK_API_KEY=<copy from Flutter AppConstants.aviationStackKey>
```

### 2.2 Two Supabase Clients (Next.js needs both)
- `lib/supabase/client.ts` — **browser** client. Used in Client Components for interactions and **Realtime** subscriptions.
- `lib/supabase/server.ts` — **server** client. Used in Server Components / route handlers to fetch data before render (fast, no spinner) and to read the auth session from cookies.

> Rule of thumb: load page data with the **server** client; use the **browser** client only for realtime and user interactions.

### 2.3 No Flutter Changes
Nothing in the Flutter app changes. Supabase treats every client identically. The two apps share only the database.

---

## 3. Design System (port from mobile)

Port the mobile design system so the web feels like the same product. Source of truth: `ground_scope/docs/design_system.md`.

### 3.1 Color Tokens → CSS Variables
Define both light and dark in `styles/globals.css` and expose them to Tailwind via `tailwind.config.ts`.

**Brand / Semantic (same hex as mobile):**
```css
:root {
  /* Brand */
  --primary-50:  #D5EDF7;
  --primary-100: #82CAE7;
  --primary-200: #2FA4D7;  /* main brand blue */
  --primary-300: #247DA4;
  --primary-400: #18526C;
  --secondary-200: #D12052; /* main pink/red */

  /* Semantic */
  --success: #22C55E;
  --warning: #F59E0B;
  --error:   #EF4444;
  --info:    #3B82F6;
}
```

**Theme-aware tokens** (mirror mobile `CustomColors`):

| Token | Light | Dark |
|---|---|---|
| `--text-primary` | `#000000` | `#FFFFFF` |
| `--text-secondary` | `#36394A` (grey600) | `#A4ACB9` (grey300) |
| `--text-hint` | `#818898` (grey400) | `#666D80` (grey500) |
| `--background` | `#F9FAFB` | `#121212` |
| `--background-secondary` | `#ECEFF3` (grey50) | `#262730` (grey800) |
| `--surface` | `#FFFFFF` | `#262730` (grey800) |
| `--surface-variant` | `#DFE1E7` (grey100) | `#272835` (grey700) |
| `--border` | `#C1C7D0` (grey200) | `#36394A` (grey600) |
| `--divider` | `#DFE1E7` (grey100) | `#272835` (grey700) |

**Status / severity / priority colors** (must match mobile exactly — used in badges everywhere):

| Domain | Value → Color |
|---|---|
| Task status | `in_progress`→primary-200 · `completed`→success · `pending`→warning · `assigned`→info · `paused`→secondary-200 · `cancelled`→text-disabled |
| Task priority | `critical`→error · `high`→secondary-200 · `medium`→warning · `low`→success |
| Report severity | `low`→success · `medium`→warning · `high`→secondary-200 · `critical`→error |
| Report status | `open`→warning · `acknowledged`→info · `in_progress`→primary-200 · `resolved`→success |
| Unit status | `available`→success · `busy`→warning · `offline`→text-disabled |
| Flight status | `scheduled`→info · `active`/`arrived`→primary-200 · `departed`→success · `cancelled`→text-disabled |

Centralize these in `lib/utils/status-colors.ts` — never hardcode a status color in a component.

### 3.2 Typography
- Font (EN): **Manrope**. Font (AR): **Tajawal**. Load via `next/font`.
- Web uses a standard responsive type scale (Tailwind `text-sm/base/lg/xl/2xl`). The mobile `flutter_screenutil` sizing does **not** carry over — web is naturally responsive. Keep weights consistent with mobile's feel: bold/extrabold for titles, light/regular for body.

### 3.3 Reusable UI Primitives (build once, in `components/ui/`)
Build these shared components early (Phase 3) and reuse everywhere:
`Button` (filled/outlined/text variants matching mobile), `Card`, `Badge` (status/severity/priority), `StatCard`, `DataTable` (TanStack wrapper), `SlideOverSheet` (for create/edit forms), `ConfirmDialog` (mirrors mobile `AppDialogs.showConfirm`), `Toast`, `EmptyState`, `ErrorState`, `LoadingState`, `FilterPills`, `SearchInput`, `PageHeader`.

---

## 4. Internationalization (English + Arabic, RTL)

- Library: **next-intl** (App Router friendly).
- Translation files: `messages/en.json` and `messages/ar.json`. Mirror the structure; every user-facing string lives here — **no hardcoded strings**.
- Locale switch persists (cookie). `<html dir>` switches between `ltr` (en) and `rtl` (ar).
- Use **logical CSS properties** (`ms-`/`me-`, `ps-`/`pe-`, `start`/`end`) so layouts mirror automatically in RTL. Avoid hardcoded `left`/`right`.
- Font switches with locale: Manrope for EN, Tajawal for AR.
- Date/number formatting via `Intl` with the active locale.

> Each phase below assumes all its strings are added to **both** `en.json` and `ar.json` and that the screen is verified in RTL.

---

## 5. Theme (Light + Dark)

- Use **next-themes** with `class` strategy (`.dark` on `<html>`).
- All colors come from the CSS variable tokens in [3.1](#31-color-tokens--css-variables) — components never reference a raw hex.
- Theme toggle lives in the topbar. Persists across reloads. Respects system preference on first visit.
- Every phase must be visually checked in **both** themes before it is "Done".

---

## 6. Folder Structure

```
groundscope-admin/
├── app/
│   ├── [locale]/                     # next-intl locale segment
│   │   ├── (auth)/login/page.tsx
│   │   └── (dashboard)/
│   │       ├── layout.tsx            # Sidebar + Topbar shell
│   │       ├── page.tsx              # Overview
│   │       ├── operations/page.tsx
│   │       ├── flights/page.tsx
│   │       ├── flights/[id]/page.tsx
│   │       ├── reports/page.tsx
│   │       ├── analytics/page.tsx
│   │       ├── service-types/page.tsx
│   │       ├── stands/page.tsx
│   │       ├── units/page.tsx
│   │       ├── units/[id]/page.tsx
│   │       └── users/page.tsx
│   └── api/
│       └── send-notification/route.ts   # 🔖 REMINDER: wire to FCM later
├── components/
│   ├── ui/            # primitives (Section 3.3)
│   ├── layout/        # Sidebar, Topbar, ThemeToggle, LocaleToggle
│   ├── charts/        # Recharts wrappers
│   ├── tables/        # column defs per entity
│   └── animations/    # shared Framer Motion variants
├── lib/
│   ├── supabase/      # client.ts, server.ts, middleware.ts
│   ├── types/         # database.ts (typed schema)
│   ├── queries/       # data-access functions per entity
│   └── utils/         # status-colors.ts, formatters, credentials.ts
├── messages/          # en.json, ar.json
├── styles/globals.css
├── tailwind.config.ts
├── middleware.ts      # auth gate + locale routing
└── .env.local
```

**Per-entity convention** (Service Types, Stands, Units, Users, Flights, Reports):
- `lib/queries/<entity>.ts` — all Supabase reads/writes for that entity (the "repo" layer; never query Supabase directly inside a component).
- `lib/types/database.ts` — the typed row shape.
- `components/tables/<entity>-columns.tsx` — TanStack column defs.
- `app/[locale]/(dashboard)/<entity>/page.tsx` — the screen.
- Create/edit forms live in a `SlideOverSheet`.

---

## 7. Global Rules (non-negotiable)

- ❌ No hardcoded colors — use the CSS variable tokens via Tailwind classes.
- ❌ No hardcoded user-facing strings — use `next-intl` keys in `en.json` **and** `ar.json`.
- ❌ No raw Supabase calls inside components — go through `lib/queries/*`.
- ❌ No hardcoded `left`/`right` — use logical properties so RTL mirrors.
- ❌ No status color logic inline — use `lib/utils/status-colors.ts`.
- ❌ No destructive action without a `ConfirmDialog`.
- ✅ Soft delete only — set `is_active = false`; never hard-delete rows.
- ✅ Every screen verified in: light + dark theme, and en + ar (RTL).
- ✅ Animations follow [Section 8](#8-animation-system) — nothing over 350ms, never block input.
- ✅ Server client for page data; browser client for realtime/interactions.
- ✅ All forms validated with Zod; show inline field errors.

---

## 8. Animation System (Framer Motion)

**Philosophy:** light, fast, purposeful. Animations confirm that something happened or is happening — never decoration, never blocking. **Max 350ms. Respect `prefers-reduced-motion`** (disable/shorten when set).

Define shared variants in `components/animations/` and reuse:

| Element | Animation | Timing |
|---|---|---|
| Page content on navigate | fade in (+ 4px rise) | 200ms ease-out |
| Sidebar active indicator | slide between links (layoutId) | 250ms spring |
| SlideOverSheet (forms) | slide in from inline-end | 300ms ease-out |
| Stat cards (Overview) | fade + rise, **staggered 80ms** | 250ms each |
| Stat numbers | count-up | 800ms |
| Table rows on load | stagger fade-in | 30ms/row, cap total |
| Operations task cards moving column | layout animation (auto-reposition) | 300ms spring |
| Active task card | faint pulsing ring (loop) | 2s loop |
| New realtime card | slide in from column top | 250ms |
| Button press | scale to 0.97 | 100ms |
| Card hover | shadow deepen + 2px rise | 150ms |
| Badges on load | scale in 0.9→1 | 150ms |
| ConfirmDialog | scale 0.95→1 + fade | 200ms |
| Toast | slide up from bottom-end + fade out | 250ms |

**Do NOT:** infinite animated skeletons (one pulse then hold), full-page slide transitions, parallax, 3D, particles, anything > 350ms.

---

## 9. Database Reference (quick map)

Full schema: `ground_scope/docs/DATABASE.md`. Tables this dashboard reads/writes:

| Table | Dashboard usage |
|---|---|
| `users` | Users screen (create supervisors/unit managers, deactivate) |
| `service_types` | Service Types CRUD |
| `units` | Units CRUD |
| `unit_members` | Unit detail — crew CRUD |
| `stands` | Stands CRUD |
| `flights` | Flights list/detail, manual entry, stand assignment, API import (mocked) |
| `tasks` | Operations monitor (live), flight detail (read), service requests (pending = task with no unit) |
| `task_checklists` | Task detail panel (read) |
| `task_pauses` | Task detail panel (read) |
| `reports` | Reports screen — acknowledge/resolve |
| `notifications` | 🔖 REMINDER: trigger via FCM later |
| `delay_analysis` | Analytics → delay tab |
| `flight_turnaround_summary` | Analytics → turnaround tab |
| `cameras` / `stand_events` | Optional, future — not in MVP |

> **Service request model note (match mobile):** The mobile supervisor module treats a "pending service request" as a **task with `status='pending'` and `unit_id IS NULL`**. The system reference also documents a `flight_service_requests` table. **Before building Phase 9, confirm with the project owner which model is live in the database** (see `🔖 REMINDER` in Phase 9). The dashboard must match whatever the mobile app actually uses so the two stay in sync.

---

# BUILD PHASES

> Build in order. Each phase ends with a **Done When** checklist. Do not advance until it passes.

---

## Phase 1 — Project Foundation

**Goal:** A running Next.js app that connects to Supabase, with the design system, i18n, theming, and types wired — but no real screens yet.

**Build Steps:**
1. Scaffold Next.js 14 (App Router, TypeScript, ESLint) in `groundscope-admin/`.
2. Install: `tailwindcss`, `@supabase/supabase-js`, `@supabase/ssr`, `framer-motion`, `next-intl`, `next-themes`, `@tanstack/react-table`, `recharts`, `react-hook-form`, `zod`, shadcn/ui.
3. Configure Tailwind; add all color tokens (light + dark) from [3.1] as CSS variables in `globals.css`; map them in `tailwind.config.ts`.
4. Load fonts (Manrope + Tajawal) via `next/font`.
5. Create `.env.local` with the shared Supabase URL + anon key. Add the AviationStack `🔖 REMINDER` comment.
6. Create `lib/supabase/client.ts` and `lib/supabase/server.ts`.
7. Create `lib/types/database.ts` with typed row interfaces for **every** table in [Section 9] (and their enums).
8. Set up next-intl with `messages/en.json` + `messages/ar.json` (start with app name + nav labels), `[locale]` routing, and `<html dir>` switching.
9. Set up next-themes (`.dark` class strategy).
10. Create `lib/utils/status-colors.ts` with all mappings from [3.1].

**Done When:**
- [ ] App runs locally with no errors.
- [ ] A test query (e.g. count `service_types`) returns real data from Supabase.
- [ ] Toggling locale flips `dir` between ltr/rtl; toggling theme flips light/dark.
- [ ] All DB tables have TypeScript types.

---

## Phase 2 — Authentication

**Goal:** Admin-only login with a session gate.

**Build Steps:**
1. `/login` page — email + password form (React Hook Form + Zod), GroundScope branding.
2. On submit: `supabase.auth.signInWithPassword`. Then fetch the row from `users` by `auth_id`.
3. If `role !== 'admin'` → sign out + show "Admins only" error. Reject non-admins.
4. `middleware.ts` — verify session on every `(dashboard)` route; redirect unauthenticated users to `/login`. Handle locale routing too.
5. Session/user context available to all dashboard pages (current admin's name/id).
6. Logout action — clears session, returns to `/login`.

**Data:** `auth` (Supabase Auth) + `users` (role check).

**Animations:** login card fade+rise on mount; button press scale; error toast slide-up.

**Done When:**
- [ ] Admin logs in → lands on dashboard. Non-admin is rejected with a clear message.
- [ ] Visiting any dashboard route while logged out redirects to `/login`.
- [ ] Logout works and clears the session.
- [ ] Login screen verified in light/dark + en/ar.

---

## Phase 3 — Layout Shell + UI Primitives

**Goal:** The permanent app frame and the reusable components every later phase depends on.

**Build Steps:**
1. Build the UI primitives listed in [3.3] in `components/ui/`.
2. `(dashboard)/layout.tsx` with:
   - **Sidebar** (start-aligned, RTL-aware): logo + "Admin Dashboard"; nav groups —
     `Overview` (/), `Operations`, `Flights`, `Reports`, `Analytics`; divider "Master Data"; `Service Types`, `Stands`, `Units`, `Users`. Active link highlighted (animated indicator). Logout at the bottom.
   - **Topbar**: current page title, admin name, theme toggle, locale toggle, notification bell (display only).
   - Responsive: sidebar collapses to a drawer with a hamburger on narrow screens.
3. `PageHeader` component (title + optional action button) used by every page.

**Animations:** sidebar active indicator slides (`layoutId`); page content fades in on navigate; drawer slides in.

**Done When:**
- [ ] All nav links route correctly; active state animates.
- [ ] Theme + locale toggles work from the topbar and persist.
- [ ] Layout mirrors correctly in RTL and looks right in both themes.
- [ ] Primitives render in a quick visual sandbox.

---

## Phase 4 — Overview Dashboard

**Goal:** Live homepage showing the operation's health.

**Build Steps:**
1. Four `StatCard`s (count-up numbers, staggered entrance):
   - Flights today — `flights` where `scheduled_arrival` within today.
   - Active tasks — `tasks` where `status='in_progress'`.
   - Pending service requests — `tasks` where `status='pending'` AND `unit_id IS NULL`.
   - Open reports — `reports` where `status='open'`.
2. Recent Flights table (last 10) → rows link to flight detail.
3. Open Reports list (last 5) with severity badges → link to reports.
4. **Realtime:** browser-client subscriptions on `tasks` and `reports` update the stat cards live.

**Data:** `flights`, `tasks`, `reports`.

**Animations:** staggered stat cards; count-up numbers; table rows stagger-fade.

**Done When:**
- [ ] All four stats show correct live counts.
- [ ] Changing a task/report status (e.g. from the mobile app) updates the cards without refresh.
- [ ] Verified in both themes + locales.

---

## Phase 5 — Service Types (CRUD)

**Goal:** Manage service categories. (First full CRUD — establishes the reusable pattern.)

**Build Steps:**
1. List page: `DataTable` — Name, Description, Default Duration, Active, Created, Actions. Search by name. "Add" opens `SlideOverSheet`.
2. Create/Edit sheet (RHF + Zod): Name (required, unique), Description, Default Duration (min), Icon, Active toggle.
3. Toggle Active = soft delete (`is_active=false`) behind `ConfirmDialog`. Inactive rows dimmed.
4. All reads/writes in `lib/queries/service-types.ts`.

**Data:** `service_types`.

**Done When:**
- [ ] Create, edit, and deactivate all work and persist to Supabase.
- [ ] Search filters correctly; inactive rows dimmed; no hard deletes.
- [ ] Strings in en/ar; verified both themes.

---

## Phase 6 — Stands (CRUD)

**Goal:** Manage airport parking positions.

**Build Steps:**
1. List page: Code, Terminal, Compatible Aircraft, Has Camera, Active, Actions. Search by code/terminal.
2. Create/Edit sheet: Code (unique), Terminal, Compatible Aircraft (multi-tag input), Has Camera toggle, Active toggle.
3. Soft delete + confirm. Queries in `lib/queries/stands.ts`.

**Data:** `stands`.

**Done When:**
- [ ] CRUD works and persists; tag input saves `text[]` correctly.
- [ ] Strings in en/ar; both themes verified.

---

## Phase 7 — Units + Unit Members (CRUD)

**Goal:** Manage ground service teams and their crew.

**Build Steps:**
1. Units list: Name, Service Type, Status badge, Shift, Member count, Actions. Filter by service type + status.
2. Create/Edit Unit sheet: Name, Service Type (dropdown from `service_types`), Compatible Aircraft (tags), Shift Start, Shift End, Status.
3. Unit Detail page (`units/[id]`): unit info header + Unit Members table (Name, Position, Phone, National ID, Active, Actions).
4. Member create/edit sheet: Full Name, Position (`driver`/`technician`/`helper`/`safety_officer`), Phone, National ID, Photo upload → **Supabase Storage**, Active toggle.
5. Soft delete for units and members. Queries in `lib/queries/units.ts`, `lib/queries/unit-members.ts`.

**Data:** `units`, `unit_members`, `service_types`, Supabase Storage.

**Done When:**
- [ ] Unit CRUD + member CRUD work and persist.
- [ ] Photo upload stores to Storage and displays.
- [ ] Filters work; en/ar + both themes verified.

---

## Phase 8 — Users (Supervisors & Unit Managers)

**Goal:** Create and manage app user accounts.

**Build Steps:**
1. Users list: Name, Email, Role badge, Linked to (service type or unit), Active, Created, Actions. Filter by role.
2. "Add Supervisor" sheet: Full Name, Phone, Service Type (required). **Email and password are auto-generated — NOT entered by the admin.** Port `lib/core/utils/credentials_generator.dart` → `lib/utils/credentials.ts`, matching its exact logic:
   - Supervisor email = `supervisor.{serviceTypeSlug}@groundscope.com`
   - Unit Manager email = `manager.{unitSlug}@groundscope.com`
   - Slug = lowercase, strip everything except `a-z0-9`
   - Password = `GroundScope{4 random digits}{1 special from !@#$%}`
   On submit: create Supabase Auth user with the generated email/password → insert `users` row (`role='supervisor'`, `service_type_id`).
3. "Add Unit Manager" sheet: same, but links a Unit (`role='unit_manager'`, `unit_id`) and uses the manager email pattern.
4. After creation: **Credentials Sheet** (name, generated email, generated password, copy-all). Shown once; not stored in plaintext.
5. Deactivate user: `is_active=false` + confirm.
6. Queries in `lib/queries/users.ts`.

> `🔖 REMINDER` — Creating an Auth user from the browser may require a **Supabase service-role key** (server-only) or an **Edge Function**. Decide the secure approach during this phase; never expose the service-role key to the browser. If blocked, implement via a server route handler.

**Data:** Supabase Auth + `users`, `service_types`, `units`.

**Done When:**
- [ ] Can create a supervisor and a unit manager; both can log into the **mobile app** with the generated credentials.
- [ ] Credentials sheet shows once with copy.
- [ ] Deactivate prevents login; en/ar + both themes verified.

---

## Phase 9 — Flights + Flight Detail + Service Requests

**Goal:** Full flight lifecycle — **live API import** (mirrors Flutter), manual entry, stand assignment, and dispatching service requests to supervisors.

> `🔖 REMINDER` — **Before building, confirm the service-request model** with the project owner (see [Section 9] note): is a service request a `task` with `unit_id IS NULL`, or a row in `flight_service_requests`? Build to match the live mobile behavior.

**Build Steps:**
1. Flights list: Flight No., Airline, Origin→Destination, Aircraft, Status badge, Stand, Scheduled Arrival, Actions. Search (number/airline) + filters (status, date range).
2. **Import from API — LIVE (mirror Flutter):** Port the existing `lib/core/shared/data/remote/aviation_stack_remote_ds.dart` exactly. See [Section 13](#13-aviationstack-reference--live-flight-import) for the full spec. In short: "Import Today's Flights" button → fetch arrivals + departures from `https://api.aviationstack.com/v1/timetable`, dedupe codeshares, map to the flights table, insert with `api_source='aviationstack'`. **Do this server-side** (Next.js route handler) so the API key stays off the browser. Show count imported on success.
3. "Add Manually" sheet: Flight Number, Airline, Origin, Destination, Aircraft Type, Registration, Scheduled Arrival, Scheduled Departure, Pax Count, Stand (dropdown), Status.
4. Flight Detail (`flights/[id]`):
   - Flight info + edit-stand action.
   - **Service Requests** section: list existing + "Send Service Request" sheet (Service Type dropdown + optional notes) → creates the request per the confirmed model → matching supervisor sees it on mobile instantly.
   - **Tasks** section: tasks linked to this flight (read-only).
   - **Turnaround** summary (from `flight_turnaround_summary`).
5. Queries in `lib/queries/flights.ts`, `lib/queries/service-requests.ts`.

**Data:** `flights`, `stands`, `service_types`, `tasks`/`flight_service_requests`, `flight_turnaround_summary`.

**Done When:**
- [ ] Live AviationStack import inserts real flights (server-side, key not exposed); manual entry works; stand assignment persists.
- [ ] Imported flights match what the Flutter app imports (same endpoint, dedup, mapping).
- [ ] Sending a service request appears for the correct supervisor on mobile.
- [ ] en/ar + both themes verified.

---

## Phase 10 — Operations Monitor (Live Board)

**Goal:** The real-time command center — all tasks across all service types, live. The dashboard's flagship feature.

**Build Steps:**
1. Kanban-style board with status columns: **Pending**, **In Progress**, **Paused**, **Completed (today)**, **Cancelled**.
2. Top filters: service type (all + each), status, search by flight number.
3. Task card: flight number, service type icon, unit name, priority badge, scheduled vs actual times, delay indicator (red if overdue).
4. **Realtime:** browser-client subscription on `tasks`; cards auto-move between columns as workers update status on mobile (layout animation). New cards slide in.
5. Click card → `SlideOverSheet` task detail: checklist progress (`task_checklists`), pause history (`task_pauses`), unit info, notes.

**Data:** `tasks` (+ joins: `flights`, `units`, `service_types`, `task_checklists`, `task_pauses`).

> Supabase `.stream()` does not support joins — do an initial `.select('*, related(*)')` fetch, then merge realtime row updates into existing joined state (same pattern the mobile supervisor module uses).

**Animations:** cards reposition on status change (spring layout); active cards pulse faintly; new cards slide in.

**Done When:**
- [ ] All tasks across all service types show in correct columns.
- [ ] Updating a task on mobile moves its card live, no refresh.
- [ ] Filters + detail panel work; en/ar + both themes verified.

---

## Phase 11 — Reports

**Goal:** Manage incident reports across all units.

**Build Steps:**
1. Reports table: Flight, Unit, Service Type, Type, Severity badge, Status badge, Reported by, Date, Actions. Filters: severity, status, service type, date range.
2. Report detail panel: description, type, severity, photo (from Storage), timeline (submitted/acknowledged/resolved with who+when).
3. Actions (each behind `ConfirmDialog`):
   - Acknowledge → `status='acknowledged'`, `acknowledged_by`, `acknowledged_at`.
   - Resolve → `status='resolved'`, `resolved_by`, `resolved_at`.
   - Writes to the same `reports` table the mobile supervisor reads — status syncs to mobile instantly.
4. "Export CSV" of the current filtered list.
5. Queries in `lib/queries/reports.ts`.

**Data:** `reports` (+ joins for flight/unit/service type names).

**Done When:**
- [ ] Filters work; photo displays; acknowledge/resolve persist and sync to mobile.
- [ ] CSV export reflects active filters.
- [ ] en/ar + both themes verified.

---

## Phase 12 — Analytics

**Goal:** Performance insight across delays, turnarounds, and units.

**Build Steps:** Tabbed page.
1. **Delay Analysis:** bar chart of avg start delay per service type; bar chart scheduled vs actual duration; table of worst-delayed tasks (sortable). Global date-range filter. Source: `delay_analysis`.
2. **Turnaround Summary:** table of flights — number, arrival, departure, total turnaround minutes, completed/total tasks, had-delays, had-reports; color-coded (green/amber/red); rows link to flight detail. Source: `flight_turnaround_summary`.
3. **Unit Performance:** per-unit table — tasks assigned/completed/cancelled, avg start delay, avg duration; filter by service type. Computed from `tasks` + `delay_analysis`.

**Data:** `delay_analysis`, `flight_turnaround_summary`, `tasks`, `units`.

**Animations:** charts animate in on load (Recharts built-in, kept subtle); tab switch fades content.

**Done When:**
- [ ] All three tabs show correct data and respect the date filter.
- [ ] Charts render in both themes (axis/grid colors theme-aware).
- [ ] en/ar + both themes verified.

---

## 10. Deferred Items (🔖 REMINDERS — revisit before production)

| # | Item | Where | Action needed |
|---|---|---|---|
| 1 | **AviationStack** key must be copied | Phase 9 | The integration is LIVE, not mocked — see [Section 13](#13-aviationstack-reference--live-flight-import). Copy the existing key from Flutter's `AppConstants.aviationStackKey` into `AVIATIONSTACK_API_KEY` and keep the call server-side. |
| 2 | **FCM push from web** not wired | Phase 9/11, `lib/queries/notifications.ts` | Web calls the **same** `send-notification` Edge Function Flutter uses — see [Section 12 — FCM Reference](#12-fcm-reference--how-notifications-work). First: verify the Edge Function is deployed in the Supabase dashboard (Functions tab). If missing, deploy it — the expected code is documented in Section 12. |
| 3 | **Auth user creation** needs secure path | Phase 8 | Use server-side service-role key or Edge Function; never expose service-role key to browser. |
| 4 | **Service-request model** must be confirmed | Phase 9 | Confirm task-with-null-unit vs `flight_service_requests` table; match mobile. |
| 5 | **RLS policies** for admin web access | All phases | Verify admin role has the RLS permissions needed for every read/write used here. |
| 6 | **Cameras / stand_events** not in MVP | Future | Optional live video / event timeline feature later. |

---

## 11. Build Order Summary

| Phase | Deliverable | Rough size |
|---|---|---|
| 1 | Foundation + Supabase + i18n + theme + types | 1 session |
| 2 | Auth (login + admin gate) | 1 session |
| 3 | Layout shell + UI primitives | 1 session |
| 4 | Overview (live stats) | 1 session |
| 5 | Service Types CRUD | 1 session |
| 6 | Stands CRUD | ½ session |
| 7 | Units + Members CRUD | 1–2 sessions |
| 8 | Users (create accounts) | 1 session |
| 9 | Flights + detail + service requests | 2 sessions |
| 10 | Operations Monitor (live) | 1–2 sessions |
| 11 | Reports | 1 session |
| 12 | Analytics | 1–2 sessions |

---

---

## 12. FCM Reference — How Notifications Work

> Read this before building Phase 9 or Phase 11. It explains the full notification system so the AI builder understands exactly what to call and when.

### 12.1 How Flutter Sends Notifications (existing flow)

The mobile app's notification flow has four layers:

```
Flutter feature code
  → NotificationSender.send()           (lib/core/notifications/service/notification_sender.dart)
    → NotificationRemoteDs.sendNotification()  (lib/core/notifications/data/remote/notification_remote_ds.dart)
      → supabase.functions.invoke('send-notification')
        → Supabase Edge Function (lives in Supabase dashboard, NOT in this repo)
          → reads users.fcm_token for the target user
          → POSTs to Firebase FCM HTTP API
          → inserts row in notifications table
          → target phone receives the push
```

**Key fact:** Flutter never talks to Firebase FCM directly. It calls a Supabase Edge Function called `send-notification` which does all FCM work server-side. The web dashboard calls the **exact same Edge Function** — no new FCM code is needed.

### 12.2 The Five Notification Types

Defined in `notification_model.dart`. Use these exact strings in the `type` field:

| String | When used | Color on mobile |
|---|---|---|
| `task_assigned` | Supervisor receives a service request / task | Blue (`#2FA4D7`) |
| `alert` | General warning | Red (`#EF4444`) |
| `delay` | A task is running past its scheduled end | Amber (`#F59E0B`) |
| `report` | New incident report filed | Pink (`#D12052`) |
| `flight_landed` | Flight status changed to active/arrived | Green (`#22C55E`) |

### 12.3 The Edge Function (verify before Phase 9)

The function `send-notification` lives in your **Supabase project dashboard → Edge Functions**. It is NOT committed to this repo.

**🔖 REMINDER — Before building Phase 9:**
1. Open Supabase dashboard → Edge Functions.
2. Confirm `send-notification` is listed and active.
3. If it is missing, deploy it using the reference code below via the Supabase CLI:
   ```bash
   supabase functions deploy send-notification
   ```

> ⚠️ **Do not write a new Edge Function from the snippet below without checking the real one first.** Your `send-notification` function already exists and works, so it already uses the current **FCM HTTP v1 API** (`https://fcm.googleapis.com/v1/projects/{project-id}/messages:send` with an OAuth2 bearer token from a Firebase service account). The legacy endpoint (`fcm.googleapis.com/fcm/send` + `Authorization: key=...`) shown below was **shut down by Google in June 2024** and will not work for a new function. The snippet is included only to illustrate the **shape** (look up token → insert row → push). Pull the real implementation from your Supabase dashboard and treat that as the source of truth.

**Illustrative shape only — NOT current FCM API** (`supabase/functions/send-notification/index.ts`):

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  const { user_id, title, body, type, reference_id, reference_type } = await req.json()

  // Service-role client — can read fcm_token bypassing RLS. Safe here (server-side only).
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // 1. Look up the target user's FCM token
  const { data: user } = await supabase
    .from('users')
    .select('fcm_token')
    .eq('id', user_id)
    .single()

  // 2. Insert notification row (visible in the user's in-app notification list)
  await supabase.from('notifications').insert({
    user_id,
    title,
    body,
    type,
    reference_id,
    reference_type,
    is_read: false,
    sent_via_fcm: !!user?.fcm_token,
  })

  // 3. Send FCM push to the device (only if token exists)
  // ⚠️ DEPRECATED ENDPOINT — the real function uses FCM HTTP v1 (see warning above).
  if (user?.fcm_token) {
    await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Authorization': `key=${Deno.env.get('FCM_SERVER_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        to: user.fcm_token,
        notification: { title, body },
        data: { type, reference_id, reference_type },
      }),
    })
  }

  return new Response(JSON.stringify({ ok: true }), { status: 200 })
})
```

> The Edge Function needs two environment secrets set in the Supabase dashboard:
> `SUPABASE_SERVICE_ROLE_KEY` and `FCM_SERVER_KEY` (from Firebase Console → Project Settings → Cloud Messaging → Server key).

### 12.4 The Web Query Function (build this in `lib/queries/notifications.ts`)

This is the only notification code the web dashboard needs. It mirrors Flutter's `NotificationRemoteDs.sendNotification()` exactly.

```typescript
// lib/queries/notifications.ts

import { createBrowserClient } from '@supabase/ssr'

export async function sendNotification({
  userId,
  title,
  body,
  type,
  referenceId,
  referenceType,
}: {
  userId: string
  title: string
  body: string
  type: 'task_assigned' | 'alert' | 'delay' | 'report' | 'flight_landed'
  referenceId?: string
  referenceType?: string
}) {
  const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )

  const { error } = await supabase.functions.invoke('send-notification', {
    body: {
      user_id: userId,
      title,
      body,
      type,
      reference_id: referenceId,
      reference_type: referenceType,
    },
  })

  if (error) throw error
}
```

> Always call this in a `try/catch` and show a toast on error. A failed notification must never block the main action (same pattern as Flutter's `NotificationSender` — it silent-fails).
>
> ⚠️ **`reference_id` and `reference_type` are `NOT NULL` in the `notifications` table** ([DATABASE.md:379-380](DATABASE.md)). The TypeScript signature marks them optional to mirror Flutter, but every real call site **must** pass both — all three moments in §12.5 do. If you ever send a notification with no reference, give it a sensible non-null reference (e.g. the flight id) rather than omitting it, or the insert in the Edge Function will fail.

### 12.5 The Three Moments the Web Sends Notifications

**Moment 1 — Admin sends a service request (Phase 9)**

Trigger: admin clicks "Send Service Request" on a flight detail page.

```typescript
await sendNotification({
  userId: fuelingSupervisorId,       // supervisor linked to the chosen service type
  title: 'New Service Request',
  body: `Flight ${flightNumber} requires ${serviceTypeName} at Stand ${standCode}`,
  type: 'task_assigned',
  referenceId: taskId,               // the created task/request id
  referenceType: 'task',
})
```

**Moment 2 — Admin resolves a report (Phase 11)**

Trigger: admin clicks "Resolve" on an incident report (after ConfirmDialog).

```typescript
await sendNotification({
  userId: report.reportedBy,         // the worker who filed the report
  title: 'Report Resolved',
  body: `Your incident report for flight ${flightNumber} has been resolved`,
  type: 'report',
  referenceId: reportId,
  referenceType: 'report',
})
```

**Moment 3 — Admin marks a flight as arrived/active (Phase 9)**

Trigger: admin changes a flight's status to `active` (flight has landed).

```typescript
// Send to every supervisor who has a pending request for this flight
for (const supervisorId of affectedSupervisorIds) {
  await sendNotification({
    userId: supervisorId,
    title: 'Flight Landed',
    body: `${flightNumber} has arrived at Stand ${standCode}. Operations starting.`,
    type: 'flight_landed',
    referenceId: flightId,
    referenceType: 'flight',
  })
}
```

### 12.6 Full Flow Diagram

```
Web Dashboard (Next.js, browser)
  │
  │  admin action (send request / resolve report / mark flight arrived)
  ▼
sendNotification() — lib/queries/notifications.ts
  │
  │  supabase.functions.invoke('send-notification', { body: {...} })
  ▼
Supabase Edge Function  ←── same function Flutter already calls
  │
  ├──► inserts row in notifications table
  │        │
  │        └──► supervisor/worker Notifications tab (realtime stream) updates live
  │
  └──► Firebase FCM HTTP API  ←── uses FCM_SERVER_KEY (secret, server-side only)
           │
           └──► target device (Android / iOS) receives push notification
```

---

---

## 13. AviationStack Reference — Live Flight Import

> Read before building Phase 9. The Flutter app already has a complete, working AviationStack integration. The web must **mirror it**, not reinvent it. Source of truth: `lib/core/shared/data/remote/aviation_stack_remote_ds.dart`.

### 13.1 The Endpoint & Params (exact)

```
GET https://api.aviationstack.com/v1/timetable
  ?access_key={AVIATIONSTACK_API_KEY}   // same key as Flutter's AppConstants.aviationStackKey
  &iataCode={AIRPORT_IATA_CODE}         // same as Flutter's AppConstants.airportIataCode
  &type=arrival | departure             // call BOTH, separately
```

> ⚠️ The endpoint is `/v1/timetable`, **not** `/v1/flights`. Connect timeout 30s, receive timeout 30s.

### 13.2 The Logic (mirror exactly)

1. Fetch `type=arrival` and `type=departure` in two calls.
2. From each response, take `data[]`. **Skip** any item where `codeshared != null` (drops duplicate codeshare rows) and any item with an empty `flight.iataNumber`.
3. **Deduplicate** the combined list by key = `{externalId}_{flightType}` (arrival vs departure).
4. Sort by scheduled arrival ascending.
5. Insert into the `flights` table with `api_source = 'aviationstack'`.

### 13.3 Field Mapping (API → flights table)

| flights column | API source field |
|---|---|
| `flight_number` | `flight.iataNumber` |
| `airline` | `airline.name` |
| `origin` | `departure.iataCode` |
| `destination` | `arrival.iataCode` |
| `aircraft_type` | `aircraft.icaoCode` |
| `aircraft_registration` | `aircraft.regNumber` |
| `scheduled_arrival` | arrival/departure `scheduledTime` (parsed) |
| `estimated_arrival` | `estimatedTime` (parsed) |
| `actual_arrival` | `actualTime` (parsed) |
| `external_id` | `flight.iataNumber` |
| `api_source` | literal `'aviationstack'` |

**Status mapping** (`item.status` → flight status): `scheduled`→`scheduled`, `active`→`landed`, `cancelled`→`cancelled`, anything else→`scheduled`.

### 13.4 Rate Limits & Errors (handle like Flutter)
- HTTP **429** → surface a clear "API rate limit exceeded" message (don't retry in a loop).
- Connection/receive timeout → "connection timeout" message.
- The free AviationStack tier is rate-limited — expect 429s during testing.

### 13.5 Security — keep the key server-side
Flutter ships the key in the app, but the web **must not** expose it to the browser. Do the AviationStack fetch in a **Next.js route handler** (`app/api/import-flights/route.ts`) or a Supabase Edge Function. The browser calls your route; your route calls AviationStack with the key from a server-only env var. The `AVIATIONSTACK_API_KEY` in `.env.local` must **not** have the `NEXT_PUBLIC_` prefix.

---

*GroundScope Admin Web Dashboard — Build Plan · v1.0 · Companion to `GroundScope_System_Reference.md`, `DATABASE.md`, and `design_system.md`.*