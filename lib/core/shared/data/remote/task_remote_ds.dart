import 'package:ground_scope/core/shared/data/models/task_model.dart';
import '../../../error/types/error_handler.dart';
import '../../../networking/supabase_service.dart';
import '../models/task_check_list_model.dart';
import '../models/task_pause_model.dart';

class TaskRemoteDs {
  const TaskRemoteDs({required this.supabaseService});

  final SupabaseService supabaseService;

  Future<int> countPendingTasks() async {
    try {
      final data = await supabaseService.client
          .from('tasks')
          .select('id')
          .inFilter('status', ['pending', 'in_progress']);
      return (data as List).length;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<TaskModel>> fetchWorkerTasks(String unitId) async {
    try {
      final response = await supabaseService.client
          .from('tasks')
          .select('''
          *,
          service_types (*),
          flights (
            *,
            stands (*)
          )
        ''')
          .eq('unit_id', unitId)
          .order('scheduled_start', ascending: true);

      final dataList = response as List<dynamic>;
      return dataList.map((json) => TaskModel.fromMap(json)).toList();
    } catch (e) {
      print("❌ SUPABASE ERROR: $e");
      throw ErrorHandler.handle(e);
    }
  }

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
