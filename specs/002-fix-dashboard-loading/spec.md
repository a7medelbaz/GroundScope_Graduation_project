# Feature Specification: Supervisor Dashboard Loading Failure Recovery

**Feature Branch**: `002-fix-dashboard-loading`

**Created**: 2026-05-18

**Status**: Draft

**Input**: User description: "Fix dashboard loading failure for supervisor dashboard screen. Investigate API failures, auth state, query handling, and loading/error recovery."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Reliable Dashboard Load on First Open (Priority: P1)

A supervisor opens the app after logging in. The dashboard loads all stat cards and the live task summary. If the backend is temporarily unavailable, a clear error message appears with a retry button — the supervisor is never left staring at a spinner indefinitely.

**Why this priority**: This is the first screen every supervisor sees. A blank or stuck dashboard destroys trust in the app and makes the supervisor unable to oversee operations.

**Independent Test**: Launch app as supervisor → dashboard stat cards appear within 5 seconds; kill network before opening → error message with retry button appears instead of infinite spinner.

**Acceptance Scenarios**:

1. **Given** a supervisor with a valid session opens the dashboard, **When** all backend queries succeed, **Then** all four stat cards and the task progress bar show real data within 5 seconds.
2. **Given** a supervisor opens the dashboard with no internet, **When** the data fetch fails, **Then** an error message and a "Retry" button appear; no spinner persists beyond 10 seconds.
3. **Given** the dashboard shows an error, **When** the supervisor taps Retry, **Then** the screen attempts to reload and either shows data or a fresh error — it does not get stuck.
4. **Given** a supervisor pulls down to refresh, **When** the refresh completes (success or failure), **Then** the pull-to-refresh indicator dismisses; it never hangs.

---

### User Story 2 — Session Expiry Handled Gracefully (Priority: P1)

When a supervisor's session has expired (e.g., after leaving the app overnight), the dashboard detects the expired auth token, automatically redirects to the login screen, and does not display a generic "server error" or a frozen spinner.

**Why this priority**: Session expiry is a near-daily occurrence. An unhandled auth failure sends supervisors to a broken screen with a confusing error, causing them to force-quit the app or contact support.

**Independent Test**: Expire the session token manually (or wait for natural expiry) → reopen app → user is taken to login screen with a "session expired, please sign in" message, not a broken dashboard.

**Acceptance Scenarios**:

1. **Given** a supervisor's session has expired, **When** the dashboard tries to load data, **Then** the app navigates to the login screen and shows a "Session expired, please sign in again" message.
2. **Given** the dashboard receives an authentication error from any query, **When** that error is classified as a session/token problem, **Then** the logout flow is triggered and the user lands on login — not on a raw error card.
3. **Given** a supervisor is actively using the dashboard and their token expires mid-session, **When** they pull to refresh, **Then** they are redirected to login with an explanation, not a silent failure.

---

### User Story 3 — Partial Data Shown When Some Queries Fail (Priority: P2)

When some dashboard queries succeed and others fail (e.g., the task summary loads but the delayed-tasks count fails due to a permission issue on that table), the dashboard shows the data it has and degrades gracefully — displaying a placeholder for the failed sections rather than failing the entire screen.

**Why this priority**: Currently one failed query out of five kills the whole dashboard. Partial data is far more useful than a blank screen, especially during maintenance windows or incremental RLS policy rollouts.

**Independent Test**: Restrict read access on the `reports` table → open dashboard → stat cards for units, tasks, and active data appear normally; the "Reports Today" card shows "—" with a subtle warning indicator, but the rest of the dashboard is fully functional.

**Acceptance Scenarios**:

1. **Given** one stat card query fails, **When** the others succeed, **Then** the failed card shows "—" and the remaining three cards show live data.
2. **Given** the task summary query fails, **When** stat cards succeed, **Then** stat cards show data and the progress bar shows an empty/unavailable state — the error does not cascade.
3. **Given** all queries fail, **When** the supervisor views the dashboard, **Then** the full-screen error state with retry is shown (existing behavior preserved).

---

### User Story 4 — Informative Error Messages (Priority: P3)

When the dashboard fails to load, the error message tells the supervisor something actionable — "You're offline", "You don't have permission — contact your admin", or "Something went wrong, try again" — rather than a raw technical string or a blank error card.

**Why this priority**: Supervisors are operational staff, not developers. A generic "Unknown error" is as useless as no message at all. Accurate messages prevent unnecessary escalations.

**Independent Test**: Simulate each failure type (no internet, permission denied, server error) → verify each shows a distinct, human-readable message in both English and Arabic.

**Acceptance Scenarios**:

