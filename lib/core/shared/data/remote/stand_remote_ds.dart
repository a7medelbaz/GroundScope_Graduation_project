import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
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

  /// Counts all active (non-terminal) flights currently assigned to this
  /// stand. No time filter — a flight with `stand_id` set occupies the
  /// stand regardless of when its `scheduled_arrival` falls.
  Future<int> countFlightsAtStand(String standId) async {
    try {
      final data = await supabaseService.client
          .from('flights')
          .select('id')
          .eq('stand_id', standId)
          .inFilter('status', ['scheduled', 'landed', 'in_service', 'ready']);
      return (data as List).length;
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Fetches all flights assigned to a specific stand.
  /// Shows past, current, and upcoming flights ordered by scheduled_arrival.
  /// No time filter — if a flight has stand_id set, show it.
  Future<List<FlightModel>> fetchFlightsForStand(String standId) async {
    try {
      final data = await supabaseService.client
          .from('flights')
          .select()
          .eq('stand_id', standId)
          .not('status', 'eq', 'cancelled') // exclude cancelled flights
          .not('status', 'eq', 'departed') // exclude departed flights
          .order('scheduled_arrival', ascending: true);

      return (data as List)
          .map((e) => FlightModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }
}
