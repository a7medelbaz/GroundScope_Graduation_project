import 'package:ground_scope/core/shared/data/models/unit_model.dart';

abstract class SupervisorUnitsRepo {
  Future<List<UnitModel>> getUnits(String serviceTypeId);
  Stream<List<UnitModel>> watchUnits(String serviceTypeId);
}
