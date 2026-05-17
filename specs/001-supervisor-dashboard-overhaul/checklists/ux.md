# UX/UI Completeness Checklist: Supervisor Dashboard Overhaul

**Purpose**: Validate completeness, clarity, and coverage of UI/UX requirements —
with special emphasis on empty-state, loading-state, and error-state specification
quality across all three modified surfaces (dashboard, assign-task bottom sheet,
reports screen).
**Created**: 2026-05-17
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md)

---

## Empty State Requirements

- [ ] CHK001 — Is the visual treatment of a `0` stat card (valid data, zero count)
  differentiated from the `—` placeholder shown on fetch error? The spec defines
  both outcomes but does not specify whether the card looks different in each case.
  [Clarity, Spec §US1 SC3, Spec §FR-004]

- [ ] CHK002 — Is the empty state for the Live Task Summary widget fully specified?
  The spec states "a neutral empty state message" when no tasks exist today [Spec §US2
  SC3] but does not define: the message text, whether an icon/illustration is shown,
  or the visual treatment (height, alignment, color). [Completeness, Gap]

- [ ] CHK003 — Is an empty state defined for the unit dropdown in the Assign Task
  form when no units are compatible with the selected service type? The spec defines
  the flight dropdown empty state [Spec §Edge Cases] but the unit dropdown equivalent
  is absent. [Coverage, Gap]

- [ ] CHK004 — Is an empty state defined for the reports list in the Supervisor
  Reports screen when no reports exist at all? The spec covers delete flows but does
  not specify what the user sees when the list is empty. [Coverage, Gap]

- [ ] CHK005 — Is an empty state defined for the service type dropdown in the Assign
  Task form if no active service types exist in the database? [Coverage, Gap]

