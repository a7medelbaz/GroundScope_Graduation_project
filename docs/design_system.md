# GroundScope — Design System
> Extracted from actual source code. This is the single source of truth for all role modules.
> Every role-specific design doc references this file and only describes what diverges from it.

---

## 1. Canvas & Sizing

| Property | Value |
|---|---|
| Base canvas | 390 × 844 |
| Sizing system | `flutter_screenutil` |
| Width | `rw(n)` → `n.w` |
| Height | `rh(n)` → `n.h` |
| Radius | `rr(n)` → `n.r` |
| Font size | `rf(n)` → `n.sp` |
| Spacing widgets | `verticalSpacing(n)`, `horizontalSpacing(n)` |
| Raw pixel values | ❌ Never |

---

## 2. Colors

### Palette (`AppColors`)
**Primary (Blue)**
| Constant | Hex |
|---|---|
| `primary50` | `#D5EDF7` |
| `primary100` | `#82CAE7` |
| `primary200` | `#2FA4D7` ← main |
| `primary300` | `#247DA4` |
| `primary400` | `#18526C` |

**Secondary (Pink/Red)**
| Constant | Hex |
|---|---|
| `secondary200` | `#D12052` ← main |

**Neutral**
| Constant | Hex |
|---|---|
| `white` | `#FFFFFF` |
| `grey50` | `#ECEFF3` |
| `grey100` | `#DFE1E7` |
| `grey200` | `#C1C7D0` |
| `grey300` | `#A4ACB9` |
| `grey400` | `#818898` |
| `grey500` | `#666D80` |
| `grey600` | `#36394A` |
| `grey700` | `#272835` |
| `grey800` | `#262730` |
| `black` | `#000000` |

**Semantic**
| Constant | Hex |
|---|---|
| `green200` | `#22C55E` |
| `red200` | `#EF4444` |
| `amber200` | `#F59E0B` |
| `blue200` | `#3B82F6` |
| `backgroundLight` | `#F9FAFB` |
| `backgroundDark` | `#121212` |

**Gradient**
```dart
AppColors.primaryGradient  
// LinearGradient: topLeft→bottomRight
// stops: [primary100, primary200, primary300]
```

### Semantic Tokens (`CustomColors`)
Access via: `context.customColors` — never hardcode

| Token | Light | Dark |
|---|---|---|
| `textPrimary` | black | white |
| `textSecondary` | grey600 | grey300 |
| `textHint` | grey400 | grey500 |
| `textDisabled` | grey300 | grey600 |
| `textInverse` | white | black |
| `background` | backgroundLight | backgroundDark |
| `backgroundSecondary` | grey50 | grey800 |
| `surface` | white | grey800 |
| `surfaceVariant` | grey100 | grey700 |
| `border` | grey200 | grey600 |
| `divider` | grey100 | grey700 |
| `iconPrimary` | grey700 | grey200 |
| `iconSecondary` | grey400 | grey500 |
| `success` / `successBackground` | green200 / green0 | green200 / green400 |
| `warning` / `warningBackground` | amber200 / amber0 | amber200 / amber400 |
| `error` / `errorBackground` | red200 / red0 | red200 / red400 |
| `info` / `infoBackground` | blue200 / blue0 | blue200 / blue400 |

---

## 3. Typography (`AppTextStyles`)

All styles have **no color** — apply color via `.copyWith(color: ...)` at call site.

| Constant | Size | Weight |
|---|---|---|
| `font24ExtraBold` | 24 | w800 |
| `font24SemiBold` | 24 | w600 |
| `font24Light` | 24 | w300 |
| `font22ExtraBold` | 22 | w800 |
| `font20ExtraBold` | 20 | w800 |
| `font20SemiBold` | 20 | w600 |
| `font18ExtraBold` | 18 | w800 |
| `font18SemiBold` | 18 | w600 |
| `font16ExtraBold` | 16 | w800 |
| `font16SemiBold` | 16 | w600 |
| `font16Light` | 16 | w300 |
| `font14ExtraBold` | 14 | w800 |
| `font14SemiBold` | 14 | w600 |
| `font14Light` | 14 | w300 |
| `font12ExtraBold` | 12 | w800 |
| `font12SemiBold` | 12 | w600 |
| `font12Light` | 12 | w300 |

