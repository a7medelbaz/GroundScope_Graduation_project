import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_date.dart';

abstract class AuthRepo {
  Future<AuthResponse> login({required String email, required String password});
  Future<UserModel> fetchAndCacheUserData();
  Future<UserModel?> getLoggedInUser();
  Future<void> logout();
}
