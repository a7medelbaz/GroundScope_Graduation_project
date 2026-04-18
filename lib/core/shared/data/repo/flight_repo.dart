import '../models/flight_model.dart';

abstract class FlightRepo {
  Future<FlightModel> fetchFlightData({required String flightId});
}
