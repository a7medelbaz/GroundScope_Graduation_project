abstract class TaskDetailsRepo {
  Future<void> updateChecklistItem({
    required String itemId,
    required bool isChecked,
    required String userId,
  });
}
