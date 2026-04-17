part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UnitModel? unit;
  final List<TaskModel> tasks;

  const HomeLoaded({this.unit, required this.tasks});

  HomeLoaded copyWith({UnitModel? unit, List<TaskModel>? tasks}) {
    return HomeLoaded(unit: unit ?? this.unit, tasks: tasks ?? this.tasks);
  }
}

final class HomeFailure extends HomeState {
  final AppError error;
  const HomeFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
