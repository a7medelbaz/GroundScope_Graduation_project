import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/notifications/data/models/notification_model.dart';
import 'package:ground_scope/core/notifications/service/notification_sender.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/shared/data/remote/user_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/report_repo.dart';

part 'admin_reports_state.dart';

class AdminReportsCubit extends Cubit<AdminReportsState> {
  AdminReportsCubit({
    required ReportRepo reportRepo,
    required UserService userService,
    required UserRemoteDs userRemoteDs,
  })  : _reportRepo = reportRepo,
        _userService = userService,
        _userRemoteDs = userRemoteDs,
        super(const AdminReportsState());

  final ReportRepo _reportRepo;
  final UserService _userService;
  final UserRemoteDs _userRemoteDs;
  StreamSubscription<List<ReportModel>>? _allSub;
  String? _currentUserId;

  Future<void> load() async {
    emit(state.copyWith(status: AdminReportsStatus.loading));
    try {
      final user = await _userService.getUser();
      if (user == null) {
        emit(state.copyWith(
            status: AdminReportsStatus.failure,
            error: AppError.unauthorized()));
        return;
      }
      _currentUserId = user.id;

      final results = await Future.wait([
        _reportRepo.fetchAllReports(),
        _reportRepo.fetchSentReports(user.id),
      ]);

      emit(state.copyWith(
        status: AdminReportsStatus.loaded,
        all: results[0],
        myReports: results[1],
      ));
    } catch (e, st) {
      debugPrint('[AdminReportsCubit.load] failed: $e\n$st');
      emit(state.copyWith(
          status: AdminReportsStatus.failure, error: AppError.unknown()));
      return;
    }

    _watchAll();
  }

  void _watchAll() {
    try {
      _allSub?.cancel();
      _allSub = _reportRepo.watchAllReports().listen(
        (all) => emit(state.copyWith(
          all: all,
          myReports: _currentUserId == null
              ? state.myReports
              : all.where((r) => r.reportedBy == _currentUserId).toList(),
        )),
        onError: (e, st) =>
            debugPrint('[AdminReportsCubit._watchAll] stream error: $e\n$st'),
      );
    } catch (e, st) {
      debugPrint('[AdminReportsCubit._watchAll] setup failed: $e\n$st');
      // Real-time is best-effort — the initial load already succeeded.
    }
  }

  @override
  Future<void> close() {
    _allSub?.cancel();
    return super.close();
  }

  void switchTab(AdminReportsTab tab) => emit(state.copyWith(tab: tab));

  void filterByDirection(ReportDirection? direction) =>
      emit(state.copyWith(directionFilter: direction, clearFilter: direction == null));

  void setSearch(String query) => emit(state.copyWith(searchQuery: query));

  Future<void> sendToSupervisors({
    required List<String> supervisorIds,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  }) async {
    emit(state.copyWith(status: AdminReportsStatus.submitting));
    try {
      final user = await _userService.getUser();
      if (user == null) throw AppError.unknown();

      final report = await _reportRepo.submitReport(
        reportedBy: user.id,
        type: type,
        description: description,
        severity: severity,
        direction: ReportDirection.adminToSupervisor,
        recipientUserIds: supervisorIds,
        imageFile: imageFile,
      );

      for (final supId in supervisorIds) {
        NotificationSender.send(
          userId: supId,
          title: 'Admin Alert',
          body: description,
          type: NotificationType.alert,
          referenceId: report.id,
          referenceType: 'report',
        );
      }

      emit(state.copyWith(
          status: AdminReportsStatus.submitSuccess,
          all: [report, ...state.all],
          myReports: [report, ...state.myReports]));
    } on AppError catch (e) {
      debugPrint('[AdminReportsCubit.sendToSupervisors] failed: $e');
      emit(state.copyWith(status: AdminReportsStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('[AdminReportsCubit.sendToSupervisors] failed: $e\n$st');
      emit(state.copyWith(
          status: AdminReportsStatus.failure, error: AppError.unknown()));
    }
  }

  Future<void> broadcast({
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    File? imageFile,
  }) async {
    emit(state.copyWith(status: AdminReportsStatus.submitting));
    try {
      final user = await _userService.getUser();
      if (user == null) throw AppError.unknown();

      final allUserIds = await _userRemoteDs.fetchAllNonAdminUserIds();

      final report = await _reportRepo.submitReport(
        reportedBy: user.id,
        type: type,
        description: description,
        severity: severity,
        direction: ReportDirection.adminBroadcast,
        recipientUserIds: allUserIds,
        imageFile: imageFile,
      );

      for (final userId in allUserIds) {
        NotificationSender.send(
          userId: userId,
          title: 'Admin Broadcast',
          body: description,
          type: NotificationType.alert,
          referenceId: report.id,
          referenceType: 'report',
        );
      }

      emit(state.copyWith(
          status: AdminReportsStatus.submitSuccess,
          all: [report, ...state.all],
          myReports: [report, ...state.myReports]));
    } on AppError catch (e) {
      debugPrint('[AdminReportsCubit.broadcast] failed: $e');
      emit(state.copyWith(status: AdminReportsStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('[AdminReportsCubit.broadcast] failed: $e\n$st');
      emit(state.copyWith(
          status: AdminReportsStatus.failure, error: AppError.unknown()));
    }
  }

  void resetSubmitStatus() {
    if (state.status == AdminReportsStatus.submitSuccess ||
        state.status == AdminReportsStatus.failure) {
      emit(state.copyWith(status: AdminReportsStatus.loaded));
    }
  }
}
