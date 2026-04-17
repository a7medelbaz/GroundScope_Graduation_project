import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';

class TaskRemoteDs {
  final SupabaseService supabaseService;

  TaskRemoteDs({required this.supabaseService});
  Future<List<TaskCheckListModel>> getTaskCheckList({
    required String taskId,
  }) async {
    try {
      final response = await supabaseService.client
          .from('task_checklists')
          .select()
          .eq('task_id', taskId);
      final dataList = response as List<dynamic>;
      return dataList.map((json) => TaskCheckListModel.fromMap(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
