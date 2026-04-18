import '../../../../../../core/error/models/app_error.dart';
import '../../../../../../core/shared/data/models/task_model.dart';
import '../remote/task_details_remote_ds.dart';
import 'task_details_repo.dart';

class TaskDetailsRepoImpl implements TaskDetailsRepo {
  final TaskDetailsRemoteDs taskDetailsRemoteDs;

  TaskDetailsRepoImpl({required this.taskDetailsRemoteDs});

  @override
  Future<void> updateChecklistItem({
    required String itemId,
    required bool isChecked,
    required String userId,
  }) {
    return taskDetailsRemoteDs.updateChecklistItem(
      itemId: itemId,
      isChecked: isChecked,
      userId: userId,
    );
  }

  @override
  Future<void> pauseTask({
    required String taskId,
    required String reason,
    required String userId,
  }) {
    return taskDetailsRemoteDs.pauseTask(
      taskId: taskId,
      reason: reason,
      userId: userId,
    );
  }

  @override
  Future<void> resumePause({required String pauseId, required String taskId}) {
    return taskDetailsRemoteDs.resumePause(pauseId: pauseId, taskId: taskId);
  }

  @override
  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    try {
      await taskDetailsRemoteDs.updateTaskStatus(
        taskId: taskId,
        newStatus: newStatus,
      );
    } catch (e) {
      throw e is AppError ? e : AppError.unknown();
    }
  }
}
