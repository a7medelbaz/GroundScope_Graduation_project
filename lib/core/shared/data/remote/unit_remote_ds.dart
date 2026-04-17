// lib/core/shared/data/remote/unit_remote_ds.dart

import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';

class UnitRemoteDs {
  const UnitRemoteDs({required this.supabaseService});

  final SupabaseService supabaseService;
  Future<UnitModel> fetchUnitData(String unitId) async {
    try {
      final response = await supabaseService.client
          .from('units')
          .select()
          .eq('id', unitId)
          .maybeSingle();

      if (response == null) {
        throw AppError.unauthorized("Unit not found with ID: $unitId");
      }
      return UnitModel.fromJson(response);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
