import '../models/task_check_list_model.dart';
import '../models/task_pause_model.dart';
import '../remote/task_remote_ds.dart';
import 'task_repo.dart';

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
