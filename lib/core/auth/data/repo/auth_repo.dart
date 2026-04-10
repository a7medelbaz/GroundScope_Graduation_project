import '../models/user_date.dart';

abstract class AuthRepo {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> fetchAndCacheUserData({required String email});
  Future<UserModel?> getLoggedInUser();
  Future<void> logout();
}
