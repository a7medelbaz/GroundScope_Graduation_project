import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_type.dart';
import 'package:ground_scope/core/shared/data/models/generated_credentials.dart';
import 'package:ground_scope/core/shared/data/repo/user_repo.dart';
import 'package:ground_scope/core/utils/credentials_generator.dart';

part 'user_reset_state.dart';

class UserResetCubit extends Cubit<UserResetState> {
  UserResetCubit(this._repo) : super(const UserResetState());

  final UserRepo _repo;

  Future<void> resetPassword(UserModel user) async {
    emit(state.copyWith(status: UserResetStatus.resetting));
    try {
      if (user.authId == null) {
        throw const AppError(
          messageKey: 'no_auth_account',
          type: ErrorType.validation,
        );
      }

      final newPassword = CredentialsGenerator.generatePassword();
      await _repo.resetPassword(authId: user.authId!, newPassword: newPassword);

      emit(
        state.copyWith(
          status: UserResetStatus.success,
          newCredentials: GeneratedCredentials(
            email: user.email,
            password: newPassword,
            fullName: user.fullName,
            role: user.userRole,
            serviceTypeName: user.serviceTypeName,
            unitName: user.unitName,
          ),
        ),
      );
    } on AppError catch (e) {
      emit(state.copyWith(status: UserResetStatus.failure, error: e));
    } catch (_) {
      emit(
        state.copyWith(
          status: UserResetStatus.failure,
          error: AppError.unknown(),
        ),
      );
    }
  }

  void reset() => emit(const UserResetState());
}
