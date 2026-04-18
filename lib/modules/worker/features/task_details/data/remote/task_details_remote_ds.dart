import '../../../../../../core/error/types/error_handler.dart';
import '../../../../../../core/networking/supabase_service.dart';
import '../../../../../../core/shared/data/models/task_model.dart';

class TaskDetailsRemoteDs {
  const TaskDetailsRemoteDs({required this.supabaseService});

  final SupabaseService supabaseService;

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

  Future<void> pauseTask({
    required String taskId,
    required String reason,
    required String userId,
  }) async {
    try {
      await supabaseService.client
          .from('tasks')
          .update({'status': 'paused'})
          .eq('id', taskId);

      await supabaseService.client.from('task_pauses').insert({
        'task_id': taskId,
        'reason': reason.trim(),
        'paused_by': userId,
      });
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> resumePause({
    required String pauseId,
    required String taskId,
  }) async {
    try {
      await supabaseService.client
          .from('tasks')
          .update({'status': 'in_progress'})
          .eq('id', taskId);
      await supabaseService.client
          .from('task_pauses')
          .update({'resumed_at': DateTime.now().toIso8601String()})
          .eq('id', pauseId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    try {
      await supabaseService.client
          .from('tasks')
          .update({'status': newStatus.dbValue})
          .eq('id', taskId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
