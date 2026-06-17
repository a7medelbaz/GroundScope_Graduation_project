import 'package:equatable/equatable.dart';

enum UnitStatus {
  available('available'),
  busy('busy'),
  offline('offline'),
  maintenance('maintenance');

  final String value;
  const UnitStatus(this.value);

  static UnitStatus fromString(String value) {
    return UnitStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UnitStatus.offline,
    );
  }

  String get label => switch (this) {
    UnitStatus.available => 'unit_status_available',
    UnitStatus.busy => 'unit_status_busy',
    UnitStatus.offline => 'unit_status_offline',
    UnitStatus.maintenance => 'unit_status_maintenance',
  };
}

class UnitProfileModel extends Equatable {
  final String id;
  final String name;
  final String serviceTypeName;
  final UnitStatus status;
  final String? shiftStartTime;
  final String? shiftEndTime;
  final List<String> compatibleAircraft;

  const UnitProfileModel({
    required this.id,
    required this.name,
    required this.serviceTypeName,
    required this.status,
    this.shiftStartTime,
    this.shiftEndTime,
    this.compatibleAircraft = const [],
  });

  factory UnitProfileModel.fromMap(Map<String, dynamic> map) {
    final serviceType = map['service_types'] as Map<String, dynamic>?;
    return UnitProfileModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      serviceTypeName: serviceType?['name'] as String? ?? '',
      status: UnitStatus.fromString(map['status'] as String? ?? 'offline'),
      shiftStartTime: map['shift_start_time']?.toString(),
      shiftEndTime: map['shift_end_time']?.toString(),
      compatibleAircraft:
          (map['compatible_aircraft'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        serviceTypeName,
        status,
        shiftStartTime,
        shiftEndTime,
        compatibleAircraft,
      ];
}
