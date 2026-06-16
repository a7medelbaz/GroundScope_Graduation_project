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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'default_duration_minutes': defaultDurationMinutes,
      'icon': icon,
      'is_active': isActive,
    };
  }

  ServiceTypeModel copyWith({
    String? id,
    String? name,
    String? description,
    int? defaultDurationMinutes,
    String? icon,
    bool? isActive,
  }) {
    return ServiceTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}
