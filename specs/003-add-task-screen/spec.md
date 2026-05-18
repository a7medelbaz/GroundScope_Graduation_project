# Feature Specification: Assign Task — Full-Page Screen

**Feature Branch**: `003-add-task-screen`

**Created**: 2026-05-18

**Status**: Draft

**Input**: Replace AddTask bottom sheet with a dedicated full-page screen. Make sure it loads not like it is now.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Assign Task via Full-Page Screen (Priority: P1)

A supervisor taps "Assign Task" on the dashboard and is navigated to a dedicated full-page screen. The screen immediately begins loading the required data (upcoming flights, active units, service types) and displays a clear loading indicator while doing so. Once data is ready, the complete form appears and the supervisor can fill in all fields and submit the assignment.

**Why this priority**: This is the core replacement of the existing bottom sheet. Without it, the feature does not exist. The full-page screen gives supervisors more space to work and a cleaner loading experience.

**Independent Test**: Tap "Assign Task" → new screen opens, loading indicator appears → form fields appear → fill all required fields → tap submit → success message shown → screen closes → dashboard refreshes.

**Acceptance Scenarios**:

1. **Given** the supervisor is on the dashboard, **When** they tap "Assign Task", **Then** a new full-page screen opens (not a bottom sheet), and a loading indicator is displayed immediately.
2. **Given** form data has loaded, **When** the form is displayed, **Then** all six fields are visible: flight selector, service type selector, unit selector, priority selector, start time picker, end time picker, and optional notes.
3. **Given** all required fields are filled with valid data, **When** the supervisor taps "Assign Task", **Then** the task is created, a success message is shown, and the supervisor is returned to the dashboard (which reflects the new task).
4. **Given** the form is submitted successfully, **When** the supervisor lands back on the dashboard, **Then** the dashboard stats and task summary are refreshed.

---

### User Story 2 — Form Validation Prevents Invalid Submission (Priority: P1)

The form enforces that all required fields are filled and that the scheduled end time is after the start time before allowing submission. The supervisor receives clear inline feedback on what is wrong before they can submit.

**Why this priority**: Submitting an incomplete or invalid task assignment would create bad data. Validation is a prerequisite to a usable form.

**Independent Test**: Try submitting with empty fields → button is disabled. Set end time before start time → error message appears next to end time field. Fix all fields → button becomes enabled.

**Acceptance Scenarios**:

1. **Given** required fields (flight, service type, unit, start time, end time) are not all filled, **When** the supervisor views the form, **Then** the submit button is disabled.
2. **Given** an end time is set that is not after the start time, **When** the supervisor views the end time field, **Then** a clear error message is shown below that field.
3. **Given** all validation rules pass, **When** the supervisor submits, **Then** the form is submitted and the submit button shows a loading indicator while the request is in progress.
4. **Given** the reset button is tapped, **When** the action completes, **Then** all field selections are cleared and the form returns to its initial state (data does not need to be re-fetched).

---

### User Story 3 — Graceful Load Failure with Retry (Priority: P2)

If the form data (flights, units, service types) fails to load, the screen shows a clear error state explaining the failure with a retry button. The supervisor can retry without leaving the screen.

**Why this priority**: Network errors are common in airport operations. A supervisor must not be left on a blank or broken screen.

**Independent Test**: Simulate a network failure before opening the screen → loading indicator appears → error state shown with retry button → tap retry → data loads and form appears.

**Acceptance Scenarios**:

1. **Given** form data fails to load, **When** the loading completes with an error, **Then** the loading indicator disappears and an error state is shown with a descriptive message and a "Retry" button.
2. **Given** the error state is displayed, **When** the supervisor taps "Retry", **Then** the loading indicator reappears and a new data fetch attempt begins.
3. **Given** a retry succeeds, **When** data loads, **Then** the form is displayed fully — no stale error state remains visible.

---

### Edge Cases

