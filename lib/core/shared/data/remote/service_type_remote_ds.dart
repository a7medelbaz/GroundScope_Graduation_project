import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';

class ServiceTypeRemoteDs {
  ServiceTypeRemoteDs({required this.supabaseService});
  final SupabaseService supabaseService;

  Future<List<ServiceTypeModel>> fetchAll({bool? isActive}) async {
    try {
      var query = supabaseService.client.from('service_types').select();

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      final data = await query.order('name', ascending: true);
      return (data as List).map((e) => ServiceTypeModel.fromMap(e)).toList();
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<ServiceTypeModel> fetchById(String id) async {
    try {
      final data = await supabaseService.client
          .from('service_types')
          .select()
          .eq('id', id)
          .single();
      return ServiceTypeModel.fromMap(data);
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<ServiceTypeModel> create(ServiceTypeModel model) async {
    try {
      final data = await supabaseService.client
          .from('service_types')
          .insert(model.toMap())
          .select()
          .single();
      return ServiceTypeModel.fromMap(data);
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<ServiceTypeModel> update(ServiceTypeModel model) async {
    try {
      final data = await supabaseService.client
          .from('service_types')
          .update(model.toMap())
          .eq('id', model.id)
          .select()
          .single();
      return ServiceTypeModel.fromMap(data);
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<void> setActive(String id, bool isActive) async {
    try {
      await supabaseService.client
          .from('service_types')
          .update({'is_active': isActive})
          .eq('id', id);
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<int> countUnitsUsingServiceType(String serviceTypeId) async {
    try {
      final data = await supabaseService.client
          .from('units')
          .select('id')
          .eq('service_type_id', serviceTypeId);
      return (data as List).length;
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<int> countActiveTasksUsingServiceType(String serviceTypeId) async {
    try {
      final units = await supabaseService.client
          .from('units')
          .select('id')
          .eq('service_type_id', serviceTypeId);

      final unitIds =
          (units as List).map((u) => u['id'] as String).toList();
      if (unitIds.isEmpty) return 0;

      final tasks = await supabaseService.client
          .from('tasks')
          .select('id')
          .inFilter('unit_id', unitIds)
          .inFilter('status', ['pending', 'in_progress', 'paused']);

      return (tasks as List).length;
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }
}
