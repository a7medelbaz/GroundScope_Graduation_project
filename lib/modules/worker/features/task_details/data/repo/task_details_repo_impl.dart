import 'package:ground_scope/modules/worker/features/task_details/data/remote/task_details_remote_ds.dart';
import 'package:ground_scope/modules/worker/features/task_details/data/repo/task_details_repo.dart';

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
}
