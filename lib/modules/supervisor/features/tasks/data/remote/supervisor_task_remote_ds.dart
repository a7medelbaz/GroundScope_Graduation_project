import 'package:flutter/foundation.dart';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupervisorTaskRemoteDs {
  const SupervisorTaskRemoteDs(this._supabaseService);

  final SupabaseService _supabaseService;

  Future<List<TaskModel>> fetchTasks(String serviceTypeId) async {
    try {
      final rows = await _supabaseService.client
          .from('tasks')
          .select('*, flights(*, stands(*)), units(*), service_types(*)')
          .eq('service_type_id', serviceTypeId)
          .order('created_at', ascending: false);
      return rows.map((row) => TaskModel.fromMap(row)).toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('SupervisorTaskRemoteDs.fetchTasks error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }
}
