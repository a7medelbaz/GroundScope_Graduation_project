import '../models/task_check_list_model.dart';
import '../models/task_pause_model.dart';

abstract class TaskRepo {
  Future<List<TaskCheckListModel>> getTaskCheckList({required String taskId});
  Future<List<TaskPauseModel>> getTaskPauseHistory({required String taskId});
}
