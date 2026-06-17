import 'package:ground_scope/core/shared/data/models/unit_model.dart';

abstract class AssignUnitRepo {
  Future<List<UnitModel>> getAvailableUnits(String serviceTypeId);
  Future<void> assignUnit({
    required String taskId,
    required String unitId,
    required String assignedBy,
  });
}