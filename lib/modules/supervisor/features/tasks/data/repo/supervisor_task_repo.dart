import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';

abstract class SupervisorTaskRepo {
  Future<List<TaskModel>> getTasks(String serviceTypeId);
  Stream<List<TaskModel>> watchTasks(String serviceTypeId);
  Future<(TaskModel, List<TaskCheckListModel>)> getTaskById(String taskId);
  Future<void> updateTaskStatus(String taskId, String newStatus);
}
