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
    final authResponse = await supabaseService.client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    if (authResponse.user == null) {
      throw AppError.unauthorized();
    }

    final userDataMap = await supabaseService.client
        .from('users')
        .select()
        .eq('auth_id', authResponse.user!.id)
        .maybeSingle();

    if (userDataMap == null) {
      throw AppError.unauthorized("Profile not found.");
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
