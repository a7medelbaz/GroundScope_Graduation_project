import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import '../remote/assign_unit_remote_ds.dart';
import 'assign_unit_repo.dart';

class AssignUnitRepoImpl implements AssignUnitRepo {
  const AssignUnitRepoImpl(this._ds);

  final AssignUnitRemoteDs _ds;

  @override
  Future<List<UnitModel>> getAvailableUnits(String serviceTypeId) =>
      _ds.fetchAvailableUnits(serviceTypeId);

  @override
  Future<void> assignUnit({
    required String taskId,
    required String unitId,
    required String assignedBy,
  }) =>
      _ds.assignUnit(taskId: taskId, unitId: unitId, assignedBy: assignedBy);
}