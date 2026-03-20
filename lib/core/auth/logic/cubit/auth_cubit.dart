import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../error/models/app_error.dart';
import '../../data/models/user_date.dart';
import '../../data/repo/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.authRepo) : super(AuthInitial());

  final AuthRepo authRepo;

  Future<void> checkAuthStatus() async {
    emit(AuthChecking());
    try {
      final userData = await authRepo.getLoggedInUser();
      if (userData == null) {
        emit(AuthUnauthenticated());
        return;
      }
      emit(AuthSuccess(userModel: userData));
    } catch (error) {
      emit(AuthFailure(error: error is AppError ? error : AppError.unknown()));
    }
  }

  Future<void> emitLogin({
    required String email,
    required String password,
  }) async {
    emit(AuthChecking());
    try {
      await authRepo.login(email: email, password: password);
      final userData = await authRepo.fetchAndCacheUserData();
      emit(AuthSuccess(userModel: userData));
    } catch (error) {
      emit(AuthFailure(error: error is AppError ? error : AppError.unknown()));
    }
  }

  Future<void> logout() async {
    await authRepo.logout();
    emit(AuthUnauthenticated());
  }
}
