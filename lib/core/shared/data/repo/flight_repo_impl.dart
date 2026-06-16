import '../models/flight_model.dart';
import '../models/stand_model.dart';
import '../remote/flights_remote_ds.dart';
import 'flight_repo.dart';

class FlightRepoImpl implements FlightRepo {
  final FlightsRemoteDs flightsRemoteDs;

  FlightRepoImpl({required this.flightsRemoteDs});

  @override
  Future<int> countActiveFlightsToday() =>
      flightsRemoteDs.countActiveFlightsToday();

  @override
  Future<FlightModel> fetchFlightData({required String flightId}) {
    final flightData = flightsRemoteDs.fetchFlightById(flightId);

    return flightData.then((flight) {
      if (flight == null) {
        throw Exception('Flight not found for ID: $flightId');
      }
      return flight;
    });
  }

  @override
  Future<List<FlightModel>> fetchFlights({
    FlightStatus? statusFilter,
    FlightType? typeFilter,
    String? searchQuery,
  }) => flightsRemoteDs.fetchFlights(
    statusFilter: statusFilter,
    typeFilter: typeFilter,
    searchQuery: searchQuery,
  );

  @override
  Future<void> importFlights(List<FlightModel> flights) =>
      flightsRemoteDs.importFlights(flights);

  @override
  Future<void> assignStand({
    required String flightId,
    required String standId,
    required DateTime scheduledArrival,
    required DateTime? scheduledDeparture,
  }) => flightsRemoteDs.assignStand(
    flightId: flightId,
    standId: standId,
    scheduledArrival: scheduledArrival,
    scheduledDeparture: scheduledDeparture,
  );

  @override
  Future<void> unassignStand(String flightId) =>
      flightsRemoteDs.unassignStand(flightId);

  @override
  Future<void> updateStatus(String flightId, FlightStatus status) =>
      flightsRemoteDs.updateStatus(flightId, status);

  @override
  Future<List<FlightModel>> fetchFlightsNeedingAttention() =>
      flightsRemoteDs.fetchFlightsNeedingAttention();

  @override
  Future<int> countFlightsNeedingAttention() =>
      flightsRemoteDs.countFlightsNeedingAttention();

  @override
  Future<List<StandModel>> fetchAvailableStands({
    required DateTime arrivalTime,
    required DateTime? departureTime,
    String? excludeFlightId,
  }) => flightsRemoteDs.fetchAvailableStands(
    arrivalTime: arrivalTime,
    departureTime: departureTime,
    excludeFlightId: excludeFlightId,
  );
}
