import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/stand_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StandRemoteDs {
  StandRemoteDs({required this.supabaseService});
  final SupabaseService supabaseService;

  Future<List<StandModel>> fetchAll({bool? isActive}) async {
    try {
      final data = await supabaseService.client
          .from('stands')
          .select()
          .order('code', ascending: true);
      final list = (data as List)
          .map((e) => StandModel.fromMap(e as Map<String, dynamic>))
          .toList();
      return isActive == null
          ? list
          : list.where((s) => s.isActive == isActive).toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  Future<StandModel> create(StandModel model) async {
    try {
      final response = await supabaseService.client
          .from('stands')
          .insert(model.toMap())
          .select()
          .single();
      return StandModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  Future<StandModel> update(StandModel model) async {
    try {
      final response = await supabaseService.client
          .from('stands')
          .update(model.toMap())
          .eq('id', model.id)
          .select()
          .single();
      return StandModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  Future<void> setActive(String id, bool isActive) async {
    try {
      await supabaseService.client
          .from('stands')
          .update({'is_active': isActive}).eq('id', id);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  Future<int> countFlightsAtStand(String standId) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final data = await supabaseService.client
          .from('flights')
          .select('id')
          .eq('stand_id', standId)
          .inFilter('status', ['scheduled', 'landed', 'in_service', 'ready'])
          .gte('scheduled_arrival', '${today}T00:00:00')
          .lte('scheduled_arrival', '${today}T23:59:59');
      return (data as List).length;
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }
}
