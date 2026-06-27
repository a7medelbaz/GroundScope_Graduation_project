import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/notifications/data/models/notification_model.dart';
import 'package:ground_scope/core/notifications/service/notification_sender.dart';
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

  Future<void> load() async {
    emit(state.copyWith(status: SupervisorReportsStatus.loading));
    try {
      final user = await _userService.getUser();
      if (user == null) {
        emit(state.copyWith(
            status: SupervisorReportsStatus.failure,
            error: AppError.unauthorized()));
        return;
      }

      final results = await Future.wait([
        _repo.fetchInbox(user.id),
        _repo.fetchSent(user.id),
        _repo.fetchFromAdmin(user.id),
      ]);

      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        inbox: results[0],
        sent: results[1],
        fromAdmin: results[2],
      ));
    } catch (_) {
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure,
          error: AppError.unknown()));
    }
  }

  void switchTab(SupervisorReportsTab tab) =>
      emit(state.copyWith(tab: tab));

  void setFilter(ReportStatus? filter) {
    if (filter == null || state.selectedFilter == filter) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(selectedFilter: filter));
    }
  }

  Future<void> acknowledgeReport(String reportId) async {
    emit(state.copyWith(
        status: SupervisorReportsStatus.actionLoading,
        actionReportId: reportId));
    try {
      final user = await _userService.getUser();
      final supervisorId = user?.id ?? '';
      await _repo.acknowledgeReport(
          reportId: reportId, supervisorId: supervisorId);

      final updated = _updateReportInLists(
          reportId,
          (r) => r.copyWith(
                status: ReportStatus.acknowledged,
                acknowledgedBy: supervisorId,
                acknowledgedAt: DateTime.now(),
              ));

      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        inbox: updated.$1,
        sent: updated.$2,
        fromAdmin: updated.$3,
        actionReportId: null,
      ));
    } catch (_) {
      emit(state.copyWith(
          status: SupervisorReportsStatus.loaded,
          error: AppError.unknown(),
          actionReportId: null));
    }
  }

  Future<void> resolveReport(String reportId) async {
    emit(state.copyWith(
        status: SupervisorReportsStatus.actionLoading,
        actionReportId: reportId));
    try {
      final user = await _userService.getUser();
      final supervisorId = user?.id ?? '';
      await _repo.resolveReport(
          reportId: reportId, supervisorId: supervisorId);

      final updated = _updateReportInLists(
          reportId,
          (r) => r.copyWith(
                status: ReportStatus.resolved,
                resolvedBy: supervisorId,
                resolvedAt: DateTime.now(),
              ));

      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        inbox: updated.$1,
        sent: updated.$2,
        fromAdmin: updated.$3,
        actionReportId: null,
      ));
    } catch (_) {
      emit(state.copyWith(
          status: SupervisorReportsStatus.loaded,
          error: AppError.unknown(),
          actionReportId: null));
    }
  }

  Future<void> sendToUnit({
    required String unitId,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  }) async {
    emit(state.copyWith(status: SupervisorReportsStatus.submitting));
    try {
      final user = await _userService.getUser();
      if (user == null) throw AppError.unknown();

      final report = await _repo.sendToUnit(
        supervisorId: user.id,
        unitId: unitId,
        type: type,
        severity: severity,
        description: description,
        imageFile: imageFile,
      );

      // Notifications are best-effort
      _notifyUnitMembers(unitId, report, user.fullName);

      emit(state.copyWith(
          status: SupervisorReportsStatus.submitSuccess,
          sent: [report, ...state.sent]));
    } on AppError catch (e) {
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure, error: AppError.unknown()));
    }
  }

  Future<void> broadcastToAll({
    required String serviceTypeId,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  }) async {
    emit(state.copyWith(status: SupervisorReportsStatus.submitting));
    try {
      final user = await _userService.getUser();
      if (user == null) throw AppError.unknown();

      final report = await _repo.broadcast(
        supervisorId: user.id,
        serviceTypeId: serviceTypeId,
        type: type,
        severity: severity,
        description: description,
        imageFile: imageFile,
      );

      emit(state.copyWith(
          status: SupervisorReportsStatus.submitSuccess,
          sent: [report, ...state.sent]));
    } on AppError catch (e) {
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure, error: AppError.unknown()));
    }
  }

  Future<void> forwardToAdmin({
    required ReportModel original,
    required String notes,
  }) async {
    emit(state.copyWith(status: SupervisorReportsStatus.submitting));
    try {
      final user = await _userService.getUser();
      if (user == null) throw AppError.unknown();

      final report = await _repo.forwardToAdmin(
        original: original,
        supervisorId: user.id,
        notes: notes,
      );

      emit(state.copyWith(
          status: SupervisorReportsStatus.submitSuccess,
          sent: [report, ...state.sent]));
    } on AppError catch (e) {
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure, error: AppError.unknown()));
    }
  }

  void resetSubmitStatus() {
    if (state.status == SupervisorReportsStatus.submitSuccess ||
        state.status == SupervisorReportsStatus.failure) {
      emit(state.copyWith(status: SupervisorReportsStatus.loaded));
    }
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  (List<ReportModel>, List<ReportModel>, List<ReportModel>) _updateReportInLists(
    String reportId,
    ReportModel Function(ReportModel) updater,
  ) {
    List<ReportModel> update(List<ReportModel> list) =>
        list.map((r) => r.id == reportId ? updater(r) : r).toList();
    return (update(state.inbox), update(state.sent), update(state.fromAdmin));
  }

  void _notifyUnitMembers(
      String unitId, ReportModel report, String senderName) {
    // Fire-and-forget — unit member ids come from report_recipients; we just
    // send one notification tagged with the report so each recipient's device
    // can display it.
    NotificationSender.send(
      userId: unitId,
      title: 'Supervisor Alert',
      body: report.description,
      type: NotificationType.alert,
      referenceId: report.id,
      referenceType: 'report',
    );
  }
}
