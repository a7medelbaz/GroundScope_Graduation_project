import 'package:ground_scope/core/shared/data/models/unit_model.dart';

abstract class AssignUnitRepo {
  Future<List<UnitModel>> getAvailableUnits(String serviceTypeId);

  Future<void> assignUnit({
    required String requestId,
    required String unitId,
    required String assignedBy,
    required String flightId,
    required String serviceTypeId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? notes,
  });
}
