import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../notifications/service/notification_service.dart';
import '../../../service/secure_storage.dart';
import '../../../utils/app_constants.dart';
import '../models/user_date.dart';
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

    // Save FCM token — non-blocking
    try {
      final token = await NotificationService.instance.getToken();
      if (token != null) {
        await authRemoteDs.supabaseService.client
            .from('users')
            .update({'fcm_token': token}).eq('id', userModel.id);
      }
    } catch (e) {
      debugPrint('FCM token save failed: $e');
    }

    // Keep token fresh on device rotation
    NotificationService.instance.onTokenRefresh((newToken) async {
      try {
        await authRemoteDs.supabaseService.client
            .from('users')
            .update({'fcm_token': newToken}).eq('id', userModel.id);
      } catch (_) {}
    });

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
    // Clear FCM token before signing out — non-blocking
    try {
      final authUser =
          authRemoteDs.supabaseService.client.auth.currentUser;
      if (authUser != null) {
        await authRemoteDs.supabaseService.client
            .from('users')
            .update({'fcm_token': null}).eq('auth_id', authUser.id);
      }
    } catch (_) {}

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
