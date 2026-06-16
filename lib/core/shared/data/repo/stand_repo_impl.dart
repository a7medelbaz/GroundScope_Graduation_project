import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/stand_model.dart';
import 'package:ground_scope/core/shared/data/remote/stand_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/stand_repo.dart';

class StandRepoImpl implements StandRepo {
  StandRepoImpl({required this.standRemoteDs});
  final StandRemoteDs standRemoteDs;

  @override
  Future<List<StandModel>> fetchAll({bool? isActive}) =>
      standRemoteDs.fetchAll(isActive: isActive);

  @override
  Future<StandModel> create(StandModel model) => standRemoteDs.create(model);

  @override
  Future<StandModel> update(StandModel model) => standRemoteDs.update(model);

  @override
  Future<void> setActive(String id, bool isActive) =>
      standRemoteDs.setActive(id, isActive);

  @override
  Future<int> countFlightsAtStand(String standId) =>
      standRemoteDs.countFlightsAtStand(standId);

  @override
  Future<List<FlightModel>> fetchFlightsForStand(String standId) =>
      standRemoteDs.fetchFlightsForStand(standId);
}
