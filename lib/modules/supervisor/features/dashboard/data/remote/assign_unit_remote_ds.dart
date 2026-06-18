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

  /// Assigns a unit to a service request.
  /// 1. Updates flight_service_requests status → 'assigned'
  /// 2. Creates a new task for the unit
  Future<void> assignUnit({
    required String requestId,
    required String unitId,
    required String assignedBy,
    required String flightId,
    required String serviceTypeId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? notes,
  }) async {
    try {
      await _supabaseService.client
          .from('flight_service_requests')
          .update({
            'status': 'assigned',
            'assigned_supervisor_id': assignedBy,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      await _supabaseService.client
          .from('tasks')
          .insert({
            'flight_id':       flightId,
            'service_type_id': serviceTypeId,
            'unit_id':         unitId,
            'assigned_by':     assignedBy,
            'created_by':      assignedBy,
            'status':          'assigned',
            'priority':        'medium',
            'scheduled_start': scheduledStart.toIso8601String(),
            'scheduled_end':   scheduledEnd.toIso8601String(),
            'notes':           notes,
          });
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('assignUnit error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }
}
