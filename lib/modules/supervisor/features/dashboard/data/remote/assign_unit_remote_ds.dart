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

  // The "service request" is the task itself (status=pending, unit_id=null).
  // Assigning a unit updates the task in-place: set unit_id, assigned_by, status=in_progress.
  Future<void> assignUnit({
    required String taskId,
    required String unitId,
    required String assignedBy,
  }) async {
    try {
      await _supabaseService.client.from('tasks').update({
        'unit_id': unitId,
        'assigned_by': assignedBy,
        'status': 'in_progress',
      }).eq('id', taskId);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('assignUnit error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }
}