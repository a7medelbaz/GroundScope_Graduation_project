# Phase 7 — Profile Tab
> Supervisor Module Rebuild · GroundScope  
> Prerequisite: Phase 1 complete.  
> Reference: `supervisor_module_reference.md` §4.5, `design_system.md` §4 InfoCard

---

## Feature 7.1 — Profile Cubit

**File:** `features/profile/logic/cubit/supervisor_profile_cubit.dart`

### State
```dart
enum SupervisorProfileStatus { initial, loading, loaded, failure }

class SupervisorProfileState extends Equatable {
  final SupervisorProfileStatus status;
  final UserModel? user;
  final int unitCount;      // number of units under this supervisor's service type
  final int memberCount;    // total crew members across all units
  final AppError? error;
}
```

### Methods
```dart
class SupervisorProfileCubit extends Cubit<SupervisorProfileState> {
  final UserService _userService;

  SupervisorProfileCubit(this._userService);

  Future<void> loadProfile();
}
```

### `loadProfile` implementation
```dart
Future<void> loadProfile() async {
  emit(state.copyWith(status: SupervisorProfileStatus.loading));
  try {
    // Read from cache — no network call needed
    final user = _userService.currentUser;
    if (user == null) throw AppError.unauthorized();
    emit(state.copyWith(
      status: SupervisorProfileStatus.loaded,
      user: user,
      // unitCount and memberCount: read from cache or leave as 0 for now
      // (can be enriched in a future iteration)
    ));
  } on AppError catch (e) {
    emit(state.copyWith(status: SupervisorProfileStatus.failure, error: e));
  }
}
```

> Unit/member counts can be hardcoded to `0` for Phase 7 and enriched later when a query is needed. Profile is read-only.

### Checklist
- [ ] Reads from `UserService` cache — no Supabase call
- [ ] Emits `failure` if `currentUser` is null
- [ ] No network calls in this cubit
- [ ] Already registered in DI from Phase 1

---

## Feature 7.2 — Profile Header Widget

**File:** `features/profile/ui/widgets/profile_header.dart`

### Layout
```
Container (gradient decoration — same as dashboard header)
  padding: rh(28) top, rw(16) horizontal, rh(36) bottom
  Column (centered):
    ├── avatar circle (rw(72)×rw(72), borderRadius rr(36))
    │     background: white@0.2
    │     border: 2.5px solid white@0.4
    │     child: initials (font24ExtraBold, white)
    ├── verticalSpacing(10)
    ├── full_name (font18ExtraBold, white)
    ├── verticalSpacing(2)
    └── role tag "supervisor".tr() (font13Light, white@0.7)
```

### Gradient (same as dashboard)
```dart
BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary200, AppColors.primary300, AppColors.primary400],
  ),
)
```

### Initials helper
```dart
String _initials(String fullName) {
  final parts = fullName.trim().split(' ');
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}
```

### Checklist
- [ ] Avatar uses initials — no image (profile photo not in scope)
- [ ] `rr(36)` on avatar (circular) — `rw(72) / 2 = rr(36)`
- [ ] Gradient matches dashboard header exactly
- [ ] Role shows `"supervisor".tr()` — not hardcoded
- [ ] `font18ExtraBold` for name — matches design system screen title rule

---

## Feature 7.3 — Info Card (Profile)

**File:** `features/profile/ui/widgets/profile_info_card.dart`

Uses the existing `InfoCard` + `InfoRowData` from `lib/core/widgets/`.

### Rows
```dart
InfoCard(rows: [
  InfoRowData(
    icon: Icons.mail_outline,
    label: 'email'.tr(),
    value: user.email,
    highlight: false,
  ),
  InfoRowData(
    icon: Icons.phone_outlined,
    label: 'phone'.tr(),
    value: user.phone ?? '—',
    highlight: false,
  ),
  InfoRowData(
    icon: Icons.bolt_outlined,
    label: 'service_type'.tr(),
    value: user.serviceTypeName ?? '—',
    highlight: true,
  ),
  InfoRowData(
    icon: Icons.local_shipping_outlined,
    label: 'units_managed'.tr(),
    value: '$unitCount ${'units'.tr()} · $memberCount ${'crew_members'.tr()}',
    highlight: false,
  ),
])
```

### InfoCard spec (from design system)
```
Card: surface, rr(14), border cc.border@0.5
Row padding: rw(14) h, rh(12) v
Icon container: rw(32)×rw(32), rr(8), primary200@0.08
Label: font12Light, textHint
Value: font12SemiBold — highlight: textPrimary / normal: textSecondary
Divider between rows: cc.divider
```

