import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../error/handlers/supabase_error_handler.dart';
import '../../../error/models/app_error.dart';
import '../../../error/types/error_handler.dart';
import '../../../error/types/error_type.dart';
import '../../../networking/supabase_service.dart';
import '../models/flight_model.dart';
import '../models/stand_model.dart';

class FlightsRemoteDs {
  final SupabaseService supabaseService;

  FlightsRemoteDs({required this.supabaseService});

  static const _occupyingStatuses = [
    'scheduled',
    'landed',
    'in_service',
    'ready',
  ];

  Future<int> countActiveFlightsToday() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final data = await supabaseService.client
          .from('flights')
          .select('id')
          .inFilter('status', _occupyingStatuses)
          .gte('scheduled_arrival', '${today}T00:00:00')
          .lte('scheduled_arrival', '${today}T23:59:59');
      return (data as List).length;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Fetches flight details including the stand information
  Future<FlightModel?> fetchFlightById(String flightId) async {
    try {
      final response = await supabaseService.client
          .from('flights')
          .select('*, stands (*)') // Join with stands table
          .eq('id', flightId) // Primary key is 'id' in your SQL
          .maybeSingle();

      if (response == null) return null;

      return FlightModel.fromMap(response);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Fetches flights relevant for today's operations:
  /// - Scheduled in next 12 hours
  /// - Currently active (landed, in_service)
  /// - Ready to depart (today)
  /// - Departed/cancelled today
  Future<List<FlightModel>> fetchActiveFlights() async {
    try {
      final now        = DateTime.now();
      final plus12h    = now.add(const Duration(hours: 12));
      final todayStart = DateTime(now.year, now.month, now.day);

      final scheduled = await supabaseService.client
          .from('flights')
          .select('*, stands(*)')
          .eq('status', 'scheduled')
          .gte('scheduled_arrival', now.toIso8601String())
          .lte('scheduled_arrival', plus12h.toIso8601String())
          .order('scheduled_arrival', ascending: true);

      final active = await supabaseService.client
          .from('flights')
          .select('*, stands(*)')
          .inFilter('status', ['landed', 'in_service'])
          .order('scheduled_arrival', ascending: true);

      final ready = await supabaseService.client
          .from('flights')
          .select('*, stands(*)')
          .eq('status', 'ready')
          .gte('scheduled_departure', todayStart.toIso8601String())
          .order('scheduled_departure', ascending: true);

      final done = await supabaseService.client
          .from('flights')
          .select('*, stands(*)')
          .inFilter('status', ['departed', 'cancelled'])
          .gte('scheduled_arrival', todayStart.toIso8601String())
          .order('scheduled_arrival', ascending: true);

      final all = [
        ...(scheduled as List),
        ...(active    as List),
        ...(ready     as List),
        ...(done      as List),
      ];

      final seen   = <String>{};
      final unique = all
          .cast<Map<String, dynamic>>()
          .where((e) => seen.add(e['id'] as String))
          .map((e) => FlightModel.fromMap(e))
          .toList();

      return unique;
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Fetches ALL flights without any filtering.
  /// Used by the "All" filter to show complete flight list.
  Future<List<FlightModel>> fetchAllFlights() async {
    try {
      debugPrint('FETCH_ALL: Starting fetchAllFlights');
      final response = await supabaseService.client
          .from('flights')
          .select('*, stands(*)')
          .order('scheduled_arrival', ascending: true);

      debugPrint('FETCH_ALL: Response type: ${response.runtimeType}');
      debugPrint('FETCH_ALL: Response length: ${(response as List).length}');

      final flights = (response as List)
          .cast<Map<String, dynamic>>()
          .map((e) => FlightModel.fromMap(e))
          .toList();

      debugPrint('FETCH_ALL: Parsed ${flights.length} flights');
      return flights;
    } on PostgrestException catch (e) {
      debugPrint('FETCH_ALL DB ERROR: ${e.message}');
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('FETCH_ALL ERROR: $e');
      debugPrint('FETCH_ALL STACK: $st');
      throw AppError.unknown();
    }
  }

  /// Updates multiple flights to a new status in one call.
  Future<void> batchUpdateStatus({
    required List<String> flightIds,
    required String newStatus,
  }) async {
    if (flightIds.isEmpty) return;
    try {
      await supabaseService.client
          .from('flights')
          .update({
            'status':     newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .inFilter('id', flightIds);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Fetches all flights for the list screen with optional filters.
  Future<List<FlightModel>> fetchFlights({
    FlightStatus? statusFilter,
    FlightType? typeFilter,
    String? searchQuery,
  }) async {
    try {
      var query = supabaseService.client.from('flights').select('*, stands(*)');

      if (statusFilter != null) {
        query = query.eq('status', statusFilter.toDbString);
      }

      if (typeFilter != null) {
        query = query.eq(
          'flight_type',
          typeFilter == FlightType.departure ? 'departure' : 'arrival',
        );
      }

      final data = await query.order('scheduled_arrival', ascending: true);
      var flights = (data as List)
          .map((e) => FlightModel.fromMap(e as Map<String, dynamic>))
          .toList();

      // Client-side search (flight number or airline)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        flights = flights
            .where(
              (f) =>
                  f.flightNumber.toLowerCase().contains(q) ||
                  f.airline.toLowerCase().contains(q) ||
                  f.origin.toLowerCase().contains(q) ||
                  f.destination.toLowerCase().contains(q),
            )
            .toList();
      }

      return flights;
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Imports a list of flights from the API into the DB.
  /// Deletes existing flights with same external_id, then inserts fresh ones.
  Future<void> importFlights(List<FlightModel> flights) async {
    try {
      if (flights.isEmpty) return;

      final externalIds = flights
          .map((f) => f.externalId)
          .whereType<String>()
          .toList();

      debugPrint('IMPORT: Starting import for ${flights.length} flights');
      debugPrint('IMPORT: External IDs to delete: $externalIds');

      // Delete existing flights with same external_id to avoid conflicts
      if (externalIds.isNotEmpty) {
        debugPrint('IMPORT: Deleting existing flights...');
        await supabaseService.client
            .from('flights')
            .delete()
            .inFilter('external_id', externalIds);
        debugPrint('IMPORT: Delete completed');
      }

      // Insert fresh flights
      final maps = flights
          .map((f) => f.toMap()..remove('id')) // let Supabase generate the ID
          .toList();

      debugPrint('IMPORT: Inserting ${maps.length} flights...');
      await supabaseService.client
          .from('flights')
          .insert(maps);
      debugPrint('IMPORT: Insert completed successfully');
    } on PostgrestException catch (e) {
      debugPrint('IMPORT DB ERROR: ${e.message}');
      debugPrint('IMPORT DB DETAILS: ${e.details}');
      throw SupabaseErrorHandler.handle(e);
    } catch (e, st) {
      debugPrint('IMPORT ERROR: $e');
      debugPrint('IMPORT STACK: $st');
      throw AppError.unknown();
    }
  }

  /// Assigns a stand to a flight after conflict check.
  /// Throws [AppError] with [ErrorType.conflict] if the stand is occupied
  /// during the same time window.
  Future<void> assignStand({
    required String flightId,
    required String standId,
    required DateTime scheduledArrival,
    required DateTime? scheduledDeparture,
  }) async {
    try {
      final endTime =
          scheduledDeparture ?? scheduledArrival.add(const Duration(hours: 2));

      final conflicts = await supabaseService.client
          .from('flights')
          .select('id, flight_number')
          .eq('stand_id', standId)
          .neq('id', flightId) // exclude current flight
          .inFilter('status', _occupyingStatuses)
          .or(
            'and(scheduled_arrival.lte.${endTime.toIso8601String()},'
            'scheduled_departure.gte.${scheduledArrival.toIso8601String()})',
          );

      if ((conflicts as List).isNotEmpty) {
        final conflictFlight = conflicts.first;
        throw AppError(
          messageKey: 'stand_conflict_error'.tr(
            namedArgs: {
              'flight': conflictFlight['flight_number']?.toString() ?? '',
            },
          ),
          type: ErrorType.conflict,
          code: ErrorCode.conflict,
        );
      }

      await supabaseService.client
          .from('flights')
          .update({'stand_id': standId})
          .eq('id', flightId);
    } on AppError {
      rethrow;
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Removes stand assignment from a flight.
  Future<void> unassignStand(String flightId) async {
    try {
      await supabaseService.client
          .from('flights')
          .update({'stand_id': null})
          .eq('id', flightId);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Updates the status of a flight manually.
  Future<void> updateStatus(String flightId, FlightStatus status) async {
    try {
      await supabaseService.client
          .from('flights')
          .update({'status': status.toDbString})
          .eq('id', flightId);
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }

  /// Fetches flights that need attention (3-hour warning).
  /// Criteria: arriving within 3 hours, no stand assigned, status = scheduled.
  Future<List<FlightModel>> fetchFlightsNeedingAttention() async {
    try {
      final now = DateTime.now();
      final in3Hours = now.add(const Duration(hours: 3));

      final data = await supabaseService.client
          .from('flights')
          .select('*, stands(*)')
          .eq('status', 'scheduled')
          .isFilter('stand_id', null)
          .gte('scheduled_arrival', now.toIso8601String())
          .lte('scheduled_arrival', in3Hours.toIso8601String())
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

  /// Counts flights needing attention for the dashboard stat card.
  Future<int> countFlightsNeedingAttention() async {
    try {
      final now = DateTime.now();
      final in3Hours = now.add(const Duration(hours: 3));
      final data = await supabaseService.client
          .from('flights')
          .select('id')
          .eq('status', 'scheduled')
          .isFilter('stand_id', null)
          .gte('scheduled_arrival', now.toIso8601String())
          .lte('scheduled_arrival', in3Hours.toIso8601String());
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// Fetches available stands during a specific time window.
  /// Used for the stand assignment picker.
  Future<List<StandModel>> fetchAvailableStands({
    required DateTime arrivalTime,
    required DateTime? departureTime,
    String? excludeFlightId,
  }) async {
    try {
      final endTime =
          departureTime ?? arrivalTime.add(const Duration(hours: 2));

      // Get all active stands
      final standsData = await supabaseService.client
          .from('stands')
          .select()
          .eq('is_active', true)
          .order('code', ascending: true);

      final allStands = (standsData as List)
          .map((e) => StandModel.fromMap(e as Map<String, dynamic>))
          .toList();

      // Get occupied stand IDs during this window
      var conflictQuery = supabaseService.client
          .from('flights')
          .select('stand_id')
          .not('stand_id', 'is', null)
          .inFilter('status', _occupyingStatuses)
          .or(
            'and(scheduled_arrival.lte.${endTime.toIso8601String()},'
            'scheduled_departure.gte.${arrivalTime.toIso8601String()})',
          );

      if (excludeFlightId != null) {
        conflictQuery = conflictQuery.neq('id', excludeFlightId);
      }

      final conflicts = await conflictQuery;
      final occupiedIds = (conflicts as List)
          .map((e) => e['stand_id']?.toString())
          .whereType<String>()
          .toSet();

      return allStands.where((s) => !occupiedIds.contains(s.id)).toList();
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
      throw AppError.unknown();
    }
  }
}
