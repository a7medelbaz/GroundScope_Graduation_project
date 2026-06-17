# Phase 8 — Notifications (Standalone)
> Supervisor Module Rebuild · GroundScope  
> ⚠️ STANDALONE PHASE — Skip this and build it independently at any time.  
> No other phase depends on this. Phases 1–7 are complete without it.  
> Prerequisite to start: Phase 1 complete.  
> Reference: `supervisor_module_reference.md` §5.2, `DATABASE.md` notifications table

---

## Overview

This phase wires FCM push notifications end-to-end for the Supervisor role:

1. **Unread dot** on the `NotificationButton` in the dashboard header
2. **Notifications inbox** — a dedicated screen (not a tab) pushed from the button
3. **Background services** — FCM token refresh, foreground message handling

The `notifications` table is already defined in the database. No schema changes needed.

---

## Feature 8.1 — Notifications Remote DS

**File:** `lib/modules/supervisor/features/notifications/data/remote/supervisor_notifications_remote_ds.dart`

### Methods
```dart
class SupervisorNotificationsRemoteDs {
  // Fetch all notifications for this user, newest first
  Future<List<NotificationModel>> fetchNotifications(String userId);

  // Unread count only — lightweight query for the dot
  Future<int> fetchUnreadCount(String userId);

  // Mark a single notification as read
  Future<void> markAsRead(String notificationId);

  // Mark all as read
  Future<void> markAllAsRead(String userId);

  // Realtime unread count stream
  Stream<List<Map<String, dynamic>>> watchNotifications(String userId);
}
```

### New model required

```dart
// lib/modules/supervisor/features/notifications/data/models/notification_model.dart
class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;           // notification_type enum value
  final String referenceId;    // polymorphic reference ID
  final String referenceType;  // 'task' | 'report' | etc.
  final bool isRead;
  final bool sentViaFcm;
  final DateTime createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json);
}
```

### Supabase Queries
```dart
// Fetch all
supabase.client.from('notifications')
  .select('*')
  .eq('user_id', userId)
  .order('created_at', ascending: false)
  .limit(50);

// Unread count
supabase.client.from('notifications')
  .select('id')
  .eq('user_id', userId)
  .eq('is_read', false);

// Mark single as read
supabase.client.from('notifications')
  .update({'is_read': true})
  .eq('id', notificationId);

// Mark all as read
supabase.client.from('notifications')
  .update({'is_read': true})
  .eq('user_id', userId)
  .eq('is_read', false);

// Realtime stream
supabase.client
  .from('notifications')
  .stream(primaryKey: ['id'])
  .eq('user_id', userId)
  .order('created_at', ascending: false)
  .limit(50);
```

### Checklist
- [ ] All queries scoped by `user_id`
- [ ] `fetchUnreadCount` is a lightweight `.select('id')` — not fetching full rows
- [ ] Realtime stream limited to 50 rows
- [ ] `PostgrestException` → `AppError`

---

## Feature 8.2 — Notifications Repo

**Files:**
- `features/notifications/data/repo/supervisor_notifications_repo.dart`
- `features/notifications/data/repo/supervisor_notifications_repo_impl.dart`

### Interface
```dart
abstract class SupervisorNotificationsRepo {
  Future<List<NotificationModel>> getNotifications(String userId);
  Future<int> getUnreadCount(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Stream<List<NotificationModel>> watchNotifications(String userId);
}
```

### DI — add to `dependency_injection.dart`
```dart
getIt.registerLazySingleton<SupervisorNotificationsRemoteDs>(
  () => SupervisorNotificationsRemoteDs(getIt<SupabaseService>()));
getIt.registerLazySingleton<SupervisorNotificationsRepo>(
  () => SupervisorNotificationsRepoImpl(getIt<SupervisorNotificationsRemoteDs>()));
getIt.registerFactory<SupervisorNotificationsCubit>(
  () => SupervisorNotificationsCubit(getIt<SupervisorNotificationsRepo>()));
```

