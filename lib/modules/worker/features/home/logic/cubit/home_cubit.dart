import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/error/models/app_error.dart';
import '../../../../../../core/service/user_service.dart';
import '../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../core/shared/data/models/unit_model.dart';
import '../../../../../../core/shared/data/repo/unit_repo.dart';

import '../../data/repo/home_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.homeRepo,
    required this.unitRepo,
    required this.userService,
  }) : super(HomeInitial());

  final HomeRepo homeRepo;
  final UnitRepo unitRepo;
  final UserService userService;
  Future<void> init() async {
    emit(HomeLoading());
    try {
      final user = await userService.getUser();

      if (user == null || user.unitId == null) {
        emit(HomeFailure(error: AppError.unauthorized('No unit assigned.')));
        return;
      }

      final results = await Future.wait([
        homeRepo.fetchWorkerTasks(unitId: user.unitId!),
        unitRepo.getUnitData(unitId: user.unitId!),
      ]);

      emit(
        HomeLoaded(
          tasks: results[0] as List<TaskModel>,
          unit: results[1] as UnitModel,
        ),
      );
    } on AppError catch (e) {
      emit(HomeFailure(error: e));
    } catch (e) {
      emit(HomeFailure(error: e is AppError ? e : AppError.unknown()));
    }
  }

  Future<void> fetchUnitData() async {
    final currentTasks = state is HomeLoaded
        ? (state as HomeLoaded).tasks
        : <TaskModel>[];
    if (state is! HomeLoaded) emit(HomeLoading());

    try {
      final user = await userService.getUser();

      if (user == null) {
        emit(HomeFailure(error: AppError.unauthorized('Please log in again.')));
        return;
      }
      final unit = await unitRepo.getUnitData(unitId: user.unitId!);

      emit(HomeLoaded(unit: unit, tasks: currentTasks));
    } on AppError catch (e) {
      emit(HomeFailure(error: e));
    } catch (e) {
      emit(HomeFailure(error: AppError.unknown()));
    }
  }

  Future<void> fetchTasks() async {
    final currentUnit = state is HomeLoaded ? (state as HomeLoaded).unit : null;
    try {
      final user = await userService.getUser();
      if (user == null) {
        emit(HomeFailure(error: AppError.unauthorized('Please log in again.')));
        return;
      }
      if (user.unitId == null) {
        emit(
          HomeFailure(
            error: AppError.unauthorized('No unit assigned to user.'),
          ),
        );
        return;
      }

      final tasks = await homeRepo.fetchWorkerTasks(unitId: user.unitId!);
      emit(HomeLoaded(unit: currentUnit, tasks: tasks));
    } on AppError catch (e) {
      emit(HomeFailure(error: e));
    } catch (e) {
      emit(HomeFailure(error: e is AppError ? e : AppError.unknown()));
    }
  }

  Future<void> refreshTasks() async {
    final current = state;
    if (current is! HomeLoaded) return;

    try {
      final user = await userService.getUser();
      if (user?.unitId == null) return;

      final tasks = await homeRepo.fetchWorkerTasks(unitId: user!.unitId!);
      emit(current.copyWith(tasks: tasks));
    } on AppError catch (e) {
      emit(HomeFailure(error: e));
    } catch (e) {
      emit(HomeFailure(error: e is AppError ? e : AppError.unknown()));
    }
  }
}
