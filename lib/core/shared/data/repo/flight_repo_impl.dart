import '../models/flight_model.dart';
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
}
