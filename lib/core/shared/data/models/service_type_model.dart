class ServiceTypeModel {
  final String id;
  final String name;
  final String? description;
  final int defaultDurationMinutes;
  final String? icon;
  final bool isActive;

  const ServiceTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.defaultDurationMinutes,
    this.icon,
    required this.isActive,
  });

  factory ServiceTypeModel.fromMap(Map<String, dynamic> map) {
    return ServiceTypeModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      defaultDurationMinutes: (map['default_duration_minutes'] as int?) ?? 0,
      icon: map['icon']?.toString(),
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
