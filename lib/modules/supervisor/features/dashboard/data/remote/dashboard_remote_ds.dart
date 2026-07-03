import 'package:flutter/foundation.dart';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_request_model.dart';

class DashboardRemoteDs {
  const DashboardRemoteDs(this._supabaseService);

  final SupabaseService _supabaseService;

  /// Rolling window: only show items from the last 12 hours to keep the
  /// dashboard fast and focused on active work.
  static const Duration _window = Duration(hours: 12);

  static String get _windowCutoff =>
      DateTime.now().toUtc().subtract(_window).toIso8601String();

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
    } catch (e, st) {
      debugPrint('fetchTaskStats error: $e\n$st');
      throw AppError.unknown(e.toString());
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
    } catch (e, st) {
      debugPrint('fetchUnitStats error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }

  /// Counts open reports for this service type.
  /// Uses a two-step query to avoid PostgREST inner-join filter syntax issues:
  /// 1. Fetch task IDs belonging to this service type.
  /// 2. Count open reports whose task_id is in that set.
  Future<int> fetchOpenReportCount(String serviceTypeId) async {
    try {
      final taskRows = await _supabaseService.client
          .from('tasks')
          .select('id')
          .eq('service_type_id', serviceTypeId);

      if (taskRows.isEmpty) return 0;

      final taskIds =
          taskRows.map((r) => r['id'] as String).toList();

      final reportRows = await _supabaseService.client
          .from('reports')
          .select('id')
          .inFilter('task_id', taskIds)
          .eq('status', 'open');

      return reportRows.length;
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('fetchOpenReportCount error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }

  /// Fetches pending service requests for this supervisor's service type.
  /// Reads from flight_service_requests, not tasks.
  Future<List<ServiceRequestModel>> fetchPendingServiceRequests(
      String serviceTypeId) async {
    try {
      final rows = await _supabaseService.client
          .from('flight_service_requests')
          .select('*, flights(*, stands(*)), service_types(id, name)')
          .eq('service_type_id', serviceTypeId)
          .eq('status', 'pending')
          .gte('created_at', _windowCutoff)
          .order('created_at', ascending: true);

      return rows
          .map((row) => ServiceRequestModel.fromJson(row))
          .toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('fetchPendingServiceRequests error: $e\n$st');
      throw AppError.unknown(e.toString());
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
    } catch (e, st) {
      debugPrint('fetchUnitsPreview error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }

  /// Real-time stream of pending service requests for this service type.
  Stream<List<ServiceRequestModel>> watchPendingServiceRequests(
      String serviceTypeId) {
    final cutoff = _windowCutoff;
    return _supabaseService.client
        .from('flight_service_requests')
        .stream(primaryKey: ['id'])
        .eq('service_type_id', serviceTypeId)
        .map((rows) => rows
            .where((r) =>
                r['status'] == 'pending' &&
                (r['created_at'] as String?) != null &&
                (r['created_at'] as String).compareTo(cutoff) >= 0)
            .map((r) => ServiceRequestModel.fromJson(r))
            .toList());
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
    } catch (e, st) {
      debugPrint('fetchServiceTypeName error: $e\n$st');
      throw AppError.unknown(e.toString());
    }
  }
}