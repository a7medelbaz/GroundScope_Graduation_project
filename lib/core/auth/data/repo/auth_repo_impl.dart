import 'dart:convert';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/config/app_constants.dart';
import 'package:ground_scope/core/service/secure_storage.dart';
import '../remote/auth_remote_ds.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDs authRemoteDs;
  final SecureStorage secureStorage;

  AuthRepoImpl({required this.authRemoteDs, required this.secureStorage});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final userModel = await authRemoteDs.loginUser(
      email: email,
      password: password,
    );

    await _cacheUser(userModel);

    return userModel;
  }

  @override
  Future<UserModel?> getLoggedInUser() async {
    final rawJson = await secureStorage.read(key: AppConstants.userDataKey);
    if (rawJson == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(rawJson));
    } catch (_) {
      await logout();
      return null;
    }
  }

  @override
  Future<UserModel> fetchAndCacheUserData({required String email}) async {
    final userModel = await authRemoteDs.fetchFreshUserData(email);
    await _cacheUser(userModel);
    return userModel;
  }

  @override
  Future<void> logout() async {
    await authRemoteDs.signOut();
    await secureStorage.delete(key: AppConstants.userDataKey);
  }

  // Helper method to keep code DRY (Don't Repeat Yourself)
  Future<void> _cacheUser(UserModel user) async {
    await secureStorage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
  }
}
