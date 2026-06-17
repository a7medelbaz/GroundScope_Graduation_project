import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import '../../data/repo/supervisor_reports_repo.dart';

part 'supervisor_reports_state.dart';

class SupervisorReportsCubit extends Cubit<SupervisorReportsState> {
  SupervisorReportsCubit({
    required SupervisorReportsRepo repo,
    required UserService userService,
  })  : _repo = repo,
        _userService = userService,
        super(const SupervisorReportsState());

  final SupervisorReportsRepo _repo;
  final UserService _userService;

  Future<void> loadReports(String serviceTypeId) async {
    emit(state.copyWith(status: SupervisorReportsStatus.loading));
    try {
      final reports = await _repo.fetchReports(serviceTypeId);
      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        allReports: reports,
        filteredReports: _applyFilters(reports, state.activeFilter, state.searchQuery),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupervisorReportsStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }

  Future<void> refresh(String serviceTypeId) => loadReports(serviceTypeId);

  void setFilter(String filter) {
    emit(state.copyWith(
      activeFilter: filter,
      filteredReports: _applyFilters(state.allReports, filter, state.searchQuery),
    ));
  }

  void setSearch(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredReports: _applyFilters(state.allReports, state.activeFilter, query),
    ));
  }

  Future<void> acknowledgeReport(String reportId) async {
    emit(state.copyWith(
      status: SupervisorReportsStatus.actionLoading,
      actionReportId: reportId,
    ));
    try {
      final user = await _userService.getUser();
      final supervisorId = user?.id ?? '';
      await _repo.acknowledgeReport(reportId: reportId, supervisorId: supervisorId);

      // Optimistic update
      final updated = state.allReports.map((r) {
        if (r.id != reportId) return r;
        return r.copyWith(
          status: ReportStatus.acknowledged,
          acknowledgedBy: supervisorId,
          acknowledgedAt: DateTime.now(),
        );
      }).toList();

      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        allReports: updated,
        filteredReports: _applyFilters(updated, state.activeFilter, state.searchQuery),
        actionReportId: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        error: AppError.unknown(),
        actionReportId: null,
      ));
    }
  }

  Future<void> resolveReport(String reportId) async {
    emit(state.copyWith(
      status: SupervisorReportsStatus.actionLoading,
      actionReportId: reportId,
    ));
    try {
      final user = await _userService.getUser();
      final supervisorId = user?.id ?? '';
      await _repo.resolveReport(reportId: reportId, supervisorId: supervisorId);

      // Optimistic update
      final updated = state.allReports.map((r) {
        if (r.id != reportId) return r;
        return r.copyWith(
          status: ReportStatus.resolved,
          resolvedBy: supervisorId,
          resolvedAt: DateTime.now(),
        );
      }).toList();

      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        allReports: updated,
        filteredReports: _applyFilters(updated, state.activeFilter, state.searchQuery),
        actionReportId: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        error: AppError.unknown(),
        actionReportId: null,
      ));
    }
  }

  List<ReportModel> _applyFilters(
    List<ReportModel> reports,
    String filter,
    String query,
  ) {
    var result = reports;
    if (filter != 'all') {
      result = result.where((r) => r.status.name == filter).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((r) {
        final flightNum = r.flight?.flightNumber.toLowerCase() ?? '';
        final desc = r.description.toLowerCase();
        return flightNum.contains(q) || desc.contains(q);
      }).toList();
    }
    return result;
  }
}