- [ ] CHK006 — Is the flight dropdown empty state text ("No upcoming flights in the
  next 24 hours") the only content, or should it also include a secondary action
  (e.g., "Check back later" or a refresh hint)? The spec defines the text [Spec §Edge
  Cases] but not whether an actionable affordance accompanies it. [Clarity]

- [ ] CHK007 — Is the empty state for the unit dropdown after filtering visually
  distinguishable from the initial unfiltered "Select Unit" prompt? [Clarity, Gap]

---

## Loading State Requirements

- [ ] CHK008 — Is the shape, count, and height of the shimmer skeleton cards for
  the Stats Grid specified? The spec requires shimmer skeletons [Spec §US5 SC1,
  FR-003] but does not define whether 4 skeleton cards appear (mirroring the real
  grid) or a single placeholder block. [Clarity]

- [ ] CHK009 — Is the shimmer skeleton for the Live Task Summary specified as a
  progress-bar-shaped skeleton or a generic rectangular block? The plan references
  "shimmer over the progress bar area" but the spec does not define the skeleton
  shape. [Clarity, Gap]

- [ ] CHK010 — Is a loading state (shimmer) defined for the Supervisor Reports screen
  while the reports list is fetching? The spec defines loading states for the dashboard
  [Spec §FR-003] but does not mention a loading state for the reports list. [Coverage,
  Gap]

- [ ] CHK011 — Is the loading state for the Assign Task bottom sheet dropdown fields
  specified at the field level? The plan states "shimmer over dropdown fields" during
  `loadingFormData` but the spec does not define which fields shimmer vs. show a
  spinner vs. are disabled. [Clarity]

- [ ] CHK012 — Is the Submit button state during form submission (`submitting`) fully
  specified? The plan mentions "disable Submit + show inline loader" but the spec does
  not define whether the button shows a spinner, a text change, or both. [Clarity,
  Gap]

- [ ] CHK013 — Is the pull-to-refresh indicator visual treatment consistent with the
  project's existing color system? The spec references pull-to-refresh [Spec §US1 SC2]
  but does not specify the indicator color (currently `AppColors.primary200` in
  existing code — is this carried over or updated?). [Consistency]

---

## Error State Requirements

- [ ] CHK014 — Is the visual treatment of the inline dashboard error state specified?
  FR-004 requires "an inline error message with a retry action" but does not define
  whether this is a full-screen error overlay, a card in the list, a banner, or a
  snack bar. [Clarity, Spec §FR-004]

- [ ] CHK015 — Is an error state defined for the Assign Task form's data-loading
  failure (when flights/units/service types fetch fails)? The spec defines submission
  failure [Spec §US3 SC5] but not the case where the form cannot populate its
  dropdowns at all. [Coverage, Gap]

- [ ] CHK016 — Is the snack bar duration and dismissal behavior specified for error
  messages (submit failure, delete failure)? The spec defines snack bar content
  [Spec §US3 SC5, US4 SC4] but not timing or user-dismissible vs. auto-dismiss.
  [Clarity, Gap]

- [ ] CHK017 — Is the error state for individual stat card fetch failures defined
  separately from a global dashboard error? If only the "Reports Today" query fails,
  does the spec define whether the other three cards still show, or does the whole
  grid enter error state? [Coverage, Ambiguity, Spec §FR-004]

- [ ] CHK018 — Are rollback requirements for optimistic report deletion visually
  specified? FR-010 requires rollback on failure but does not define whether the
  re-inserted item animates back into position or appears without animation.
  [Clarity, Spec §FR-010]

---

## Assign Task Bottom Sheet — Form UX Requirements

- [ ] CHK019 — Is keyboard overlap behavior specified for the Assign Task bottom
  sheet? When a text field (Notes) is focused and the soft keyboard appears, the
  sheet must scroll or resize. The spec does not define this behavior. [Coverage, Gap]

- [ ] CHK020 — Is the field tab order (or sequential focus order) specified for the
  Assign Task form? The spec lists fields [Spec §US3 SC1] but does not define the
  logical progression for keyboard/accessibility navigation. [Completeness, Gap]

- [ ] CHK021 — Is the time picker type specified for Start Time and End Time fields?
  The spec requires these fields [Spec §FR-008] but does not define whether the picker
  is a clock-face dialog, a scroll wheel, an inline time input, or a text field.
  [Clarity, Gap]

- [ ] CHK022 — Is the visual treatment of the Priority selector chips specified?
  The plan mentions "chip row: Low/Medium/High/Critical" but the spec does not define
  chip colors, the default selected state, or whether chips are single-select with
  visual emphasis. [Clarity, Gap]

- [ ] CHK023 — Is the default selected value for the Priority field specified? The
  data model sets `TaskPriority.medium` as default [data-model.md §TaskAssignmentInput]
  but the spec does not reference this default in any acceptance scenario. [Consistency,
  Gap]

- [ ] CHK024 — Is the character count display requirement defined for the Notes field
  (max 500 chars per data-model.md)? The spec does not specify whether a "X / 500"
  counter is shown inline. [Completeness, Gap]

- [ ] CHK025 — Is the sheet dismiss behavior defined when the form has unsaved
  changes? The spec allows dragging down to close [FR-005] but does not define whether
  a "Discard changes?" confirmation is shown. [Coverage, Gap]

- [ ] CHK026 — Does the Reset button require a confirmation before clearing all
  fields, or is it immediate? The spec defines the Reset button [FR-005a, US3 SC1]
  but does not specify whether a "Are you sure?" prompt appears. [Ambiguity,
  Spec §FR-005a]

- [ ] CHK027 — Is the Submit button label text specified? The spec does not define
  whether the button reads "Submit", "Assign Task", or "Create Task". [Clarity, Gap]

- [ ] CHK028 — Is the visual treatment of validation error messages (field-level)
  specified? FR-008 requires field-level error messages but does not define whether
  they appear inline below the field, as a banner, or as a tooltip. [Clarity,
  Spec §FR-008]

- [ ] CHK029 — Is a header area (title + drag handle) specified for the Assign Task
  bottom sheet? The plan describes a `DraggableScrollableSheet` but the spec does not
  define whether a fixed header with a drag handle and close button is required.
  [Completeness, Gap]

---

## Visual Hierarchy & Styling Requirements

- [ ] CHK030 — Are the spacing values between dashboard sections (Stats Grid →
  Admin Notification → Live Summary → Quick Actions) specified in the requirements?
  The spec references "improved card hierarchy" [Spec §US5] but does not define
  section spacing targets. [Clarity, Gap]

- [ ] CHK031 — Is the swipe-to-delete affordance visual treatment specified for the
  Reports list? The spec references "swipe or button" [Spec §US4 SC1] but does not
  define the background color, icon, or label shown behind the Dismissible widget.
  [Completeness, Gap]

- [ ] CHK032 — Is the confirmation dialog destructive action button styled as a
  danger/red button? The spec defines dialog content [Spec §US4 SC1] but does not
  specify whether the "Delete" option uses a destructive color (e.g., `AppColors.red200`).
  [Completeness, Gap]

- [ ] CHK033 — Is the visual content of the confirmation dialog (title text, body
  text) defined? Localization keys are listed in the plan (`supervisor_dashboard.
  delete_report_confirm`, `supervisor_dashboard.delete_report_confirm_body`) but the
  actual English/Arabic string content is not specified in the spec. [Completeness, Gap]

- [ ] CHK034 — Are interactive tap states (press feedback / ripple / splash) specified
  for Stat Cards and Quick Action buttons? The spec references tappable cards [Spec §US1]
  but does not define the tap feedback visual pattern. [Completeness, Gap]

---

## Interaction & Transition Requirements

- [ ] CHK035 — Is the bottom sheet slide-up animation curve specified, or does it
  use the platform default? The spec does not define whether a custom easing curve
  is required. [Clarity, Gap]

- [ ] CHK036 — Is the stat card tap → navigation behavior fully specified for cards
  where the navigation target is not yet built (e.g., "Active Units" → units screen)?
  The spec does not define whether tapping an unimplemented target shows a toast, is
  disabled, or navigates to a placeholder. [Coverage, Gap]

---

## Dark Mode & RTL Requirements

- [ ] CHK037 — Is the shimmer animation gradient direction specified for RTL (Arabic)
  layouts? Standard shimmer sweeps left-to-right, which is the wrong direction for
  RTL. The spec requires RTL fidelity [Spec §US5 SC3] but does not address shimmer
  directionality. [Completeness, Gap]

- [ ] CHK038 — Is the progress bar fill direction for RTL explicitly specified? The
  spec states "direction preserved logically" [Spec §US5 SC3] but "logically" is
  ambiguous — does the Done segment start from the right in Arabic? [Clarity,
  Ambiguity, Spec §US5 SC3]

- [ ] CHK039 — Is the swipe-to-delete direction mirrored for RTL? In LTR the swipe
  is right-to-left (`endToStart`); in RTL it should be left-to-right. The spec does
  not specify this. [Coverage, Gap]

- [ ] CHK040 — Are dark mode color requirements specified for the shimmer skeleton
  gradient? Shimmer gradients in dark mode need different base/highlight colors. The
  spec references `CustomColors` semantic tokens [Spec §US5 SC2] but does not confirm
  whether shimmer uses them. [Completeness, Gap]

---

## Animation Requirements

- [ ] CHK041 — Is the count-up animation duration specified for stat card value
  updates? The spec requires a "brief count-up animation" [Spec §US5 SC4] but
  "brief" is vague — is 300ms, 500ms, or 800ms intended? [Clarity, Ambiguity,
  Spec §US5 SC4]

- [ ] CHK042 — Is it specified whether the count-up animation plays on every
  pull-to-refresh or only when the value changes from the previous load? [Ambiguity,
  Spec §US5 SC4]

- [ ] CHK043 — Is the shimmer animation speed (duration, repeat interval) specified?
  The spec requires shimmer [Spec §FR-003] but `flutter_animate`'s `.shimmer()` needs
  a duration parameter. No target duration is defined. [Clarity, Gap]

---

## Notes

- Items marked `[Gap]` indicate requirements that are absent and must be added to
  the spec before implementation to avoid ambiguous handoff.
- Items marked `[Ambiguity]` indicate existing requirements that use vague language
  and need quantification.
- Items marked `[Clarity]` indicate requirements that exist but lack enough specificity
  to be implemented consistently.
- Check items off as resolved: `[x]` — add inline notes referencing which spec update
  or design decision resolved the item.
- Total: 43 items across 8 categories.
