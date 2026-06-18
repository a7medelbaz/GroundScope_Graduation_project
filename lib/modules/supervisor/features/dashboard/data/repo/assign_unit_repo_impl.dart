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
    required String requestId,
    required String unitId,
    required String assignedBy,
    required String flightId,
    required String serviceTypeId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? notes,
  }) =>
      _ds.assignUnit(
        requestId:      requestId,
        unitId:         unitId,
        assignedBy:     assignedBy,
        flightId:       flightId,
        serviceTypeId:  serviceTypeId,
        scheduledStart: scheduledStart,
        scheduledEnd:   scheduledEnd,
        notes:          notes,
      );
}
