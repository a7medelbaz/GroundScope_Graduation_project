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
        filteredReports: _applyFilters(
          reports,
          state.activeFilter,
          state.activeSeverityFilter,
          state.activeRoleFilter,
          state.searchQuery,
        ),
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
      filteredReports: _applyFilters(
        state.allReports,
        filter,
        state.activeSeverityFilter,
        state.activeRoleFilter,
        state.searchQuery,
      ),
    ));
  }

  void setSeverityFilter(String filter) {
    emit(state.copyWith(
      activeSeverityFilter: filter,
      filteredReports: _applyFilters(
        state.allReports,
        state.activeFilter,
        filter,
        state.activeRoleFilter,
        state.searchQuery,
      ),
    ));
  }

  void setRoleFilter(String filter) {
    emit(state.copyWith(
      activeRoleFilter: filter,
      filteredReports: _applyFilters(
        state.allReports,
        state.activeFilter,
        state.activeSeverityFilter,
        filter,
        state.searchQuery,
      ),
    ));
  }

  void clearAdvancedFilters() {
    emit(state.copyWith(
      activeSeverityFilter: 'all',
      activeRoleFilter: 'all',
      filteredReports: _applyFilters(
        state.allReports,
        state.activeFilter,
        'all',
        'all',
        state.searchQuery,
      ),
    ));
  }

  void setSearch(String query) {
    emit(state.copyWith(
      searchQuery: query,
      filteredReports: _applyFilters(
        state.allReports,
        state.activeFilter,
        state.activeSeverityFilter,
        state.activeRoleFilter,
        query,
      ),
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
        filteredReports: _applyFilters(
          updated,
          state.activeFilter,
          state.activeSeverityFilter,
          state.activeRoleFilter,
          state.searchQuery,
        ),
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
        filteredReports: _applyFilters(
          updated,
          state.activeFilter,
          state.activeSeverityFilter,
          state.activeRoleFilter,
          state.searchQuery,
        ),
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
    String statusFilter,
    String severityFilter,
    String roleFilter,
    String query,
  ) {
    var result = reports;

    if (statusFilter != 'all') {
      result = result.where((r) => r.status.name == statusFilter).toList();
    }

    if (severityFilter != 'all') {
      result =
          result.where((r) => r.severity.value == severityFilter).toList();
    }

    if (roleFilter != 'all') {
      result = result.where((r) {
        final role = r.reporterRole;
        if (roleFilter == 'admin') {
          return role == 'admin' || role == 'supervisor';
        }
        // 'worker' bucket = workers + unit managers + unknown
        return role == 'worker' || role == 'unit_manager' || role == null;
      }).toList();
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
