import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/constants/app_constants.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_type.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';

class AirLabsRemoteDs {
  static const String _baseUrl = 'https://airlabs.co/api/v9/schedules';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// Fetches both arrivals and departures for the configured airport.
  /// Filters out duplicates automatically.
  /// Returns a deduplicated list of [FlightModel].
  Future<List<FlightModel>> fetchTodaysFlights() async {
    try {
      final arrivals = await _fetch(arrIata: AppConstants.airportIataCode);
      final departures = await _fetch(depIata: AppConstants.airportIataCode);

      // Deduplicate by external_id + flight type
      final seen = <String>{};
      final combined = <FlightModel>[];

      for (final flight in [...arrivals, ...departures]) {
        final key = '${flight.externalId}_${flight.flightType.name}';
        if (seen.add(key)) {
          combined.add(flight);
        }
      }

      combined.sort((a, b) => a.scheduledArrival.compareTo(b.scheduledArrival));

      return combined;
    } on AppError {
      rethrow;
    } catch (e, st) {
      debugPrint('FETCH ERROR: $e');
      debugPrint('FETCH STACK: $st');
      throw AppError.unknown();
    }
  }

  Future<List<FlightModel>> _fetch({String? arrIata, String? depIata}) async {
    try {
      final params = {'api_key': AppConstants.airLabsApiKey};
      if (arrIata != null) params['arr_iata'] = arrIata;
      if (depIata != null) params['dep_iata'] = depIata;

      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: params,
      );

      debugPrint('API STATUS: ${response.statusCode}');
      debugPrint('API KEYS: ${response.data?.keys}');

      final json = response.data ?? {};

      // Check for API errors
      if (json['error'] != null) {
        debugPrint('API ERROR: ${json['error']}');
        throw AppError.unknown();
      }

      final data = json['response'] as List? ?? [];
      debugPrint('FLIGHTS COUNT: ${data.length}');

      final isArrival = arrIata != null;

      return data
          .cast<Map<String, dynamic>>()
          .where((item) {
            final num = item['flight_iata']?.toString() ?? '';
            return num.isNotEmpty;
          })
          .map((item) => _mapToModel(item, isArrival: isArrival))
          .toList();
    } on DioException catch (e) {
      debugPrint('DIO ERROR: ${e.type} — ${e.message}');
      debugPrint('DIO RESPONSE: ${e.response?.data}');
      if (e.response?.statusCode == 429) {
        throw AppError(
          type: ErrorType.serviceUnavailable,
          messageKey: 'api_rate_limit_exceeded'.tr(),
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw AppError(
          type: ErrorType.connectionError,
          messageKey: 'connection_timeout'.tr(),
        );
      }
      throw AppError(
        type: ErrorType.connectionError,
        messageKey: 'errors.connection_error'.tr(),
      );
    } catch (e, st) {
      debugPrint('PARSE ERROR: $e');
      debugPrint('PARSE STACK: $st');
      throw AppError.unknown();
    }
  }

  FlightModel _mapToModel(
    Map<String, dynamic> item, {
    required bool isArrival,
  }) {
    return FlightModel(
      id: '', // Will be assigned by Supabase on insert
      flightNumber: item['flight_iata']?.toString() ?? '',
      airline: item['airline_iata']?.toString() ?? '', // AirLabs only provides iata/icao codes
      origin: isArrival
          ? item['dep_iata']?.toString() ?? ''
          : item['dep_iata']?.toString() ?? '',
      destination: isArrival
          ? item['arr_iata']?.toString() ?? ''
          : item['arr_iata']?.toString() ?? '',
      aircraftType: item['aircraft_icao']?.toString(),
      aircraftRegistration: null, // Not available in AirLabs schedules
      scheduledArrival: _parseDate(
        isArrival ? item['arr_time'] : item['dep_time'],
      ) ??
          DateTime.now(),
      estimatedArrival: _parseDate(
        isArrival ? item['arr_estimated'] : item['dep_estimated'],
      ),
      actualArrival: _parseDate(
        isArrival ? item['arr_actual'] : item['dep_actual'],
      ),
      scheduledDeparture: _parseDate(
        isArrival ? item['dep_time'] : item['arr_time'],
      ),
      actualDeparture: _parseDate(
        isArrival ? item['dep_actual'] : item['arr_actual'],
      ),
      standId: null,
      status: FlightStatus.fromString(
        _mapApiStatus(item['status']?.toString() ?? ''),
      ),
      paxCount: null,
      apiSource: 'airlabs',
      externalId: item['flight_iata']?.toString(),
      flightType: isArrival ? FlightType.arrival : FlightType.departure,
      depTerminal: item['dep_terminal']?.toString(),
      depGate: item['dep_gate']?.toString(),
      arrTerminal: item['arr_terminal']?.toString(),
      arrGate: item['arr_gate']?.toString(),
      delayMinutes: item['delayed'] is int ? item['delayed'] as int : null,
    );
  }

  String _mapApiStatus(String apiStatus) => switch (apiStatus.toLowerCase()) {
    'scheduled' => 'scheduled',
    'active' => 'landed',
    'landed' => 'landed',
    'cancelled' => 'cancelled',
    'delayed' => 'scheduled', // treat as scheduled, delay minutes will show separately
    'diverted' => 'scheduled',
    _ => 'scheduled',
  };

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
