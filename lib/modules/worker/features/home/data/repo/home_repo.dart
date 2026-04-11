import 'package:ground_scope/core/data/models/task_model.dart';
import 'package:ground_scope/core/data/models/unit_model.dart';

abstract class HomeRepo {
  Future<List<TaskModel>> fetchWorkerTasks();
  Future<UnitModel> getUnitData();
}
