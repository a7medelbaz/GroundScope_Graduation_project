import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepo {
  Future<AuthResponse> login({required String email, required String password});
  Future<UserData> fetchAndCacheUserData();
  Future<UserData?> getLoggedInUser();
  Future<void> logout();
}
