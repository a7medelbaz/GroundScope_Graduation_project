import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';

class TaskDetailsRemoteDs {
  final SupabaseService supabaseService;

  TaskDetailsRemoteDs({required this.supabaseService});
  Future<void> updateChecklistItem({
    required String itemId,
    required bool isChecked,
    required String userId,
  }) async {
    try {
      await supabaseService.client
          .from('task_checklists')
          .update({
            'is_checked': isChecked,
            'checked_at': isChecked ? DateTime.now().toIso8601String() : null,
            'checked_by': isChecked ? userId : null,
          })
          .eq('id', itemId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
