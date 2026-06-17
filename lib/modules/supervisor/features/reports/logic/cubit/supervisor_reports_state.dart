part of 'supervisor_reports_cubit.dart';

sealed class SupervisorReportsState extends Equatable {
  const SupervisorReportsState();

  @override
  List<Object?> get props => [];
}

final class SupervisorReportsInitial extends SupervisorReportsState {
  const SupervisorReportsInitial();
}