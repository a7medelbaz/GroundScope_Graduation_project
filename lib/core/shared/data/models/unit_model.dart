import 'package:equatable/equatable.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';

class UnitModel extends Equatable {
  final String id;
  final String name;
  final String serviceTypeId;
  final String status;
  final List<String> compatibleAircraft;
  final DateTime? createdAt;
  final String? shiftStartTime;
  final String? shiftEndTime;
  final String? serviceTypeName;

  const UnitModel({
    required this.id,
    required this.name,
    required this.serviceTypeId,
    required this.status,
    this.compatibleAircraft = const [],
    this.createdAt,
    this.shiftStartTime,
    this.shiftEndTime,
    this.serviceTypeName,
  });

  UnitStatus get unitStatus => UnitStatus.fromString(status);

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Unit',
      serviceTypeId: json['service_type_id'] as String? ?? '',
      status: json['status'] as String? ?? 'offline',
      compatibleAircraft:
          (json['compatible_aircraft'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      shiftStartTime: json['shift_start_time']?.toString(),
      shiftEndTime: json['shift_end_time']?.toString(),
    );
  }

  factory UnitModel.fromMap(Map<String, dynamic> map) {
    final serviceTypeData = map['service_types'] as Map<String, dynamic>?;

    String? parseTime(dynamic value) {
      if (value == null) return null;
      final str = value.toString();
      if (str.length >= 5) return str.substring(0, 5);
      return str;
    }

    return UnitModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Unit',
      serviceTypeId: map['service_type_id']?.toString() ?? '',
      status: map['status']?.toString() ?? 'offline',
      compatibleAircraft:
          (map['compatible_aircraft'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      shiftStartTime: parseTime(map['shift_start_time']),
      shiftEndTime: parseTime(map['shift_end_time']),
      serviceTypeName: serviceTypeData?['name']?.toString(),
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

  Map<String, dynamic> toMap() => {
    'name': name,
    'service_type_id': serviceTypeId,
    'status': status,
    'compatible_aircraft': compatibleAircraft,
    'shift_start_time': shiftStartTime,
    'shift_end_time': shiftEndTime,
  };

  UnitModel copyWith({
    String? id,
    String? name,
    String? serviceTypeId,
    String? status,
    List<String>? compatibleAircraft,
    DateTime? createdAt,
    String? shiftStartTime,
    String? shiftEndTime,
    String? serviceTypeName,
  }) {
    return UnitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      status: status ?? this.status,
      compatibleAircraft: compatibleAircraft ?? this.compatibleAircraft,
      createdAt: createdAt ?? this.createdAt,
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
      shiftEndTime: shiftEndTime ?? this.shiftEndTime,
      serviceTypeName: serviceTypeName ?? this.serviceTypeName,
    );
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
    serviceTypeName,
  ];
}
