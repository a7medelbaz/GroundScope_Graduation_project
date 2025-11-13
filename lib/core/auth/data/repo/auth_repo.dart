import 'package:flutter/material.dart';
import 'package:ground_scope/core/auth/data/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepo {
  final AuthService _authService = AuthService();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.loginUser(
        email: email,
        password: password,
      );
    } catch (e, stackTrace) {
      debugPrint('Login error: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    try {
      return await _authService.fetchUserProfileById(userId);
    } catch (e, stackTrace) {
      debugPrint('Fetch user data error: $e\n$stackTrace');
      return null;
    }
  }
}
