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
  Future<void> createTaskFromRequest({
    required String requestId,
    required String flightId,
    required String serviceTypeId,
    required String unitId,
    required String assignedBy,
    required String priority,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    required List<String> checklistItems,
    String? notes,
  }) =>
      _ds.createTaskFromRequest(
        requestId:      requestId,
        flightId:       flightId,
        serviceTypeId:  serviceTypeId,
        unitId:         unitId,
        assignedBy:     assignedBy,
        priority:       priority,
        scheduledStart: scheduledStart,
        scheduledEnd:   scheduledEnd,
        checklistItems: checklistItems,
        notes:          notes,
      );
}
