import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'supervisor_nav_state.dart';

class SupervisorNavCubit extends Cubit<SupervisorNavState> {
  SupervisorNavCubit() : super(const SupervisorNavState(currentIndex: 0));

  void changeTab(int index) => emit(SupervisorNavState(currentIndex: index));
}