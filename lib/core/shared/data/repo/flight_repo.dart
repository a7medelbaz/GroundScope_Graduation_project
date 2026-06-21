import '../models/flight_model.dart';
import '../models/stand_model.dart';

abstract class FlightRepo {
  Future<FlightModel> fetchFlightData({required String flightId});
  Future<int> countActiveFlightsToday();

  Future<List<FlightModel>> fetchActiveFlights();

  Future<void> batchUpdateStatus({
    required List<String> flightIds,
    required String newStatus,
  });

  Future<List<FlightModel>> fetchFlights({
    FlightStatus? statusFilter,
    FlightType? typeFilter,
    String? searchQuery,
  });

  Future<void> importFlights(List<FlightModel> flights);

  Future<void> assignStand({
    required String flightId,
    required String standId,
    required DateTime scheduledArrival,
    required DateTime? scheduledDeparture,
  });

  Future<void> unassignStand(String flightId);

  Future<void> updateStatus(String flightId, FlightStatus status);

  Future<List<FlightModel>> fetchFlightsNeedingAttention();

  Future<int> countFlightsNeedingAttention();

  Future<List<StandModel>> fetchAvailableStands({
    required DateTime arrivalTime,
    required DateTime? departureTime,
    String? excludeFlightId,
  });
}
