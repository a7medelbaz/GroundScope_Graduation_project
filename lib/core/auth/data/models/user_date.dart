class UserData {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String imageUrl;
  final String position;

  UserData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
    required this.position,
  });

  /// Convert from Supabase JSON → Dart object
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      position: json['position'] as String? ?? '',
    );
  }

  /// Convert Dart object → Map (useful for inserts/updates)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'image_url': imageUrl,
      'position': position,
    };
  }
}
