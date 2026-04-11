import '../../../../../../core/data/models/task_model.dart';
import '../../../../../../core/data/models/unit_model.dart';

abstract class HomeRepo {
  Future<List<TaskModel>> fetchWorkerTasks();
  Future<UnitModel> getUnitData();
}
