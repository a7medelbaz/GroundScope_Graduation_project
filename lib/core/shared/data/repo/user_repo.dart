import 'package:ground_scope/core/auth/data/models/user_date.dart';

abstract class UserRepo {
  Future<UserModel> createAccount({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? serviceTypeId,
    String? unitId,
  });

  Future<void> resetPassword({
    required String authId,
    required String newPassword,
  });

  Future<List<UserModel>> fetchAll({UserRole? roleFilter});

  Future<void> setActive(String userId, bool isActive);
}
