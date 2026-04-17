import 'package:ground_scope/core/shared/data/models/flight_model.dart';

abstract class FlightRepo {
  Future<FlightModel> fetchFlightData({required String flightId});
}