### Checklist
- [ ] Reuses `InfoCard` from `lib/core/widgets/` — no new card widget
- [ ] 4 rows: email, phone, service type, units managed
- [ ] `highlight: true` on service type row
- [ ] Phone shows `'—'` when null
- [ ] `rr(14)` on card via existing widget

---

## Feature 7.4 — Settings Tiles

**File:** `features/profile/ui/widgets/supervisor_settings_tile.dart`

### Each tile layout
```
GestureDetector(onTap: onTap)
  Container (bg: cc.surface, border-bottom: 0.5px cc.divider)
    padding: rh(14) v, rw(16) h
    Row:
      ├── Icon(icon, rf(18), color: isDestructive ? red200 : cc.iconSecondary)
      ├── horizontalSpacing(10)
      ├── Text(label.tr(), font14Light, isDestructive ? red200 : cc.textPrimary) [flex 1]
      └── if showTrailing:
            Row: [trailing text (font13Light, textHint)] [Icon(chevron_right, rf(16), iconSecondary)]
```

### Tiles to render

| Label key | Icon | Trailing | onTap |
|---|---|---|---|
| `language` | `Icons.language_outlined` | current lang (`'English'` / `'العربية'`) | `switchLanguage(context)` from `app_setting_method.dart` |
| `dark_mode` | `Icons.dark_mode_outlined` | `''` (no trailing) | `switchTheme(context)` |
| `notifications` | `Icons.notifications_outlined` | `''` | `() {}` (Phase 8) |
| `logout` | `Icons.logout_outlined` | none | confirm dialog → `AuthCubit.signOut()` |

### Logout flow
```dart
onTap: () async {
  await AppDialogs.showConfirm(
    context,
    message: 'logout_confirm'.tr(),
    onConfirm: () {
      context.read<AuthCubit>().signOut();
    },
  );
},
```

### Grouping
Wrap language + dark_mode + notifications in one `Container` (surface, rr(12), border cc.border@0.5).
Logout tile is separated with `verticalSpacing(12)` and its own `Container` (same style).

### Checklist
- [ ] `switchLanguage` and `switchTheme` from `app_setting_method.dart` — not reimplemented
- [ ] Logout uses `AppDialogs.showConfirm` — never raw `showDialog`
- [ ] Logout delegates to `context.read<AuthCubit>().signOut()` — no auth logic in profile cubit
- [ ] Destructive tile (logout) uses `red200` for icon and label
- [ ] `rr(12)` on settings group containers
- [ ] Notifications tile tap is no-op for now (Phase 8 wires it)

---

## Feature 7.5 — Profile Screen

**File:** `features/profile/ui/supervisor_profile_screen.dart`

### Layout
```
Scaffold (bg: cc.background)
  body: BlocBuilder<SupervisorProfileCubit, SupervisorProfileState>
    loading → centered CircularProgressIndicator(color: primary200)
    failure → ErrorScreen(onRetry: cubit.loadProfile)
    loaded  →
      SingleChildScrollView:
        ├── ProfileHeader(user: state.user!)
        ├── verticalSpacing(16)
        ├── Padding(rw(16)h): ProfileInfoCard(user, unitCount, memberCount)
        ├── verticalSpacing(16)
        └── SupervisorSettingsTiles()
              (language, dark mode, notifications, logout)
        └── verticalSpacing(32)   ← bottom breathing room
```

### Init
```dart
@override
void initState() {
  super.initState();
  context.read<SupervisorProfileCubit>().loadProfile();
}
```

### Checklist
- [ ] `initState` calls `loadProfile`
- [ ] Loading state shows spinner
- [ ] Failure state shows `ErrorScreen`
- [ ] All 3 sub-widgets assembled: header, info card, settings tiles
- [ ] Bottom padding `rh(32)` to avoid nav bar overlap
- [ ] No `Scaffold` app bar — header IS the visual top of the screen
- [ ] No hardcoded strings, no raw pixel values

---

## Phase 7 — Done Criteria

- [ ] Profile tab loads supervisor's name, email, phone, service type from cache
- [ ] Avatar shows correct initials
- [ ] Gradient header matches dashboard header style exactly
- [ ] Info card shows all 4 rows with correct data
- [ ] Language toggle works and switches app locale
- [ ] Theme toggle works and switches light/dark mode
- [ ] Notifications tile is visible but tapping is a no-op (Phase 8)
- [ ] Logout shows confirm dialog → signs out and navigates to login screen
- [ ] No hardcoded strings, no raw pixel values
- [ ] Settings groups have `rr(12)` container radius
