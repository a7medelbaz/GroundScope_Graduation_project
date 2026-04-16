import 'package:equatable/equatable.dart';

class UnitModel extends Equatable {
  final String id;
  final String name;
  final String serviceTypeId;
  final String status;
  final List<String> compatibleAircraft;
  final DateTime? createdAt;
  final String? shiftStartTime;
  final String? shiftEndTime;

  const UnitModel({
    required this.id,
    required this.name,
    required this.serviceTypeId,
    required this.status,
    this.compatibleAircraft = const [],
    this.createdAt,
    this.shiftStartTime,
    this.shiftEndTime,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      // SQL: id uuid (String)
      id: json['id'] as String? ?? '',

      // SQL: name text (String)
      name: json['name'] as String? ?? 'Unknown Unit',

      // SQL: service_type_id uuid (String)
      serviceTypeId: json['service_type_id'] as String? ?? '',

      // SQL: status unit_status (String)
      status: json['status'] as String? ?? 'offline',

      // SQL: compatible_aircraft text[] (List<String>)
      // We use .toString() to ensure no type errors if the DB returns unexpected types
      compatibleAircraft:
          (json['compatible_aircraft'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],

      // SQL: created_at timestamptz (ISO String)
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,

      // SQL: shift_start_time time (String like "08:00:00")
      shiftStartTime: json['shift_start_time']?.toString(),

      // SQL: shift_end_time time (String like "17:00:00")
      shiftEndTime: json['shift_end_time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service_type_id': serviceTypeId,
      'status': status,
      'compatible_aircraft': compatibleAircraft,
      'created_at': createdAt?.toIso8601String(),
      'shift_start_time': shiftStartTime,
      'shift_end_time': shiftEndTime,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    serviceTypeId,
    status,
    compatibleAircraft,
    createdAt,
    shiftStartTime,
    shiftEndTime,
  ];
}