1. **Given** the device has no internet, **When** the dashboard fails to load, **Then** the error message reads "No internet connection. Check your network and retry."
2. **Given** the query fails due to a permission problem, **When** the dashboard displays the error, **Then** the message reads "Access denied. Contact your administrator."
3. **Given** the query fails due to an unknown server error, **When** the dashboard displays the error, **Then** the message reads "Something went wrong. Please try again."
4. **Given** the app is in Arabic, **When** any error is shown, **Then** the message is displayed in Arabic.

---

### Edge Cases

- What happens when the dashboard is loaded while the device is transitioning from offline to online (flaky network)?
- What happens if a query returns data but parsing fails (e.g., a field in the backend schema changes type)?
- What happens if `Future.wait` partially resolves before a query throws — are there memory leaks or dangling subscriptions?
- What happens if the supervisor force-quits and reopens the app while the previous load was in progress?
- What happens when a supervisor has valid auth but zero permission on every table (RLS fully locked)?
- What happens if `loadDashboard()` is called multiple times in rapid succession (e.g., quick double-tap on retry)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The dashboard MUST display an actionable error state (message + retry button) within 10 seconds when any data fetch fails, and MUST NOT show an indefinite loading spinner.
- **FR-002**: When a backend auth/session error is detected during any dashboard query, the system MUST automatically navigate the user to the login screen and display a localized "session expired" message.
- **FR-003**: The dashboard MUST handle individual query failures independently — a failure in one stat card query MUST NOT prevent other successfully fetched stat cards from displaying their data.
- **FR-004**: The retry action MUST be idempotent and debounced — tapping Retry multiple times in rapid succession MUST NOT dispatch multiple simultaneous fetch requests.
- **FR-005**: Pull-to-refresh MUST always complete (indicator dismisses) regardless of whether the refresh succeeds or fails — it MUST NOT hang indefinitely.
- **FR-006**: Error messages displayed to the supervisor MUST be human-readable, localized in the current app language (English and Arabic), and contextually appropriate to the failure type (network, auth, permission, unknown).
- **FR-007**: When partial data is available (some queries succeeded, some failed), the dashboard MUST display available data and show a neutral placeholder ("—") for failed sections — not a full-screen error.
- **FR-008**: On session expiry detection, the system MUST clear local auth state and redirect to the login screen — it MUST NOT leave the supervisor on a broken dashboard that requires app restart.
- **FR-009**: The dashboard MUST protect against duplicate concurrent loads — if a load is already in progress, subsequent load requests MUST be ignored until the current one completes.
- **FR-010**: Data parsing errors (malformed backend response) MUST be caught and treated as query failures for that specific section, falling back to the "—" placeholder, rather than crashing the screen.

### Key Entities

- **Dashboard Load Attempt**: A single coordinated fetch of all dashboard data; has a status (pending, succeeded, partially failed, fully failed) and a result set per stat section.
- **Stat Section**: An individual data point (active units, completed tasks, delayed tasks, reports today, task summary bar); each can independently succeed or fail.
- **Session State**: The supervisor's authentication status; determines whether data queries are permitted or should trigger a logout redirect.
- **Error Context**: The classification of a failure (no internet, auth/session expired, permission denied, server error, parsing error); drives the error message shown to the supervisor.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Dashboard displays data (or error state) within 10 seconds of the screen becoming visible — no indefinite spinners.
- **SC-002**: 100% of session-expiry failures result in navigation to the login screen, with zero instances of a broken dashboard requiring an app restart.
- **SC-003**: When at least one stat section query succeeds, supervisors see partial data rather than a full-screen error in 100% of cases.
- **SC-004**: Pull-to-refresh always terminates (indicator fully dismisses) within 15 seconds regardless of network state.
- **SC-005**: All error messages are displayed in the supervisor's current app language (English or Arabic) — 0% of errors shown in the wrong language or as raw technical strings.
- **SC-006**: Tapping Retry 5 times in quick succession dispatches exactly 1 network request, not 5.
- **SC-007**: Zero app crashes attributable to dashboard data parsing failures — all schema mismatches are handled gracefully with a "—" fallback.

## Assumptions

- Supabase Row Level Security (RLS) is active on all queried tables; permission errors are expected failure modes, not bugs.
- The app has an existing login screen that can receive navigation with an optional message parameter explaining why the session ended.
- Auth state is managed globally via `AuthCubit` — the dashboard can observe it and react to transitions without owning the logout logic.
- Network connectivity detection is available via the existing error classification system (no-internet errors are already classified separately from server errors).
- The supervisor role has read access to at least some tables by design; a full-permission-denied failure is an exceptional edge case, not a normal startup state.
- The fix scope is the supervisor dashboard screen only — other screens (reports, tasks, profile) are not in scope even if they share similar loading patterns.
- The existing `AppError` taxonomy (unauthorized, forbidden, noInternet, serverError, unknown) is sufficient to drive contextual error messages without adding new error types.
