import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/constants/app_constants.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_type.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';

class AviationStackRemoteDs {
  static const String _baseUrl = 'https://api.aviationstack.com/v1/timetable';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// Fetches both arrivals and departures for the configured airport.
  /// Filters out codeshared duplicates automatically.
  /// Returns a deduplicated list of [FlightModel].
  Future<List<FlightModel>> fetchTodaysFlights() async {
    try {
      final arrivals = await _fetch(type: 'arrival');
      final departures = await _fetch(type: 'departure');

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

  Future<List<FlightModel>> _fetch({required String type}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {
          'access_key': AppConstants.aviationStackKey,
          'iataCode': AppConstants.airportIataCode,
          'type': type,
        },
      );

      debugPrint('API STATUS: ${response.statusCode}');
      debugPrint('API DATA KEYS: ${response.data?.keys}');
      debugPrint('API ERROR: ${response.data?['error']}');

      final json = response.data ?? {};
      final data = json['data'] as List? ?? [];
      debugPrint('FLIGHTS COUNT: ${data.length}');

      return data
          .cast<Map<String, dynamic>>()
          .where((item) => item['codeshared'] == null)
          .where((item) {
            final num = item['flight']?['iataNumber']?.toString() ?? '';
            return num.isNotEmpty;
          })
          .map((item) => _mapToModel(item, type))
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

  FlightModel _mapToModel(Map<String, dynamic> item, String type) {
    final arrival = item['arrival'] as Map<String, dynamic>? ?? {};
    final departure = item['departure'] as Map<String, dynamic>? ?? {};
    final aircraft = item['aircraft'] as Map<String, dynamic>? ?? {};
    final airline = item['airline'] as Map<String, dynamic>? ?? {};
    final flight = item['flight'] as Map<String, dynamic>? ?? {};

    final isArrival = type == 'arrival';

    return FlightModel(
      id: '', // Will be assigned by Supabase on insert
      flightNumber: flight['iataNumber']?.toString() ?? '',
      airline: airline['name']?.toString() ?? '',
      origin: isArrival
          ? departure['iataCode']?.toString() ??
                '' // came FROM here
          : departure['iataCode']?.toString() ?? '', // CAI (departing)
      destination: isArrival
          ? arrival['iataCode']?.toString() ??
                '' // CAI (arriving)
          : arrival['iataCode']?.toString() ?? '', // going TO here
      aircraftType: aircraft['icaoCode']?.toString(),
      aircraftRegistration: aircraft['regNumber']?.toString(),
      scheduledArrival:
          _parseDate(
            isArrival ? arrival['scheduledTime'] : departure['scheduledTime'],
          ) ??
          DateTime.now(),
      estimatedArrival: _parseDate(
        isArrival ? arrival['estimatedTime'] : departure['estimatedTime'],
      ),
      actualArrival: _parseDate(
        isArrival ? arrival['actualTime'] : departure['actualTime'],
      ),
      scheduledDeparture: _parseDate(
        isArrival ? departure['scheduledTime'] : arrival['scheduledTime'],
      ),
      actualDeparture: _parseDate(
        isArrival ? departure['actualTime'] : arrival['actualTime'],
      ),
      standId: null,
      status: FlightStatus.fromString(
        _mapApiStatus(item['status']?.toString() ?? ''),
      ),
      paxCount: null,
      apiSource: 'aviationstack',
      externalId: flight['iataNumber']?.toString(),
      flightType: isArrival ? FlightType.arrival : FlightType.departure,
    );
  }

  String _mapApiStatus(String apiStatus) => switch (apiStatus.toLowerCase()) {
    'scheduled' => 'scheduled',
    'active' => 'landed',
    'cancelled' => 'cancelled',
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
