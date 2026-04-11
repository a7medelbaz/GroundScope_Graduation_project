import 'package:ground_scope/core/data/models/task_model.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';

class HomeRemoteDs {
  final SupabaseService supabaseService;

  HomeRemoteDs({required this.supabaseService});

  Future<List<TaskModel>> fetchWorkerTasks(String unitId) async {
    try {
      final response = await supabaseService.client
          .from('tasks')
          .select('''
            *,
            flights (*),
            service_types (*)
          ''')
          .eq('unit_id', unitId)
          .order('scheduled_start', ascending: true);
      final dataList = response as List<dynamic>;
      return dataList.map((json) => TaskModel.fromMap(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
