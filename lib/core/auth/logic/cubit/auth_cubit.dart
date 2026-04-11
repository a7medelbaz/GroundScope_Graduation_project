import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_date.dart';
import '../../../error/models/app_error.dart';
import '../../data/repo/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit(this.authRepo) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthChecking());
    try {
      final cachedUser = await authRepo.getLoggedInUser();
      if (cachedUser == null) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthSuccess(userModel: cachedUser));
      }
    } catch (e) {
      emit(AuthFailure(error: e is AppError ? e : AppError.unknown()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthChecking());
    try {
      final userModel = await authRepo.login(email: email, password: password);
      if (!userModel.isActive) {
        emit(AuthFailure(error: AppError.unauthorized()));
        return;
      }

      emit(AuthSuccess(userModel: userModel));
    } catch (error) {
      emit(AuthFailure(error: error is AppError ? error : AppError.unknown()));
    }
  }

  Future<void> logout() async {
    try {
      await authRepo.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
