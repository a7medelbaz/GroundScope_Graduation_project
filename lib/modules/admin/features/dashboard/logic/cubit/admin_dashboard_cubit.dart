import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/repo/flight_repo.dart';
import 'package:ground_scope/core/shared/data/repo/report_repo.dart';
import 'package:ground_scope/core/shared/data/repo/task_repo.dart';
import 'package:ground_scope/core/shared/data/repo/unit_repo.dart';

part 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit(
    this._userService,
    this._flightRepo,
    this._taskRepo,
    this._reportRepo,
    this._unitRepo,
  ) : super(const AdminDashboardState());

  final UserService _userService;
  final FlightRepo _flightRepo;
  final TaskRepo _taskRepo;
  final ReportRepo _reportRepo;
  final UnitRepo _unitRepo;

  Future<void> load() async {
    emit(state.copyWith(status: AdminDashboardStatus.loading));
    try {
      final user = await _userService.getUser();

      final results = await Future.wait([
        _flightRepo.countActiveFlightsToday(),
        _taskRepo.countPendingTasks(),
        _reportRepo.countOpenReports(),
        _unitRepo.countActiveUnits(),
      ]);

      emit(
        state.copyWith(
          status: AdminDashboardStatus.success,
          adminName: user?.fullName,
          activeFlightsCount: results[0],
          pendingTasksCount: results[1],
          openReportsCount: results[2],
          activeUnitsCount: results[3],
        ),
      );
    } on AppError catch (e) {
      debugPrint('Error loading dashboard stats: ${e.messageKey}');
      emit(state.copyWith(status: AdminDashboardStatus.failure, error: e));
    } catch (_) {
      emit(
        state.copyWith(
          status: AdminDashboardStatus.failure,
          error: AppError.unknown(),
        ),
      );
    }
  }
}
