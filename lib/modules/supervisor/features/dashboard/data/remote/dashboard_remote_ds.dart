import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_request_model.dart';

class DashboardRemoteDs {
  const DashboardRemoteDs(this._supabaseService);

  final SupabaseService _supabaseService;

  Future<Map<String, int>> fetchTaskStats(String serviceTypeId) async {
    try {
      final rows = await _supabaseService.client
          .from('tasks')
          .select('status')
          .eq('service_type_id', serviceTypeId);
      final stats = <String, int>{};
      for (final row in rows) {
        final s = row['status'] as String? ?? 'unknown';
        stats[s] = (stats[s] ?? 0) + 1;
      }
      return stats;
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<Map<String, int>> fetchUnitStats(String serviceTypeId) async {
    try {
      final rows = await _supabaseService.client
          .from('units')
          .select('status')
          .eq('service_type_id', serviceTypeId);
      final stats = <String, int>{};
      for (final row in rows) {
        final s = row['status'] as String? ?? 'unknown';
        stats[s] = (stats[s] ?? 0) + 1;
      }
      return stats;
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<int> fetchOpenReportCount(String serviceTypeId) async {
    try {
      final rows = await _supabaseService.client
          .from('reports')
          .select('id, tasks!inner(service_type_id)')
          .eq('tasks.service_type_id', serviceTypeId)
          .eq('status', 'open');
      return rows.length;
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<List<ServiceRequestModel>> fetchPendingServiceRequests(
      String serviceTypeId) async {
    try {
      final rows = await _supabaseService.client
          .from('flight_service_requests')
          .select('*, flights(*, stands(*))')
          .eq('service_type_id', serviceTypeId)
          .eq('status', 'pending')
          .order('created_at', ascending: true);
      return rows
          .map((row) => ServiceRequestModel.fromJson(row))
          .toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<List<UnitModel>> fetchUnitsPreview(String serviceTypeId,
      {int limit = 3}) async {
    try {
      final rows = await _supabaseService.client
          .from('units')
          .select()
          .eq('service_type_id', serviceTypeId)
          .limit(limit);
      return rows
          .map((row) => UnitModel.fromJson(row))
          .toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  Future<String?> fetchServiceTypeName(String serviceTypeId) async {
    try {
      final row = await _supabaseService.client
          .from('service_types')
          .select('name')
          .eq('id', serviceTypeId)
          .maybeSingle();
      return row?['name'] as String?;
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }
}
