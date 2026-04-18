import '../../../../../../core/shared/data/models/task_model.dart';

abstract class HomeRepo {
  Future<List<TaskModel>> fetchWorkerTasks({required String unitId});
}
