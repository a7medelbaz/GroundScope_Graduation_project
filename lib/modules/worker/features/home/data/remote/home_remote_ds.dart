import '../../../../../../core/error/types/error_handler.dart';
import '../../../../../../core/networking/supabase_service.dart';
import '../../../../../../core/shared/data/models/task_model.dart';

class HomeRemoteDs {
  final SupabaseService supabaseService;

  HomeRemoteDs({required this.supabaseService});
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
}
