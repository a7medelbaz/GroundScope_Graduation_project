import '../../../../../../core/error/types/error_handler.dart';
import '../../../../../../core/networking/supabase_service.dart';
import '../../../../../../core/shared/data/models/task_model.dart';

class HomeRemoteDs {
  final SupabaseService supabaseService;

  HomeRemoteDs({required this.supabaseService});
  Future<List<TaskModel>> fetchWorkerTasks(String unitId) async {
    try {
      print("🔍 FETCHING TASKS FOR UNIT_ID: $unitId");

      final response = await supabaseService.client
          .from('tasks')
          .select('*, flights (*), service_types (*)')
          .eq('unit_id', unitId)
          .order('scheduled_start', ascending: true);

      print("📊 RAW RESPONSE DATA: $response"); // Check if this is []

      final dataList = response as List<dynamic>;
      return dataList.map((json) => TaskModel.fromMap(json)).toList();
    } catch (e) {
      print("❌ SUPABASE ERROR: $e");
      throw ErrorHandler.handle(e);
    }
  }
}
