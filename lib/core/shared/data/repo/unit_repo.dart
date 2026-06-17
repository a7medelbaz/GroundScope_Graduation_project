import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';

abstract class UnitRepo {
  Future<UnitModel> getUnitData({required String unitId});
  Future<UnitProfileModel> fetchUnitById(String unitId);
  Future<int> countActiveUnits();
  Future<List<UnitModel>> fetchAll({String? serviceTypeId});
  Future<UnitModel?> fetchUnitModelById(String unitId);
  Future<UnitModel> create(UnitModel model);
  Future<UnitModel> update(UnitModel model);
  Future<void> updateStatus(String unitId, UnitStatus status);
  Future<List<TaskModel>> fetchUnitTasks(String unitId);
}
