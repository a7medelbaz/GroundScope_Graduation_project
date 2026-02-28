part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthChecking extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthSuccess extends AuthState {
  final UserData userData;
  AuthSuccess({required this.userData});
}

class AuthFailure extends AuthState {
  final AppError error;
  AuthFailure({required this.error});
}
