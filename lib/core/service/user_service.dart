import 'dart:convert';

import '../auth/data/models/user_date.dart';
import 'secure_storage.dart';
import '../utils/app_constants.dart';

class UserService {
  const UserService({required this.secureStorage});

  final SecureStorage secureStorage;
  Future<UserModel?> getUser() async {
    final jsonString = await secureStorage.read(key: AppConstants.userDataKey);
    if (jsonString == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return null;
    }
  }
}
