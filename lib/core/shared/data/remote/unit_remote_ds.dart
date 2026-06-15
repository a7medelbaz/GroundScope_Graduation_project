import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';

class UnitRemoteDs {
  const UnitRemoteDs({required this.supabaseService});

  final SupabaseService supabaseService;
  Future<int> countActiveUnits() async {
    try {
      final data = await supabaseService.client
          .from('units')
          .select('id')
          .inFilter('status', ['available', 'busy']);
      return (data as List).length;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

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

  Future<UnitProfileModel> fetchUnitById(String unitId) async {
    try {
      final response = await supabaseService.client
          .from('units')
          .select('*, service_types(name)')
          .eq('id', unitId)
          .single();
      return UnitProfileModel.fromMap(response);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
