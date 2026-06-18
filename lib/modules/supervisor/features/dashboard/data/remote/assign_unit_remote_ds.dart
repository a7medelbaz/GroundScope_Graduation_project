import 'package:flutter/foundation.dart';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignUnitRemoteDs {
  const AssignUnitRemoteDs(this._supabaseService);

  final SupabaseService _supabaseService;

  Future<List<UnitModel>> fetchAvailableUnits(String serviceTypeId) async {
    try {
      final rows = await _supabaseService.client
          .from('units')
          .select('*')
          .eq('service_type_id', serviceTypeId)
          .eq('status', 'available');
      return rows.map((row) => UnitModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('fetchAvailableUnits error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }

  /// Creates a task from a service request.
  /// 1. Inserts task row, captures generated ID
  /// 2. Inserts task_checklists rows (if any)
  /// 3. Updates flight_service_requests status → 'assigned'
  Future<void> createTaskFromRequest({
    required String requestId,
    required String flightId,
    required String serviceTypeId,
    required String unitId,
    required String assignedBy,
    required String priority,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    required List<String> checklistItems,
    String? notes,
  }) async {
    try {
      final taskRow = await _supabaseService.client
          .from('tasks')
          .insert({
            'flight_id':       flightId,
            'service_type_id': serviceTypeId,
            'unit_id':         unitId,
            'assigned_by':     assignedBy,
            'created_by':      assignedBy,
            'status':          'assigned',
            'priority':        priority,
            'scheduled_start': scheduledStart.toIso8601String(),
            'scheduled_end':   scheduledEnd.toIso8601String(),
            'notes':           notes,
          })
          .select('id')
          .single();

      final taskId = taskRow['id'] as String;

      if (checklistItems.isNotEmpty) {
        final rows = checklistItems
            .asMap()
            .entries
            .map((e) => {
                  'task_id':     taskId,
                  'item':        e.value,
                  'is_checked':  false,
                  'order_index': e.key,
                })
            .toList();
        await _supabaseService.client.from('task_checklists').insert(rows);
      }

      await _supabaseService.client
          .from('flight_service_requests')
          .update({
            'status':                  'assigned',
            'assigned_supervisor_id':  assignedBy,
            'updated_at':              DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('createTaskFromRequest error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }
}
