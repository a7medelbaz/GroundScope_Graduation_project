import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'supervisor_profile_state.dart';

class SupervisorProfileCubit extends Cubit<SupervisorProfileState> {
  SupervisorProfileCubit() : super(const SupervisorProfileInitial());
}