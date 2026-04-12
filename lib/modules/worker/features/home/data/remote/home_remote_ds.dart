import '../../../../../../core/data/models/task_model.dart';
import '../../../../../../core/data/models/unit_model.dart';
import '../../../../../../core/error/models/app_error.dart';
import '../../../../../../core/error/types/error_handler.dart';
import '../../../../../../core/networking/supabase_service.dart';

class HomeRemoteDs {
  final SupabaseService supabaseService;

  HomeRemoteDs({required this.supabaseService});
  Future<List<TaskModel>> fetchWorkerTasks(String unitId) async {
    try {
      final response = await supabaseService.client
          .from('tasks')
          .select('*, flights (*), service_types (*)')
          .eq('unit_id', unitId)
          .order('scheduled_start', ascending: true);

      final dataList = response as List<dynamic>;
      return dataList.map((json) => TaskModel.fromMap(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<UnitModel> fetchUnitData(String userId) async {
    try {
      final response = await supabaseService.client
          .from('users')
          .select('*, units(*)')
          .or('id.eq.$userId,auth_id.eq.$userId')
          .maybeSingle();
      if (response == null) {
        throw AppError.unauthorized("User profile missing.");
      }
      if (response['units'] == null) {
        throw AppError.unauthorized("No unit assigned.");
      }
      return UnitModel.fromJson(response['units'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