- What happens when there are no upcoming flights? The flight selector shows a disabled state with a "No upcoming flights" message; the form cannot be submitted.
- What happens when a service type has no associated units? The unit selector shows a disabled "No units available" message; the submit button remains disabled.
- What happens when the supervisor submits and the server returns an error? An error snack bar is shown; the form remains open with all field values intact so the supervisor can retry without re-entering data.
- What happens when the supervisor navigates back before submitting? The screen closes with no data saved; the dashboard is not refreshed.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The "Assign Task" action MUST navigate to a full-page screen instead of opening a bottom sheet.
- **FR-002**: The new screen MUST begin loading form data (flights, service types, active units) immediately on entry and display a loading indicator during the fetch.
- **FR-003**: The loading state MUST be a full-screen indicator, not an in-sheet skeleton — it must feel like a proper page load.
- **FR-004**: The form MUST contain: flight selector, service type selector, unit selector (filtered by selected service type), priority selector (low/medium/high/critical), start time picker, end time picker, and an optional notes field.
- **FR-005**: The unit selector MUST only show units that match the currently selected service type, and MUST reset when the service type changes.
- **FR-006**: The submit button MUST be disabled until flight, service type, unit, start time, and end time are all selected AND end time is after start time.
- **FR-007**: The submit button MUST show a loading indicator while submission is in progress; all other fields MUST be non-interactive during submission.
- **FR-008**: On successful submission, the screen MUST close, a success message MUST be shown, and the supervisor dashboard MUST refresh its stats and task summary.
- **FR-009**: On submission failure, the screen MUST stay open with all field values intact and an error message MUST be shown.
- **FR-010**: If form data fails to load, the screen MUST show an error state with a descriptive message and a "Retry" button.
- **FR-011**: The reset action MUST clear all field selections and return the form to its unfilled initial state without re-fetching data from the server.
- **FR-012**: The screen MUST be navigated to via a named route so it can be reached from any point in the supervisor flow (not only from the dashboard).

### Key Entities

- **Task Assignment**: The data submitted when assigning a task. Attributes: flight (required), service type (required), unit (required), priority (required, defaults to medium), scheduled start time (required), scheduled end time (required), notes (optional).
- **Flight**: An upcoming flight available for task assignment. Displayed as flight number and route (origin → destination).
- **Service Type**: A category of ground service (e.g., refuelling, catering). Determines which units are eligible.
- **Unit**: A ground crew unit. Each unit belongs to a service type.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A supervisor can open the assign-task screen, fill all required fields, and submit a task assignment in under 60 seconds on a stable connection.
- **SC-002**: The form is fully interactive (no loading skeleton visible) within 3 seconds on a stable connection.
- **SC-003**: When form data fails to load, an error state with a retry button appears within 15 seconds (matching the network timeout).
- **SC-004**: 100% of required-field validation errors are surfaced before the supervisor can submit — no invalid assignments reach the server.
- **SC-005**: After a successful submission, the dashboard stats and task summary update within the same screen session without requiring a full app restart.

---

## Assumptions

- The existing `AssignTaskCubit` and `AssignTaskState` logic are correct and will be reused unchanged; only the presentation layer (bottom sheet → full-page screen) and navigation wiring change.
- The new screen will be registered as a named route in the app router, consistent with all other pushed screens in the supervisor module.
- The `AssignTaskCubit` is provided at the route level (via `app_routers.dart`) and receives `loadFormData()` called immediately on creation — the same pattern already used.
- The "not like it is now" loading concern refers specifically to the bottom sheet skeleton (fields appearing inside a sliding sheet as a skeleton), which feels janky. The replacement must show a clean full-screen loading state before the form is rendered.
- The dashboard refresh after success is achieved by calling `SupervisorDashboardCubit.refresh()`, which already exists.
- No new localization keys are expected beyond what already exists in `supervisor_dashboard.*`; any missing keys will be added during implementation.
