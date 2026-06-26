part of 'supervisor_profile_cubit.dart';

enum SupervisorProfileStatus { initial, loading, loaded, failure }

final class SupervisorProfileState extends Equatable {
  const SupervisorProfileState({
    this.status = SupervisorProfileStatus.initial,
    this.user,
    this.serviceTypeName,
    this.unitCount = 0,
    this.memberCount = 0,
    this.error,
  });

  final SupervisorProfileStatus status;
  final UserModel? user;
  final String? serviceTypeName;
  final int unitCount;
  final int memberCount;
  final AppError? error;

  SupervisorProfileState copyWith({
    SupervisorProfileStatus? status,
    UserModel? user,
    String? serviceTypeName,
    int? unitCount,
    int? memberCount,
    AppError? error,
  }) {
    return SupervisorProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      serviceTypeName: serviceTypeName ?? this.serviceTypeName,
      unitCount: unitCount ?? this.unitCount,
      memberCount: memberCount ?? this.memberCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, user, serviceTypeName, unitCount, memberCount, error];
}
