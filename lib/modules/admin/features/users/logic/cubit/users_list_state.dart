part of 'users_list_cubit.dart';

enum UsersFilter { all, supervisors, unitManagers }

enum UsersListStatus { initial, loading, success, failure }

class UsersListState extends Equatable {
  const UsersListState({
    this.status = UsersListStatus.initial,
    this.all = const [],
    this.filtered = const [],
    this.filter = UsersFilter.all,
    this.error,
    this.toggledUserId,
  });

  final UsersListStatus status;
  final List<UserModel> all;
  final List<UserModel> filtered;
  final UsersFilter filter;
  final AppError? error;
  final String? toggledUserId;

  UsersListState copyWith({
    UsersListStatus? status,
    List<UserModel>? all,
    List<UserModel>? filtered,
    UsersFilter? filter,
    AppError? error,
    String? toggledUserId,
  }) {
    return UsersListState(
      status: status ?? this.status,
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      filter: filter ?? this.filter,
      error: error ?? this.error,
      toggledUserId: toggledUserId,
    );
  }

  @override
  List<Object?> get props =>
      [status, all, filtered, filter, error, toggledUserId];
}
