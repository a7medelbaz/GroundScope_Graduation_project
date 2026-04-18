import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';
import 'package:ground_scope/core/shared/data/models/task_pause_model.dart';

class TaskRemoteDs {
  const TaskRemoteDs({required this.supabaseService});

  final SupabaseService supabaseService;

  Future<List<TaskCheckListModel>> getTaskCheckList({
    required String taskId,
  }) async {
    try {
      final response = await supabaseService.client
          .from('task_checklists')
          .select()
          .eq('task_id', taskId)
          .order('order_index', ascending: true);

      return (response as List<dynamic>)
          .map(
            (json) => TaskCheckListModel.fromMap(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<TaskPauseModel>> getTaskPauseHistory({
    required String taskId,
  }) async {
    try {
      final response = await supabaseService.client
          .from('task_pauses')
          .select()
          .eq('task_id', taskId)
          .order('paused_at', ascending: true);

      return (response as List<dynamic>)
          .map((json) => TaskPauseModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
