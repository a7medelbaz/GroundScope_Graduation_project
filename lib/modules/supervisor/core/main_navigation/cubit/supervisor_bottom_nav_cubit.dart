import 'package:flutter_bloc/flutter_bloc.dart';

class SupervisorBottomNavCubit extends Cubit<int> {
  SupervisorBottomNavCubit() : super(0);

  void jumpTo(int index) => emit(index);
}
