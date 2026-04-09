class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final String? serviceTypeId;
  final String? unitId;
  final String? fcmToken;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.serviceTypeId,
    this.unitId,
    this.fcmToken,
    required this.isActive,
    required this.createdAt,
  });

// Better version (recommended)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String, // or json['role']?.toString() ?? ''
      serviceTypeId: json['service_type_id'] as String?,
      unitId: json['unit_id'] as String?,
      fcmToken: json['fcm_token'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Dart object → Map (for insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'service_type_id': serviceTypeId,
      'unit_id': unitId,
      'fcm_token': fcmToken,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
