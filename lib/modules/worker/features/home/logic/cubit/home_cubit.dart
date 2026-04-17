import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/secure_storage.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/shared/data/repo/unit_repo.dart';
import 'package:ground_scope/core/utils/app_constants.dart';

import '../../data/repo/home_repo.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.homeRepo, required this.unitRepo})
    : super(HomeInitial());

  final HomeRepo homeRepo;
  final UnitRepo unitRepo;

  Future<UserModel?> _getUser() async {
    final jsonString = await getIt<SecureStorage>().read(
      key: AppConstants.userDataKey,
    );

    if (jsonString == null) {
      print("❌ ERROR: No data found in Secure Storage. User is not logged in.");
      return null;
    }

    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return UserModel.fromJson(map);
    } catch (e) {
      print("❌ MODEL PARSING FAILED: $e");
    }
    return null;
  }

  Future<void> fetchUnitData() async {
    final currentTasks = state is HomeLoaded
        ? (state as HomeLoaded).tasks
        : <TaskModel>[];
    if (state is! HomeLoaded) emit(HomeLoading());

    try {
      final user = await _getUser();

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
      final user = await _getUser();
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
      emit(HomeFailure(error: AppError.unknown()));
    }
  }

  Future<void> init() async {
    emit(HomeLoading());
    try {
      final user = await _getUser();
      if (user == null || user.unitId == null) {
        emit(
          HomeFailure(
            error: AppError.unauthorized('No unit assigned to user.'),
          ),
        );
        return;
      }
      final results = await Future.wait([
        homeRepo.fetchWorkerTasks(unitId: user.unitId!),
        unitRepo.getUnitData(unitId: user.unitId!),
      ]);
      final tasks = results[0] as List<TaskModel>;
      final unit = results[1] as UnitModel;
      emit(HomeLoaded(unit: unit, tasks: tasks));
    } catch (e) {
      emit(HomeFailure(error: AppError.unknown()));
    }
  }
}
