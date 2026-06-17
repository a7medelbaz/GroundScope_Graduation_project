import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'supervisor_units_state.dart';

class SupervisorUnitsCubit extends Cubit<SupervisorUnitsState> {
  SupervisorUnitsCubit() : super(const SupervisorUnitsInitial());
}