**Usage patterns:**
| Context | Style |
|---|---|
| Screen/section titles | `font24ExtraBold`, `font22ExtraBold`, `font20ExtraBold` |
| App bar title | `font18SemiBold` |
| Card headings | `font18ExtraBold`, `font16SemiBold` |
| Body / descriptions | `font16Light`, `font14Light` |
| Captions / timestamps | `font12Light`, `font12SemiBold` |
| Buttons (medium/large) | `font16ExtraBold` |
| Buttons (small) | `font14ExtraBold` |
| Dialog title | `font18ExtraBold` |
| Dialog body | `font16Light` |

---

## 4. Components

### `CustomAppBar`
```dart
CustomAppBar({
  required String title,
  Widget? iconData,   // optional trailing widget
})
```
- Back button: `Icons.arrow_back_ios_new` → `context.pop()`
- Title: centered, `font18SemiBold`
- Padding: `horizontal rw(16)`, `vertical rh(24)`
- Layout: `[back icon] [Spacer] [title] [Spacer] [iconData or shrink]`

---

### `CustomTextButton`
Three constructors: `.filled()`, `.outlined()`, `.text()`

| Size | Height | Padding H | Text style |
|---|---|---|---|
| `small` | 40 | 16 | `font14ExtraBold` |
| `medium` | 52 | 24 | `font16ExtraBold` |
| `large` | 56 | 24 | `font16ExtraBold` |

| Style | Background | Foreground | Border |
|---|---|---|---|
| `filled` | `primary200` | white | none |
| `outlined` | transparent | `primary200` | `primary200` w1.2 |
| `textOnly` | transparent | `primary200` | none |
| disabled | `grey100` | `grey400` | `grey200` |

- Border radius: `rr(12)`
- Loading: `CircularProgressIndicator` 22×22, strokeWidth 2.5
- Elevation: 0

---

### `CustomIconButton`
```dart
CustomIconButton({
  required IconData icon,
  required VoidCallback onPressed,
  String? label,
  String? tooltip,
  double? iconSize,        // default: rf(20)
  Color? backgroundColor,  // default: transparent
})
```
- Radius: `rr(12)`, icon color: `textSecondary`
- Padding: `rw(10)` h (no label), `rw(12)` h (with label)

---

### `CustomTextForm`
- Border radius: `rr(12)`
- Input style: `font16Light`, color `textPrimary`
- Hint style: `font16Light`, color `textHint`
- Default padding: `horizontal 14, vertical 18`
- Border states: default `cc.border` / focused `primary50` / error `red200` / disabled `cc.border @ 0.4`

---

### `InfoCard` + `InfoRowData`
```dart
InfoCard(rows: [
  InfoRowData(icon: ..., label: ..., value: ..., highlight: false)
])
```
- Card: `surface`, radius `rr(14)`, border `cc.border @ 0.5`
- Row padding: `rw(14)` h, `rh(12)` v
- Icon container: `rw(32)×rw(32)`, radius `rr(8)`, bg `primary200 @ 0.08`
- Label: `font12Light`, color `textHint`
- Value: `font12SemiBold` (highlight: textPrimary / normal: textSecondary)
- Divider between rows: color `cc.divider`

---

### `NotificationButton`
- Size: `rw(44)×rw(44)`, circle
- Background: `white @ 0.12`, border: `white @ 0.2`
- Icon: `Icons.notifications_outlined`, white, size 22
- Unread dot: `rw(8)×rw(8)`, color `secondary200`, top-right

---

### `OverlayLoader`
```dart
OverlayLoader(isLoading: bool, child: Widget, message: String?)
```
- Overlay bg: `background @ 0.8`
- Spinner: `CircularProgressIndicator(color: AppColors.primary300)`
- Message: `font16Light`, color `textSecondary`

---

### `ErrorScreen`
```dart
ErrorScreen(error: String?, onRetry: VoidCallback?)
```
- Icon: `Icons.error_outline_rounded`, `rf(80)`, color `red100`
- Title: `font24ExtraBold`
- Retry: `font14SemiBold`, color `red100`

---

### `MessageSnackBar`
```dart
context.showMessageSnackBar(message, type: SnackBarType.error | success)
```
- Slide-up + fade-in (350ms, `easeOutCubic`), auto-dismiss 4s/3s
- Error bg: `colorScheme.error` / Success bg: `#22C55E`
- Text: `font14SemiBold`, white

---

