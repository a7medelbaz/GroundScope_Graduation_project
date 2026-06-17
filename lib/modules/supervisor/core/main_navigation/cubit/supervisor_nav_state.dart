part of 'supervisor_nav_cubit.dart';

final class SupervisorNavState extends Equatable {
  const SupervisorNavState({required this.currentIndex});

  final int currentIndex;

  @override
  List<Object> get props => [currentIndex];
}