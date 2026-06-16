import 'stand_model.dart';

enum FlightStatus {
  scheduled,
  landed,
  inService,
  ready,
  departed,
  cancelled;

  static FlightStatus fromString(String value) => switch (value) {
    'scheduled' => FlightStatus.scheduled,
    'landed' => FlightStatus.landed,
    'in_service' => FlightStatus.inService,
    'ready' => FlightStatus.ready,
    'departed' => FlightStatus.departed,
    'cancelled' => FlightStatus.cancelled,
    _ => FlightStatus.scheduled,
  };

  String get toDbString => switch (this) {
    FlightStatus.scheduled => 'scheduled',
    FlightStatus.landed => 'landed',
    FlightStatus.inService => 'in_service',
    FlightStatus.ready => 'ready',
    FlightStatus.departed => 'departed',
    FlightStatus.cancelled => 'cancelled',
  };

  String get label => switch (this) {
    FlightStatus.scheduled => 'Scheduled',
    FlightStatus.landed => 'Landed',
    FlightStatus.inService => 'In Service',
    FlightStatus.ready => 'Ready',
    FlightStatus.departed => 'Departed',
    FlightStatus.cancelled => 'Cancelled',
  };
}

enum FlightType {
  arrival,
  departure;

  static FlightType fromString(String? value) =>
      value == 'departure' ? FlightType.departure : FlightType.arrival;
}

class FlightModel {
  final String id;
  final String flightNumber;
  final String airline;
  final String origin;
  final String destination;
  final String? aircraftType;
  final String? aircraftRegistration;
  final DateTime scheduledArrival;
  final DateTime? estimatedArrival;
  final DateTime? actualArrival;
  final DateTime? scheduledDeparture;
  final DateTime? actualDeparture;
  final String? standId;
  final FlightStatus status;
  final int? paxCount;
  final String apiSource;
  final String? externalId;
  final FlightType flightType;
  final StandModel? stand;

  const FlightModel({
    required this.id,
    required this.flightNumber,
    required this.airline,
    required this.origin,
    required this.destination,
    this.aircraftType,
    this.aircraftRegistration,
    required this.scheduledArrival,
    this.estimatedArrival,
    this.actualArrival,
    this.scheduledDeparture,
    this.actualDeparture,
    this.standId,
    required this.status,
    this.paxCount,
    required this.apiSource,
    this.externalId,
    this.flightType = FlightType.arrival,
    this.stand,
  });

  factory FlightModel.fromMap(Map<String, dynamic> map) {
    return FlightModel(
      id: map['id']?.toString() ?? '',
      flightNumber: map['flight_number']?.toString() ?? '',
      airline: map['airline']?.toString() ?? '',
      origin: map['origin']?.toString() ?? '',
      destination: map['destination']?.toString() ?? '',
      aircraftType: map['aircraft_type'],
      aircraftRegistration: map['aircraft_registration'],
      scheduledArrival: map['scheduled_arrival'] != null
          ? DateTime.parse(map['scheduled_arrival'])
          : DateTime.now(),
      estimatedArrival: map['estimated_arrival'] != null
          ? DateTime.parse(map['estimated_arrival'])
          : null,
      actualArrival: map['actual_arrival'] != null
          ? DateTime.parse(map['actual_arrival'])
          : null,
      scheduledDeparture: map['scheduled_departure'] != null
          ? DateTime.parse(map['scheduled_departure'])
          : null,
      actualDeparture: map['actual_departure'] != null
          ? DateTime.parse(map['actual_departure'])
          : null,
      standId: map['stand_id'],
      status: FlightStatus.fromString(map['status']?.toString() ?? 'scheduled'),
      paxCount: map['pax_count'] as int?,
      apiSource: map['api_source']?.toString() ?? 'manual',
      externalId: map['external_id'],
      flightType: FlightType.fromString(map['flight_type']?.toString()),
      // Supabase returns the joined table as a nested Map
      stand: map['stands'] != null ? StandModel.fromMap(map['stands']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flight_number': flightNumber,
      'airline': airline,
      'origin': origin,
      'destination': destination,
      'aircraft_type': aircraftType,
      'aircraft_registration': aircraftRegistration,
      'scheduled_arrival': scheduledArrival.toIso8601String(),
      'status': status.toDbString,
      'stand_id': standId,
      'api_source': apiSource,
      'external_id': externalId,
      'pax_count': paxCount,
      'estimated_arrival': estimatedArrival?.toIso8601String(),
      'actual_arrival': actualArrival?.toIso8601String(),
      'scheduled_departure': scheduledDeparture?.toIso8601String(),
      'actual_departure': actualDeparture?.toIso8601String(),
      'flight_type': flightType == FlightType.departure
          ? 'departure'
          : 'arrival',
    };
  }
}