### Checklist
- [ ] Interface + impl pattern
- [ ] `watchNotifications` maps raw stream to `List<NotificationModel>`
- [ ] All 5 methods in impl

---

## Feature 8.3 — Notifications Cubit

**File:** `features/notifications/logic/cubit/supervisor_notifications_cubit.dart`

### State
```dart
enum SupervisorNotificationsStatus { initial, loading, loaded, failure }

class SupervisorNotificationsState extends Equatable {
  final SupervisorNotificationsStatus status;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final AppError? error;
}
```

### Methods
```dart
class SupervisorNotificationsCubit extends Cubit<SupervisorNotificationsState> {
  StreamSubscription? _subscription;

  // Called on scaffold init — starts realtime + loads initial data
  Future<void> init(String userId);

  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

### `init` implementation
```dart
Future<void> init(String userId) async {
  emit(state.copyWith(status: SupervisorNotificationsStatus.loading));
  try {
    final notifications = await _repo.getNotifications(userId);
    final unreadCount = notifications.where((n) => !n.isRead).length;
    emit(state.copyWith(
      status: SupervisorNotificationsStatus.loaded,
      notifications: notifications,
      unreadCount: unreadCount,
    ));
    // Subscribe to realtime
    _subscription = _repo.watchNotifications(userId).listen((updated) {
      final count = updated.where((n) => !n.isRead).length;
      emit(state.copyWith(notifications: updated, unreadCount: count));
    });
  } on AppError catch (e) {
    emit(state.copyWith(status: SupervisorNotificationsStatus.failure, error: e));
  } catch (_) {
    emit(state.copyWith(
      status: SupervisorNotificationsStatus.failure,
      error: AppError.unknown(),
    ));
  }
}
```

### Checklist
- [ ] `init` fetches + subscribes in one call
- [ ] `unreadCount` computed from local list — no extra query
- [ ] `markAsRead` updates row + decrements local count
- [ ] `markAllAsRead` resets `unreadCount` to 0 + marks all local items read
- [ ] Stream subscription cancelled in `close()`

---

## Feature 8.4 — Notification Button (Wired)

**File:** Update `features/dashboard/ui/widgets/supervisor_header.dart`

The `NotificationButton` was added in Phase 2 as a static placeholder. In this phase, wire it to the cubit.

### Changes
```dart
// In SupervisorHeader — replace placeholder with:
BlocBuilder<SupervisorNotificationsCubit, SupervisorNotificationsState>(
  builder: (context, state) {
    return NotificationButton(
      hasUnread: state.unreadCount > 0,
      onTap: () => context.pushNamed(Routes.supervisorNotificationsScreen),
    );
  },
)
```

### `NotificationButton` spec (from `design_system.md` §4)
```dart
// Already exists in lib/core/widgets/notification_button.dart
// Just pass hasUnread and onTap
NotificationButton(
  hasUnread: true,   // shows red dot (secondary200) top-right
  onTap: onTap,
)
```

### Route to add

In `lib/core/router/routes.dart`:
```dart
static const String supervisorNotificationsScreen = '/supervisorNotificationsScreen';
```

In `app_routers.dart`:
```dart
case Routes.supervisorNotificationsScreen:
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => BlocProvider.value(
      value: getIt<SupervisorNotificationsCubit>(),
      child: const SupervisorNotificationsScreen(),
    ),
  );
```

### Checklist
- [ ] Unread dot appears when `unreadCount > 0`
- [ ] Unread dot disappears after `markAllAsRead` called
- [ ] Tapping button navigates to notifications screen
- [ ] Route registered in `routes.dart` + `app_routers.dart`
- [ ] `NotificationButton` uses existing widget — not recreated

---

## Feature 8.5 — Notifications Screen

**File:** `features/notifications/ui/supervisor_notifications_screen.dart`

### Layout
```
Scaffold (bg: cc.background)
  CustomAppBar(
    title: 'notifications'.tr(),
    iconData: TextButton(
      label: 'mark_all_read'.tr(),
      style: font12SemiBold, primary200,
      onPressed: () => cubit.markAllAsRead(userId),
    ),
  )
  body: BlocBuilder:
    loading → CircularProgressIndicator(color: primary200)
    failure → ErrorScreen
    empty   → EmptyState (icon: notifications_none_outlined)
    loaded  → ListView.builder of NotificationTile