### `CustomAppDialog` + `AppDialogs`
```dart
AppDialogs.showConfirm(context, message:, onConfirm:, ...)
AppDialogs.showError(context, message:, ...)
AppDialogs.showSuccess(context, message:, ...)
AppDialogs.showWarning(context, message:, ...)
```
- Shape: radius `rr(16)`, bg `cc.surface`
- `barrierDismissible: false` for all static helpers
- Two-button layout: secondary `outlined` + primary `filled` in `Row`

---

## 5. Badges & Chips

### Chip pattern (from `ReportCard._Chip`)
- Padding: `rw(8)` h, `rh(3)` v — Radius: `rr(8)`
- Background: `color @ (filled ? 0.15 : 0.10)`
- Border: `color @ 0.3` — Text: `font12SemiBold`, color = `color`
- Severity chip: `filled: false` / Status chip: `filled: true`

### Filter Pills
- Selected: bg `primary200`, text white
- Unselected: bg `surfaceVariant`, border `cc.border`, text `textSecondary`
- Padding: `rw(14)` h, `rh(6)` v — Radius: `rr(20)` — Text: `font12SemiBold`
- Animation: 200ms

### Task Priority Colors
| Priority | Color |
|---|---|
| `critical` | `red200` |
| `high` | `secondary200` |
| `medium` | `amber200` |
| `low` | `green200` |

### Task Status Colors
| Status | Color |
|---|---|
| `inProgress` | `primary200` |
| `completed` | `green200` |
| `pending` | `amber200` |
| `assigned` | `blue200` |
| `paused` | `secondary200` |
| `cancelled` | `textDisabled` |

### Report Severity Colors
| Severity | Color |
|---|---|
| `low` | `green200` |
| `medium` | `amber200` |
| `high` | `secondary200` |
| `critical` | `red200` |

### Report Status Colors
| Status | Color |
|---|---|
| `open` | `amber200` |
| `acknowledged` | `blue200` |
| `inProgress` | `primary200` |
| `resolved` | `green200` |

---

## 6. Card Spec

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
- Left accent bar: `rw(4)` wide, colored by severity/status
- Body padding: `all rw(14)`
- Icon container: `rw(42)×rw(42)`, radius `rr(12)`, bg `color @ 0.12`, icon `rf(20)`
- Title: `font16SemiBold`, `textPrimary`
- Description: `font14Light`, `textSecondary`, maxLines 2
- Timestamp: `font12Light`, `textHint`

---

## 7. Navigation

```dart
Routes.workerScaffold
Routes.supervisorScaffold
Routes.supervisorTaskListScreen
Routes.taskDetailsScreen
Routes.taskDetailsInfoScreen
Routes.addReportScreen
Routes.reportsScreen
Routes.reportsDetailsScreen
Routes.workerManagerAndMembersScreen
Routes.workerMemberDetailScreen
Routes.adminScreen
Routes.loginScreen

context.pushNamed(route, arguments: {})
context.pushReplacementNamed(route)
context.pushNamedAndRemoveAll(route)
context.pop([result])
```

---

## 8. State Handling Patterns

### Pattern A — Status enum
```dart
loading/initial → CircularProgressIndicator(color: AppColors.primary200)
failure         → cloud_off icon + error message + retry TextButton
empty           → EmptyState widget
loaded          → RefreshIndicator(color: primary200) + ListView
```

### Pattern B — Sealed states
```dart
Loading → CircularProgressIndicator
Failure → font14Light text, red300
Loaded  → RefreshIndicator + content
```

Error text: always `state.error?.messageKey` — never hardcode.

---

## 9. Rules (Non-Negotiable)

- ❌ No raw pixel values — always `rw()`, `rh()`, `rr()`, `rf()`
- ❌ No hardcoded colors — always `AppColors.*` or `context.customColors.*`
- ❌ No inline `TextStyle(...)` — always `AppTextStyles.*`
- ❌ No hardcoded strings — always `.tr()` with keys in both `en.json` + `ar.json`
- ❌ No `Navigator.push()` — always `context.pushNamed(Routes.x)`
- ❌ No `showDialog()` directly — always `AppDialogs.*` or `CustomAppDialog`
- ❌ No cubit provided inside screen widgets — always via `app_routers.dart` or DI
- ✅ RTL: use `context.isArabic` for direction-aware layout
- ✅ Always guard `context.pop()` with `Navigator.canPop(context)`
