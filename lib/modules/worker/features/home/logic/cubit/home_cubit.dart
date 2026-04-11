import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/data/models/task_model.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/modules/worker/features/home/data/repo/home_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo homeRepo;

  HomeCubit({required this.homeRepo}) : super(HomeInitial());

  Future<void> fetchWorkerTasks() async {
    emit(HomeLoading());
    try {
      final tasks = await homeRepo.fetchWorkerTasks();
      emit(HomeLoaded(tasks: tasks));
    } catch (error) {
      emit(HomeFailure(error: error is AppError ? error : AppError.unknown()));
    }
  }
}
