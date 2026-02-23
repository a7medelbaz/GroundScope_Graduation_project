import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_type.dart';
import '../../../utils/secure_storage.dart';

import '../../data/models/user_date.dart';
import '../../data/repo/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.authRepo) : super(AuthInitial());

  final AuthRepo authRepo;

  Future<void> emitLogin({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      // 1️⃣ Login using Supabase
      final response = await authRepo.login(email: email, password: password);

      final userId = response.user?.id;
      if (userId == null) {
        emit(AuthFailure(errorMessage: 'User ID is null after login'));
        return;
      }

      // 2️⃣ Fetch user data from Supabase table
      final userDataMap = await authRepo.getUserDataById(userId);
      // 4️⃣ 🔥 Save userId and role to cache

      if (userDataMap == null) {
        emit(AuthFailure(errorMessage: 'User data not found for this user'));
        return;
      }

      // 3️⃣ Map to UserData model
      final userData = UserData.fromJson(userDataMap);
      // 4️⃣ Emit success state
      emit(AuthSuccess(userData: userData));
      final storage = SecureStorage();
      storage.saveString(key: 'user_id', value: userId);
      storage.saveString(key: 'position', value: userData.position);
    } on AppError catch (e) {
      emit(AuthFailure(errorMessage: e.message, errorType: e.type));
    } catch (_) {
      emit(
        AuthFailure(errorMessage: 'Something went wrong. Please try again.'),
      );
    }
  }
}
