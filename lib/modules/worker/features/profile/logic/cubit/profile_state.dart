part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UnitProfileModel? unit;
  final List<UnitMemberModel> members;
  final AppError? error;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.unit,
    this.members = const [],
    this.error,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UnitProfileModel? unit,
    List<UnitMemberModel>? members,
    AppError? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      unit: unit ?? this.unit,
      members: members ?? this.members,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, unit, members, error];
}
