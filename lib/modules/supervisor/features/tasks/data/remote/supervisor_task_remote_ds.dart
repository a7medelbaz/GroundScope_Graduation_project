import 'package:flutter/foundation.dart';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';
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

  Future<(TaskModel, List<TaskCheckListModel>)> fetchTaskById(
      String taskId) async {
    try {
      final row = await _supabaseService.client
          .from('tasks')
          .select(
              '*, flights(*, stands(*)), units(*, unit_members(*)), service_types(*), task_checklists(*)')
          .eq('id', taskId)
          .single();

      final task = TaskModel.fromMap(row);
      final checklists = (row['task_checklists'] as List<dynamic>? ?? [])
          .map((m) => TaskCheckListModel.fromMap(m as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      return (task, checklists);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('SupervisorTaskRemoteDs.fetchTaskById error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _supabaseService.client.from('tasks').update({
        'status': newStatus,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', taskId);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('SupervisorTaskRemoteDs.updateTaskStatus error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }
}
