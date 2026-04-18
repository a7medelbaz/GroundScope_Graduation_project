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
      id: map['id'],
      code: map['code'],
      terminal: map['terminal'],
      compatibleAircraft: (map['compatible_aircraft'] as List?)?.cast<String>(),
      hasCamera: map['has_camera'],
      isActive: map['is_active'],
    );
  }
}
