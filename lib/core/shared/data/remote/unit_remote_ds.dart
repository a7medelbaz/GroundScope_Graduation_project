import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
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

  Future<UnitModel?> fetchUnitModelById(String unitId) async {
    try {
      final data = await supabaseService.client
          .from('units')
          .select('*, service_types(id, name)')
          .eq('id', unitId)
          .maybeSingle();
      if (data == null) return null;
      return UnitModel.fromMap(Map<String, dynamic>.from(data));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<UnitModel>> fetchAll({String? serviceTypeId}) async {
    try {
      final query = supabaseService.client
          .from('units')
          .select('*, service_types(id, name)');

      final data = serviceTypeId != null
          ? await query.eq('service_type_id', serviceTypeId).order('name', ascending: true)
          : await query.order('name', ascending: true);

      return (data as List)
          .map((e) => UnitModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<UnitModel> create(UnitModel model) async {
    try {
      final response = await supabaseService.client
          .from('units')
          .insert(model.toMap())
          .select('*, service_types(id, name)')
          .single();
      return UnitModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<UnitModel> update(UnitModel model) async {
    try {
      final response = await supabaseService.client
          .from('units')
          .update(model.toMap())
          .eq('id', model.id)
          .select('*, service_types(id, name)')
          .single();
      return UnitModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> updateStatus(String unitId, UnitStatus status) async {
    try {
      await supabaseService.client
          .from('units')
          .update({'status': status.value})
          .eq('id', unitId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<TaskModel>> fetchUnitTasks(String unitId) async {
    try {
      final twoHoursAgo = DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String();

      final activeTasks = await supabaseService.client
          .from('tasks')
          .select('*, flights(flight_number), service_types(name, icon)')
          .eq('unit_id', unitId)
          .inFilter('status', ['pending', 'assigned', 'in_progress', 'paused'])
          .order('scheduled_start', ascending: true);

      final recentTasks = await supabaseService.client
          .from('tasks')
          .select('*, flights(flight_number), service_types(name, icon)')
          .eq('unit_id', unitId)
          .inFilter('status', ['completed', 'cancelled'])
          .gte('updated_at', twoHoursAgo)
          .order('updated_at', ascending: false);

      final all = [
        ...(activeTasks as List)
            .map((e) => TaskModel.fromMap(e as Map<String, dynamic>)),
        ...(recentTasks as List)
            .map((e) => TaskModel.fromMap(e as Map<String, dynamic>)),
      ];

      return all;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
