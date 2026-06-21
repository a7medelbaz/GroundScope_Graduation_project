import '../shared/data/models/flight_model.dart';

class FlightStatusChecker {
  /// Returns a map of newStatus → list of flight IDs that need auto-updating.
  static Map<String, List<String>> checkAutoUpdates(List<FlightModel> flights) {
    final now = DateTime.now();
    final updates = <String, List<String>>{};

    for (final flight in flights) {
      final newStatus = _getAutoStatus(flight, now);
      if (newStatus != null) {
        updates.putIfAbsent(newStatus, () => []).add(flight.id);
      }
    }

    return updates;
  }

  static String? _getAutoStatus(FlightModel flight, DateTime now) {
    // scheduled → landed: arrival time has passed and not manually recorded
    if (flight.status == FlightStatus.scheduled &&
        now.isAfter(flight.scheduledArrival) &&
        flight.actualArrival == null) {
      return 'landed';
    }

    // ready → departed: departure time has passed
    if (flight.status == FlightStatus.ready &&
        flight.scheduledDeparture != null &&
        now.isAfter(flight.scheduledDeparture!)) {
      return 'departed';
    }

    return null;
  }

  /// Returns true if admin can create service requests for this flight.
  static bool canRequestServices(FlightModel flight) {
    return flight.status == FlightStatus.scheduled ||
        flight.status == FlightStatus.landed;
  }

  /// Returns true if flight needs attention (arriving within 3h, no stand).
  static bool isWarning(FlightModel flight) {
    final now = DateTime.now();
    final in3Hours = now.add(const Duration(hours: 3));
    return flight.status == FlightStatus.scheduled &&
        flight.standId == null &&
        flight.scheduledArrival.isAfter(now) &&
        flight.scheduledArrival.isBefore(in3Hours);
  }

  /// Returns the valid next statuses from the current one (forward-only).
  static List<FlightStatus> allowedNextStatuses(FlightStatus current) {
    return switch (current) {
      FlightStatus.scheduled => [FlightStatus.landed, FlightStatus.cancelled],
      FlightStatus.landed    => [FlightStatus.inService, FlightStatus.cancelled],
      FlightStatus.inService => [FlightStatus.ready, FlightStatus.cancelled],
      FlightStatus.ready     => [FlightStatus.departed],
      _                      => [],
    };
  }

  /// Sort order: active first, then scheduled, ready, departed/cancelled last.
  static int sortFlights(FlightModel a, FlightModel b) {
    final orderA = _sortOrder(a);
    final orderB = _sortOrder(b);
    if (orderA != orderB) return orderA.compareTo(orderB);
    return a.scheduledArrival.compareTo(b.scheduledArrival);
  }

  static int _sortOrder(FlightModel f) => switch (f.status) {
    FlightStatus.inService => 0,
    FlightStatus.landed    => 1,
    FlightStatus.scheduled => 2,
    FlightStatus.ready     => 3,
    FlightStatus.departed  => 4,
    FlightStatus.cancelled => 5,
  };
}
