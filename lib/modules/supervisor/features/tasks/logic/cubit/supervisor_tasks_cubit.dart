import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'supervisor_tasks_state.dart';

class SupervisorTasksCubit extends Cubit<SupervisorTasksState> {
  SupervisorTasksCubit() : super(const SupervisorTasksInitial());
}