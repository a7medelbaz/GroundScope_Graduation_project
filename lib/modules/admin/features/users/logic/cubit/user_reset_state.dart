part of 'user_reset_cubit.dart';

enum UserResetStatus { initial, resetting, success, failure }

class UserResetState extends Equatable {
  const UserResetState({
    this.status = UserResetStatus.initial,
    this.newCredentials,
    this.error,
  });

  final UserResetStatus status;
  final GeneratedCredentials? newCredentials;
  final AppError? error;

  UserResetState copyWith({
    UserResetStatus? status,
    GeneratedCredentials? newCredentials,
    AppError? error,
  }) {
    return UserResetState(
      status: status ?? this.status,
      newCredentials: newCredentials ?? this.newCredentials,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, newCredentials, error];
}
