import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
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
  StreamSubscription<(List<ReportModel>, List<ReportModel>)>? _receivedSub;

  Future<void> load() async {
    emit(state.copyWith(status: SupervisorReportsStatus.loading));
    String? supervisorId;
    try {
      final user = await _userService.getUser();
      if (user == null) {
        emit(state.copyWith(
            status: SupervisorReportsStatus.failure,
            error: AppError.unauthorized()));
        return;
      }
      supervisorId = user.id;

      final receivedFuture = _repo.fetchReceived(user.id);
      final sentFuture = _repo.fetchSent(user.id);
      final received = await receivedFuture;
      final sent = await sentFuture;

      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        inbox: received.$1,
        fromAdmin: received.$2,
        sent: sent,
      ));
    } catch (e, st) {
      debugPrint('[SupervisorReportsCubit.load] failed: $e\n$st');
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure,
          error: SupabaseErrorHandler.handle(e)));
      return;
    }

    _watchReceived(supervisorId);
  }

  void _watchReceived(String supervisorId) {
    try {
      _receivedSub?.cancel();
      _receivedSub = _repo.watchReceived(supervisorId).listen(
        (received) {
          if (isClosed) return;
          emit(state.copyWith(
            inbox: received.$1,
            fromAdmin: received.$2,
          ));
        },
        onError: (_) {},
      );
    } catch (_) {
      // Real-time is best-effort — the initial load already succeeded.
    }
  }

  @override
  Future<void> close() {
    _receivedSub?.cancel();
    return super.close();
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

  Future<void> markAsRead(String reportId) async {
    final user = await _userService.getUser();
    if (user == null) return;
    try {
      await _repo.markAsRead(reportId: reportId, supervisorId: user.id);
    } catch (_) {
      // Best-effort — the real-time stream will still reflect the true
      // state on next update.
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

      if (isClosed) return;
      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        inbox: updated.$1,
        sent: updated.$2,
        fromAdmin: updated.$3,
        actionReportId: null,
      ));
    } catch (_) {
      if (isClosed) return;
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

      if (isClosed) return;
      emit(state.copyWith(
        status: SupervisorReportsStatus.loaded,
        inbox: updated.$1,
        sent: updated.$2,
        fromAdmin: updated.$3,
        actionReportId: null,
      ));
    } catch (_) {
      if (isClosed) return;
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

      final (report, recipientIds) = await _repo.sendToUnit(
        supervisorId: user.id,
        unitId: unitId,
        type: type,
        severity: severity,
        description: description,
        imageFile: imageFile,
      );

      // Notifications are best-effort
      _notifyRecipients(recipientIds, report, 'Supervisor Alert');

      if (isClosed) return;
      emit(state.copyWith(
          status: SupervisorReportsStatus.submitSuccess,
          sent: [report, ...state.sent]));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure, error: e));
    } catch (_) {
      if (isClosed) return;
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

      final (report, recipientIds) = await _repo.broadcast(
        supervisorId: user.id,
        serviceTypeId: serviceTypeId,
        type: type,
        severity: severity,
        description: description,
        imageFile: imageFile,
      );

      _notifyRecipients(recipientIds, report, 'Supervisor Broadcast');

      if (isClosed) return;
      emit(state.copyWith(
          status: SupervisorReportsStatus.submitSuccess,
          sent: [report, ...state.sent]));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure, error: e));
    } catch (_) {
      if (isClosed) return;
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

      final (report, recipientIds) = await _repo.forwardToAdmin(
        original: original,
        supervisorId: user.id,
        notes: notes,
      );

      _notifyRecipients(recipientIds, report, 'Forwarded Report');

      if (isClosed) return;
      emit(state.copyWith(
          status: SupervisorReportsStatus.submitSuccess,
          sent: [report, ...state.sent]));
    } on AppError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
          status: SupervisorReportsStatus.failure, error: e));
    } catch (_) {
      if (isClosed) return;
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

  void _notifyRecipients(
      List<String> recipientIds, ReportModel report, String title) {
    // Fire-and-forget — NotificationSender.send silently fails per recipient.
    for (final userId in recipientIds) {
      NotificationSender.send(
        userId: userId,
        title: title,
        body: report.description,
        type: NotificationType.alert,
        referenceId: report.id,
        referenceType: 'report',
      );
    }
  }
}
