part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<TaskModel> tasks;
  final UnitModel unit; // Added unit data here

  const HomeLoaded({required this.tasks, required this.unit});

  @override
  List<Object?> get props => [tasks, unit];
}

final class HomeFailure extends HomeState {
  final AppError error;
  const HomeFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
