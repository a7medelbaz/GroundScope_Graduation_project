# Mobile App Fix — Supervisor Service-Request Detail Shows Blank

**Target project:** `ground_scope` (Flutter mobile app) — **NOT** the admin dashboard.
**Audience:** whoever maintains the mobile app.
**Severity:** High — blocks the supervisor from seeing flight details on newly-assigned service requests.

---

## 1. Symptom

When the **admin** creates a service request for a flight (from the admin web dashboard),
it appears in the **supervisor's dashboard** (Service section) in real time. But when the
supervisor taps **"Details"** on that freshly-arrived request, the **flight details are
blank** (no flight number, route, stand, times).

If the supervisor **pulls to refresh / reloads** the dashboard, the same request then shows
its flight details correctly. So the data exists — it's only blank for requests that arrive
**live via the realtime stream**.

---

## 2. Root Cause

**Supabase realtime `.stream()` does not support foreign-table joins.** It returns only the
flat columns of the streamed table.

### The chain

1. The supervisor dashboard subscribes to a realtime stream:
   **`lib/modules/supervisor/features/dashboard/logic/cubit/dashboard_cubit.dart`** (~line 93)
   ```dart
   _requestSubscription = _dashboardRepo
       .watchPendingServiceRequests(serviceTypeId)
       .listen((requests) { ... emit(...) });
   ```

2. That stream:
   **`lib/modules/supervisor/features/dashboard/data/remote/dashboard_remote_ds.dart`** (~line 128)
   ```dart
   Stream<List<ServiceRequestModel>> watchPendingServiceRequests(String serviceTypeId) {
     return _supabaseService.client
         .from('flight_service_requests')
         .stream(primaryKey: ['id'])          // ← .stream() = flat columns only, NO joins
         .eq('service_type_id', serviceTypeId)
         .map((rows) => rows
             .where((r) => r['status'] == 'pending')
             .map((r) => ServiceRequestModel.fromJson(r))
             .toList());
   }
   ```
   Because `.stream()` cannot join, the streamed row has **no `flights` key**.

3. The model then sets `flight = null`:
   **`lib/modules/supervisor/features/dashboard/data/models/service_request_model.dart`** (~line 70)
   ```dart
   final flightData = json['flights'] as Map<String, dynamic>?;   // null from stream
   ...
   flight: flightData != null ? FlightModel.fromMap(flightData) : null,   // → null
   ```

4. The detail card reads the now-null flight:
   **`lib/modules/supervisor/features/dashboard/ui/widgets/service_request_card.dart`** (~line 34)
   ```dart
   final flight = request.flight;   // null → blank UI
   ```

### Why refresh works
The **initial** load (`dashboard_cubit.dart` ~line 45) uses `fetchPendingServiceRequests()`,
which queries **with** the join:
```dart
.select('*, flights(*, stands(*)), service_types(id, name)')
```
so `flight` is populated. Only the **realtime stream path** is missing the join.

> **Note:** The admin dashboard writes a correct, complete `flight_service_requests` row
> (`flight_id`, `service_type_id`, `requested_by`, `assigned_supervisor_id`, `notes`,
> `status='pending'`). No change is needed on the admin side. This is purely a mobile
> realtime-join limitation.

---

## 3. The Fix

Use the realtime stream **only as a "something changed" trigger**, then re-fetch the list
**with the join** so `flight` is always populated. This keeps live updates while restoring
the flight details.

### Option A (recommended — smallest, safest change)

Edit **`dashboard_cubit.dart`**, method `_startRealTimeSubscription`.

**Before:**
```dart
Future<void> _startRealTimeSubscription(String serviceTypeId) async {
  await _requestSubscription?.cancel();
  _requestSubscription = _dashboardRepo
      .watchPendingServiceRequests(serviceTypeId)
      .listen(
    (requests) {
      if (state.status == DashboardStatus.loaded) {
        emit(state.copyWith(
          pendingRequests: requests,
          pendingRequestCount: requests.length,
        ));
      }
    },
    onError: (e) => debugPrint('Dashboard real-time error: $e'),
  );
}
```

**After:**
```dart
Future<void> _startRealTimeSubscription(String serviceTypeId) async {
  await _requestSubscription?.cancel();
  _requestSubscription = _dashboardRepo
      .watchPendingServiceRequests(serviceTypeId)
      .listen(
    (_) async {
      // The realtime stream cannot carry the flights(*) join, so its rows have
      // flight == null. Use the stream purely as a change signal and re-fetch
      // the joined list so flight details are populated.
      if (state.status != DashboardStatus.loaded) return;
      try {
        final joined =
            await _dashboardRepo.fetchPendingServiceRequests(serviceTypeId);
        emit(state.copyWith(
          pendingRequests: joined,
          pendingRequestCount: joined.length,
        ));
      } catch (e) {
        debugPrint('Dashboard re-fetch after stream event failed: $e');
      }
    },
    onError: (e) => debugPrint('Dashboard real-time error: $e'),
  );
}
```

**Trade-off:** one extra lightweight query per realtime event. Acceptable for a
single-airport dashboard. Debounce if request volume is ever high.

### Option B (join stays inside the data source)

Change `watchPendingServiceRequests` in `dashboard_remote_ds.dart` so that, on each stream
emission, it re-queries the affected rows with the join (`asyncMap` → a `.select('*,
flights(*, stands(*)), service_types(id, name)')` fetch filtered by the streamed IDs), then
maps those joined rows to `ServiceRequestModel`. More self-contained but more code than
Option A.

---

## 4. Verification (after applying)

1. Keep the supervisor app open on the dashboard (do **not** refresh).
2. From the admin web dashboard, create a service request for a flight whose service type
   matches this supervisor.
3. The request appears live in the supervisor's Service section.
4. Tap **Details** → the **flight number, route, stand, and times now display** (previously
   blank).
5. Assign a unit → confirm the flow still completes and the request moves to `assigned`.

---

## 5. Optional / related

- **Notification tap does nothing for service requests.** `lib/core/notifications/service/notification_navigator.dart`
  only routes `type == 'task_assigned'` and `type == 'flight_landed'`; the admin sends
  `type: 'alert'`, which hits `default: break` (no navigation). This is separate from the
  blank-detail bug — the supervisor sees requests via the live dashboard regardless. If you
  want the push notification to deep-link, add a `case` that routes a service-request
  notification to the supervisor dashboard. (No supervisor-facing service-request *detail*
  route currently exists; the only one — `adminFlightServiceRequestScreen` — is admin-only.)

- **Admin-side notification body** already includes service type + flight number + notes, so
  the notification text itself is informative even without deep-linking.
