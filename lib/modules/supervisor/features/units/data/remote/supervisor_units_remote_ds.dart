import 'package:flutter/foundation.dart';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupervisorUnitsRemoteDs {
  const SupervisorUnitsRemoteDs(this._supabaseService);

  final SupabaseService _supabaseService;

  Future<List<UnitModel>> fetchUnits(String serviceTypeId) async {
    try {
      final rows = await _supabaseService.client
          .from('units')
          .select('*, unit_members(*)')
          .eq('service_type_id', serviceTypeId)
          .order('name', ascending: true);
      return rows.map((row) => UnitModel.fromJson(row)).toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('SupervisorUnitsRemoteDs.fetchUnits error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }

  // Returns a raw stream — .stream() does not support joins.
  // Members are preserved in the cubit by merging with existing state.
  Stream<List<Map<String, dynamic>>> watchUnits(String serviceTypeId) {
    return _supabaseService.client
        .from('units')
        .stream(primaryKey: ['id'])
        .eq('service_type_id', serviceTypeId);
  }
}
