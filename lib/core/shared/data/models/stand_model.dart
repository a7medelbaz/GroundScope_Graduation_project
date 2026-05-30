class StandModel {
  final String id;
  final String code;
  final String terminal;
  final List<String>? compatibleAircraft;

  final bool hasCamera;
  final bool isActive;

  const StandModel({
    required this.id,
    required this.code,
    required this.terminal,
    this.compatibleAircraft,
    required this.hasCamera,
    required this.isActive,
  });

  factory StandModel.fromMap(Map<String, dynamic> map) {
    return StandModel(
      id: map['id']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      terminal: map['terminal']?.toString() ?? '',
      compatibleAircraft: (map['compatible_aircraft'] as List?)?.cast<String>(),
      hasCamera: map['has_camera'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
