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
      id: map['id'],
      name: map['name'],
      description: map['description'],
      defaultDurationMinutes: map['default_duration_minutes'],
      icon: map['icon'],
      isActive: map['is_active'],
    );
  }
}
