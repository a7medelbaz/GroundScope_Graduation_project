import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';
import 'package:ground_scope/core/shared/data/models/task_pause_model.dart';
import 'package:ground_scope/core/shared/data/remote/task_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/task_repo.dart';

class TaskRepoImpl implements TaskRepo {
  final TaskRemoteDs taskRemoteDs;

  TaskRepoImpl({required this.taskRemoteDs});
  @override
  Future<List<TaskCheckListModel>> getTaskCheckList({required String taskId}) {
    return taskRemoteDs.getTaskCheckList(taskId: taskId);
  }

  @override
  Future<List<TaskPauseModel>> getTaskPauseHistory({required String taskId}) {
    return taskRemoteDs.getTaskPauseHistory(taskId: taskId);
  }
}
