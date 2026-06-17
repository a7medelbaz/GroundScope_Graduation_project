import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/repo/user_repo.dart';

part 'users_list_state.dart';

class UsersListCubit extends Cubit<UsersListState> {
  UsersListCubit(this._repo) : super(const UsersListState());

  final UserRepo _repo;

  Future<void> load() async {
    emit(state.copyWith(status: UsersListStatus.loading));
    try {
      final users = await _repo.fetchAll();
      emit(state.copyWith(
        status: UsersListStatus.success,
        all: users,
        filtered: _applyFilter(users, state.filter),
      ));
    } on AppError catch (e) {
      emit(state.copyWith(status: UsersListStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
          status: UsersListStatus.failure, error: AppError.unknown()));
    }
  }

  void onFilterChanged(UsersFilter filter) {
    emit(state.copyWith(
      filter: filter,
      filtered: _applyFilter(state.all, filter),
    ));
  }

  Future<void> toggleActive(UserModel user) async {
    try {
      final newActive = !user.isActive;
      await _repo.setActive(user.id, newActive);
      final updated = state.all.map((u) {
        if (u.id == user.id) {
          return UserModel(
            id: u.id,
            fullName: u.fullName,
            email: u.email,
            phone: u.phone,
            role: u.role,
            serviceTypeId: u.serviceTypeId,
            unitId: u.unitId,
            fcmToken: u.fcmToken,
            isActive: newActive,
            createdAt: u.createdAt,
            authId: u.authId,
            serviceTypeName: u.serviceTypeName,
            unitName: u.unitName,
          );
        }
        return u;
      }).toList();

      emit(state.copyWith(
        all: updated,
        filtered: _applyFilter(updated, state.filter),
        toggledUserId: user.id,
      ));
    } catch (_) {
      // silently fail — list stays unchanged
    }
  }

  List<UserModel> _applyFilter(List<UserModel> all, UsersFilter filter) =>
      switch (filter) {
        UsersFilter.all => all,
        UsersFilter.supervisors =>
          all.where((u) => u.userRole == UserRole.supervisor).toList(),
        UsersFilter.unitManagers =>
          all.where((u) => u.userRole == UserRole.unitManager).toList(),
      };
}
