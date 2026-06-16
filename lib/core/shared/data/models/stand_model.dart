class StandModel {
  final String id;
  final String code;
  final String terminal;
  final List<String> compatibleAircraft;
  final bool hasCamera;
  final bool isActive;
  final DateTime createdAt;

  const StandModel({
    required this.id,
    required this.code,
    required this.terminal,
    required this.compatibleAircraft,
    required this.hasCamera,
    required this.isActive,
    required this.createdAt,
  });

  factory StandModel.fromMap(Map<String, dynamic> map) {
    return StandModel(
      id: map['id']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      terminal: map['terminal']?.toString() ?? '',
      compatibleAircraft: map['compatible_aircraft'] != null
          ? List<String>.from(map['compatible_aircraft'] as List)
          : [],
      hasCamera: map['has_camera'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'code': code,
        'terminal': terminal,
        'compatible_aircraft': compatibleAircraft,
        'has_camera': hasCamera,
        'is_active': isActive,
      };

  /// Returns true if this stand is compatible with the given aircraft type.
  /// Returns true if compatibleAircraft is empty (no restriction).
  bool isCompatibleWith(String? aircraftType) {
    if (compatibleAircraft.isEmpty) return true;
    if (aircraftType == null || aircraftType.isEmpty) return true;

    final normalizedType = aircraftType.toUpperCase().trim();

    return compatibleAircraft.any(
      (type) => type.toUpperCase().trim() == normalizedType,
    );
  }

  StandModel copyWith({
    String? id,
    String? code,
    String? terminal,
    List<String>? compatibleAircraft,
    bool? hasCamera,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return StandModel(
      id: id ?? this.id,
      code: code ?? this.code,
      terminal: terminal ?? this.terminal,
      compatibleAircraft: compatibleAircraft ?? this.compatibleAircraft,
      hasCamera: hasCamera ?? this.hasCamera,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
