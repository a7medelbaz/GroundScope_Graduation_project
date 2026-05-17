import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_type.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/repo/supervisor_dashboard_repo.dart';

part 'supervisor_dashboard_state.dart';

class SupervisorDashboardCubit extends Cubit<SupervisorDashboardState> {
  SupervisorDashboardCubit({required this.repo})
      : super(const SupervisorDashboardState());

  final SupervisorDashboardRepo repo;

  Future<void> loadDashboard() async {
    if (state.status == DashboardStatus.loading) return;
    emit(state.copyWith(status: DashboardStatus.loading, clearError: true));

    final results = await Future.wait<dynamic>([
      _safeCall<int>(() => repo.fetchActiveUnitsCount()),
      _safeCall<int>(() => repo.fetchCompletedTasksTodayCount()),
      _safeCall<int>(() => repo.fetchDelayedTasksCount()),
      _safeCall<int>(() => repo.fetchReportsTodayCount()),
      _safeCall<List<Map<String, dynamic>>>(
          () => repo.fetchTodaysTasksForSummary()),
    ]);

    final (int? activeUnits, AppError? e0) = results[0] as (int?, AppError?);
    final (int? completedTasks, AppError? e1) = results[1] as (int?, AppError?);
    final (int? delayedTasks, AppError? e2) = results[2] as (int?, AppError?);
    final (int? reportsToday, AppError? e3) = results[3] as (int?, AppError?);
    final (List<Map<String, dynamic>>? taskRows, AppError? e4) =
        results[4] as (List<Map<String, dynamic>>?, AppError?);

    final errors =
        [e0, e1, e2, e3, e4].whereType<AppError>().toList();

    // Any auth error means the session has expired — redirect to login
    if (errors.any((e) => e.isAuthError)) {
      emit(state.copyWith(status: DashboardStatus.sessionExpired));
      return;
    }

    // All 5 queries failed — show full-screen error
    if (errors.length == 5) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        error: _dominantError(errors),
      ));
      return;
    }

    // At least one query succeeded — emit partial or full data
    final stats = DashboardStatsModel(
      activeUnits: activeUnits,
      completedTasksToday: completedTasks,
      delayedTasks: delayedTasks,
      reportsToday: reportsToday,
    );

    final summary = taskRows != null
        ? _buildSummary(taskRows)
        : const TaskStatusSummaryModel(
            total: 0, done: 0, inProgress: 0, delayed: 0);

    emit(state.copyWith(
      status: DashboardStatus.success,
      stats: stats,
      taskSummary: summary,
    ));
  }

  Future<void> refresh() => loadDashboard();

  /// Returns the most actionable error from a non-empty list.
  /// Priority: noInternet > internalServer > first error encountered.
  AppError _dominantError(List<AppError> errors) {
    for (final e in errors) {
      if (e.type == ErrorType.noInternet) return e;
    }
    for (final e in errors) {
      if (e.type == ErrorType.internalServer) return e;
    }
    return errors.first;
  }

  /// Wraps a remote call and returns a settled result — never throws.
  Future<(T?, AppError?)> _safeCall<T>(Future<T> Function() fn) async {
    try {
      return (await fn(), null);
    } on AppError catch (e) {
      return (null, e);
    } catch (_) {
      return (null, AppError.unknown());
    }
  }

  TaskStatusSummaryModel _buildSummary(List<Map<String, dynamic>> rows) {
    int done = 0;
    int inProgress = 0;
    int delayed = 0;
    final now = DateTime.now();

    for (final row in rows) {
      final status = TaskStatus.fromString(row['status'] as String? ?? '');
      final scheduledEnd = row['scheduled_end'] != null
          ? DateTime.tryParse(row['scheduled_end'] as String)
          : null;

      final isDelayed = scheduledEnd != null &&
          scheduledEnd.isBefore(now) &&
          status != TaskStatus.completed &&
          status != TaskStatus.cancelled;

      if (isDelayed) {
        delayed++;
      } else if (status == TaskStatus.completed) {
        done++;
      } else if (status == TaskStatus.inProgress ||
          status == TaskStatus.assigned ||
          status == TaskStatus.paused) {
        inProgress++;
      }
    }

    return TaskStatusSummaryModel(
      total: rows.length,
      done: done,
      inProgress: inProgress,
      delayed: delayed,
    );
  }
}
