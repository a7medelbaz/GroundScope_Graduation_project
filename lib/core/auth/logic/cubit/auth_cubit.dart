import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';

import '../../../error/models/app_error.dart';
import '../../data/repo/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit(this.authRepo) : super(AuthInitial());

  /// Check if user is already logged in from cache
  Future<void> checkAuthStatus() async {
    emit(AuthChecking());
    try {
      final cachedUser = await authRepo.getLoggedInUser();
      if (cachedUser == null) {
        emit(AuthUnauthenticated());
        return;
      }
      emit(AuthSuccess(userModel: cachedUser));
    } catch (e) {
      emit(AuthFailure(error: e is AppError ? e : AppError.unknown()));
    }
  }

  /// Perform login and emit success/failure
  Future<void> login({required String email, required String password}) async {
    emit(AuthChecking());
    try {
      final userModel = await authRepo.login(email: email, password: password);
      if (!userModel.isActive) {
        throw AppError.unauthorized();
      }
      emit(AuthSuccess(userModel: userModel));
    } catch (error) {
      emit(AuthFailure(error: error is AppError ? error : AppError.unknown()));
    }
  }

  /// Logout and clear state
  Future<void> logout() async {
    try {
      await authRepo.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e is AppError ? e : AppError.unknown()));
    }
  }
}
