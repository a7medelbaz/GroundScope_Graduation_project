enum UserRole {
  admin,
  supervisor,
  unitManager;

  static UserRole fromString(String value) => switch (value) {
        'admin' => UserRole.admin,
        'supervisor' => UserRole.supervisor,
        'unit_manager' => UserRole.unitManager,
        _ => UserRole.unitManager,
      };

  String get toDbString => switch (this) {
        UserRole.admin => 'admin',
        UserRole.supervisor => 'supervisor',
        UserRole.unitManager => 'unit_manager',
      };

  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.supervisor => 'Supervisor',
        UserRole.unitManager => 'Unit Manager',
      };
}

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
  final String? authId;

  // Joined fields (populated by admin queries with select joins)
  final String? serviceTypeName;
  final String? unitName;

  UserRole get userRole => UserRole.fromString(role);

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
    this.authId,
    this.serviceTypeName,
    this.unitName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
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
        authId: json['auth_id']?.toString(),
      );
    } catch (e, stack) {
      print("CRITICAL: UserModel Parsing Error: $e");
      print("STACKTRACE: $stack");
      rethrow;
    }
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final serviceTypeData = map['service_types'] as Map<String, dynamic>?;
    final unitData = map['units'] as Map<String, dynamic>?;
    return UserModel(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString(),
      role: map['role']?.toString() ?? '',
      serviceTypeId: map['service_type_id']?.toString(),
      unitId: map['unit_id']?.toString(),
      fcmToken: map['fcm_token']?.toString(),
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      authId: map['auth_id']?.toString(),
      serviceTypeName: serviceTypeData?['name']?.toString(),
      unitName: unitData?['name']?.toString(),
    );
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

  Map<String, dynamic> toMap() => {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'service_type_id': serviceTypeId,
        'unit_id': unitId,
        'is_active': isActive,
        'auth_id': authId,
      };
}
