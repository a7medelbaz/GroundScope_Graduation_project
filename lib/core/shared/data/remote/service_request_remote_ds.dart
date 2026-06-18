import 'package:easy_localization/easy_localization.dart';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_type.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/service_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceRequestRemoteDs {
  ServiceRequestRemoteDs(this._supabase);
  final SupabaseService _supabase;

  /// Fetch all service requests for a specific flight.
  Future<List<AdminServiceRequestModel>> fetchForFlight(
      String flightId) async {
    try {
      final data = await _supabase.client
          .from('flight_service_requests')
          .select('*, service_types(id, name)')
          .eq('flight_id', flightId)
          .order('created_at', ascending: true);

      return (data as List)
          .map((e) => AdminServiceRequestModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Create a service request for one service type.
  Future<AdminServiceRequestModel> create({
    required String flightId,
    required String serviceTypeId,
    required String requestedBy,
    String? notes,
  }) async {
    try {
      final response = await _supabase.client
          .from('flight_service_requests')
          .insert({
            'flight_id':       flightId,
            'service_type_id': serviceTypeId,
            'requested_by':    requestedBy,
            'status':          'pending',
            'notes':           notes,
          })
          .select('*, service_types(id, name)')
          .single();

      return AdminServiceRequestModel.fromMap(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw AppError(
          messageKey: 'request_already_exists'.tr(),
          type: ErrorType.conflict,
        );
      }
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Cancel a pending service request.
  Future<void> cancel(String requestId) async {
    try {
      await _supabase.client
          .from('flight_service_requests')
          .update({
            'status':     'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId)
          .eq('status', 'pending');
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Fetch summary count of requests by status for dashboard.
  Future<Map<String, int>> fetchStatusSummary() async {
    try {
      final data = await _supabase.client
          .from('flight_service_requests')
          .select('status')
          .not('status', 'eq', 'cancelled');

      final summary = <String, int>{};
      for (final row in data as List) {
        final s = row['status']?.toString() ?? 'pending';
        summary[s] = (summary[s] ?? 0) + 1;
      }
      return summary;
    } catch (_) {
      return {};
    }
  }
}
