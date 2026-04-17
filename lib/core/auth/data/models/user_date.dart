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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        // Using toString() handles cases where UUIDs might be treated weirdly
        id: json['id']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        role: json['role']?.toString() ?? 'worker',
        serviceTypeId: json['service_type_id']?.toString(),
        unitId: json['unit_id']?.toString(),
        fcmToken: json['fcm_token']?.toString(),
        isActive: json['is_active'] is bool ? json['is_active'] : true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
      );
    } catch (e, stack) {
      // This will show up in your terminal if the model fails
      print("CRITICAL: UserModel Parsing Error: $e");
      print("STACKTRACE: $stack");
      rethrow;
    }
  }

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
