import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/remote/flights_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/flight_repo.dart';

class FlightRepoImpl implements FlightRepo {
  final FlightsRemoteDs flightsRemoteDs;

  FlightRepoImpl({required this.flightsRemoteDs});
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
