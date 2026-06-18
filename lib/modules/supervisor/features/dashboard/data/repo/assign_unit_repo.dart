import 'package:ground_scope/core/shared/data/models/unit_model.dart';

abstract class AssignUnitRepo {
  Future<List<UnitModel>> getAvailableUnits(String serviceTypeId);

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
  });
}