```

### `NotificationTile` spec
```
Container (bg: isRead ? surface : primary50, border-bottom: 0.5px cc.divider)
  padding: rw(16) h, rh(12) v
  Row:
    ├── icon container rw(40)×rw(40), rr(10)
    │     bg: notifTypeColor@0.1, icon color: notifTypeColor
    │     icon: depends on type (task → checkbox, report → flag, general → bell)
    ├── Column (flex 1):
    │     ├── title (font14SemiBold if unread, font14Light if read, textPrimary)
    │     ├── body (font12Light, textSecondary, maxLines: 2)
    │     └── createdAt.timeAgo (font12Light, textHint)
    └── if !isRead: unread dot rw(8)×rw(8), rr(4), primary200
```

### Notification type → icon + color
| Type | Icon | Color |
|---|---|---|
| `task_assigned` | `Icons.check_box_outlined` | `primary200` |
| `task_completed` | `Icons.check_circle_outline` | `green200` |
| `report_submitted` | `Icons.flag_outlined` | `secondary200` |
| default | `Icons.notifications_outlined` | `amber200` |

### On tile tap
```dart
onTap: () {
  if (!notification.isRead) {
    cubit.markAsRead(notification.id);
  }
  // Navigate based on referenceType:
  // referenceType == 'task' → pushNamed(Routes.supervisorTaskDetailScreen, args: {taskId})
  // referenceType == 'report' → (no screen yet — no-op for now)
}
```

### FCM token refresh

In `SupervisorScaffold.initState` (or `DashboardCubit.loadDashboard`):
```dart
// Update FCM token in users table on every login
final token = await FirebaseMessaging.instance.getToken();
if (token != null) {
  await supabase.client.from('users')
    .update({'fcm_token': token})
    .eq('id', currentUserId);
}
// Listen for token refresh
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
  await supabase.client.from('users')
    .update({'fcm_token': newToken})
    .eq('id', currentUserId);
});
```

### Foreground message handling

In `SupervisorScaffold`:
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Show local snackbar notification
  context.showMessageSnackBar(
    message.notification?.title ?? 'new_notification'.tr(),
    type: SnackBarType.info,
  );
  // Refresh notifications cubit
  context.read<SupervisorNotificationsCubit>().init(currentUserId);
});
```

### Checklist
- [ ] Screen uses `CustomAppBar` with "Mark all read" trailing button
- [ ] Unread tiles have `primary50` background
- [ ] Unread dot shown on unread tiles
- [ ] Tile tap marks notification as read
- [ ] `timeAgo` from `datetime_ext.dart`
- [ ] FCM token saved/refreshed in `users.fcm_token`
- [ ] Foreground messages show snackbar + refresh list
- [ ] No-op on report tile tap (no detail screen yet)

---

## Phase 8 — Done Criteria

- [ ] `SupervisorNotificationsCubit` initialized when supervisor logs in
- [ ] Unread dot on `NotificationButton` reflects real unread count
- [ ] Dot disappears after "Mark all read" is tapped
- [ ] Realtime: new notification arriving updates dot count without refresh
- [ ] Notifications screen shows list sorted newest first
- [ ] Unread items visually distinguished (primary50 bg + bold title + dot)
- [ ] Tapping a notification marks it read and dot count decrements
- [ ] FCM token stored/refreshed on login
- [ ] Foreground FCM messages show snackbar
- [ ] Stream subscription cancelled on cubit close (no memory leaks)
- [ ] No hardcoded strings, no raw pixel values
