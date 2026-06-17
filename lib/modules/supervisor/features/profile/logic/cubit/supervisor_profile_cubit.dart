import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/user_service.dart';

part 'supervisor_profile_state.dart';

class SupervisorProfileCubit extends Cubit<SupervisorProfileState> {
  SupervisorProfileCubit({required UserService userService})
      : _userService = userService,
        super(const SupervisorProfileState());

  final UserService _userService;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: SupervisorProfileStatus.loading));
    try {
      final user = await _userService.getUser();
      if (user == null) throw AppError.unauthorized();
      emit(state.copyWith(
        status: SupervisorProfileStatus.loaded,
        user: user,
      ));
    } on AppError catch (e) {
      emit(state.copyWith(status: SupervisorProfileStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
        status: SupervisorProfileStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }
}
