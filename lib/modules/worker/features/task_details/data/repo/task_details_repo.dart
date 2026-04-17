import 'package:ground_scope/core/shared/data/models/task_model.dart';

abstract class TaskDetailsRepo {
  Future<void> updateChecklistItem({
    required String itemId,
    required bool isChecked,
    required String userId,
  });
  Future<void> pauseTask({
    required String taskId,
    required String reason,
    required String userId,
  });
  Future<void> resumePause({required String pauseId, required String taskId});
  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus newStatus,
  });
}
