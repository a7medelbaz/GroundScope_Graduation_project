import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import '../remote/supervisor_units_remote_ds.dart';
import 'supervisor_units_repo.dart';

class SupervisorUnitsRepoImpl implements SupervisorUnitsRepo {
  const SupervisorUnitsRepoImpl(this._ds);

  final SupervisorUnitsRemoteDs _ds;

  @override
  Future<List<UnitModel>> getUnits(String serviceTypeId) =>
      _ds.fetchUnits(serviceTypeId);

  @override
  Stream<List<UnitModel>> watchUnits(String serviceTypeId) {
    return _ds
        .watchUnits(serviceTypeId)
        .map((rows) => rows.map((r) => UnitModel.fromJson(r)).toList());
  }
}
