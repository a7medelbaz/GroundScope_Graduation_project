import 'package:equatable/equatable.dart';

class UnitMemberModel extends Equatable {
  final String id;
  final String unitId;
  final String fullName;
  final String? phone;
  final String? nationalId;
  final String position;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  const UnitMemberModel({
    required this.id,
    required this.unitId,
    required this.fullName,
    this.phone,
    this.nationalId,
    required this.position,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory UnitMemberModel.fromMap(Map<String, dynamic> map) {
    return UnitMemberModel(
      id: map['id'] as String? ?? '',
      unitId: map['unit_id'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone']?.toString(),
      nationalId: map['national_id']?.toString(),
      position: map['position'] as String? ?? '',
      imageUrl: map['image_url']?.toString(),
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        unitId,
        fullName,
        phone,
        nationalId,
        position,
        imageUrl,
        isActive,
        createdAt,
      ];
}
