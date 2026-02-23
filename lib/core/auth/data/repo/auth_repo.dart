import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../service/auth_service.dart';

class AuthRepo {
  final AuthService _authService;

  AuthRepo({required AuthService authService}) : _authService = authService;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.loginUser(email: email, password: password);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError.unknown('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    try {
      return await _authService.fetchUserProfileById(userId);
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError.unknown('Something went wrong. Please try again.');
    }
  }
}
