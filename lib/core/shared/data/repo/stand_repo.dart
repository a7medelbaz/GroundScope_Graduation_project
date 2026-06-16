import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/stand_model.dart';

abstract class StandRepo {
  Future<List<StandModel>> fetchAll({bool? isActive});
  Future<StandModel> create(StandModel model);
  Future<StandModel> update(StandModel model);
  Future<void> setActive(String id, bool isActive);
  Future<int> countFlightsAtStand(String standId);
  Future<List<FlightModel>> fetchFlightsForStand(String standId);
}
