import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';

class AuthRemoteDs {
  final SupabaseService supabaseService;

  AuthRemoteDs({required this.supabaseService});
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    // 1. Authenticate with Supabase Auth
    final authResponse = await supabaseService.client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    if (authResponse.user == null) {
      throw AppError.unauthorized();
    }

    // 2. Fetch profile from 'users' table
    final userDataMap = await supabaseService.client
        .from('users')
        .select()
        .eq('email', email.trim())
        .maybeSingle();

    if (userDataMap == null) {
      throw AppError.unauthorized();
    }

    return UserModel.fromJson(userDataMap);
  }

  Future<UserModel> fetchFreshUserData(String email) async {
    final userDataMap = await supabaseService.client
        .from('users')
        .select()
        .eq('email', email.trim())
        .maybeSingle();

    if (userDataMap == null) {
      throw AppError.unauthorized();
    }

    return UserModel.fromJson(userDataMap);
  }

  Future<void> signOut() async {
    await supabaseService.client.auth.signOut();
  }
}
