part of 'supervisor_profile_cubit.dart';

sealed class SupervisorProfileState extends Equatable {
  const SupervisorProfileState();

  @override
  List<Object?> get props => [];
}

final class SupervisorProfileInitial extends SupervisorProfileState {
  const SupervisorProfileInitial();
}