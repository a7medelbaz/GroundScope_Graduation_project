import 'package:ground_scope/core/auth/data/models/user_date.dart';

class GeneratedCredentials {
  const GeneratedCredentials({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.serviceTypeName,
    this.unitName,
  });

  final String email;
  final String password;
  final String fullName;
  final UserRole role;
  final String? serviceTypeName;
  final String? unitName;

  String get contextName => serviceTypeName ?? unitName ?? fullName;

  String get shareMessage =>
      'Your GroundScope account has been created.\n\n'
      'Email: $email\n'
      'Password: $password\n\n'
      'Please login and change your password.';
}
