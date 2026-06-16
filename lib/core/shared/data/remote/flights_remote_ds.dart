import 'package:easy_localization/easy_localization.dart';
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
  /// Uses upsert on external_id to avoid duplicates on re-fetch.
  Future<void> importFlights(List<FlightModel> flights) async {
    try {
      if (flights.isEmpty) return;

      final maps = flights
          .map((f) => f.toMap()..remove('id')) // let Supabase generate the ID
          .toList();

      await supabaseService.client
          .from('flights')
          .upsert(maps, onConflict: 'external_id');
    } on PostgrestException catch (e) {
      throw SupabaseErrorHandler.handle(e);
    } catch (_) {
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
