import 'package:ground_scope/core/shared/data/models/task_model.dart';

import '../models/task_check_list_model.dart';
import '../models/task_pause_model.dart';

abstract class TaskRepo {
  Future<List<TaskModel>> fetchWorkerTasks({required String unitId});
  Future<List<TaskCheckListModel>> getTaskCheckList({required String taskId});
  Future<List<TaskPauseModel>> getTaskPauseHistory({required String taskId});
}
