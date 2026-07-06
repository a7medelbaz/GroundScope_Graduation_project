part of 'supervisor_reports_cubit.dart';

enum SupervisorReportsStatus {
  initial,
  loading,
  loaded,
  actionLoading,
  submitting,
  submitSuccess,
  failure,
}

enum SupervisorReportsTab { inbox, sent, fromAdmin }

const _clearId = Object();

final class SupervisorReportsState extends Equatable {
  const SupervisorReportsState({
    this.status = SupervisorReportsStatus.initial,
    this.inbox = const [],
    this.sent = const [],
    this.fromAdmin = const [],
    this.tab = SupervisorReportsTab.inbox,
    this.selectedFilter,
    this.actionReportId,
    this.error,
  });

  final SupervisorReportsStatus status;
  final List<ReportModel> inbox;
  final List<ReportModel> sent;
  final List<ReportModel> fromAdmin;
  final SupervisorReportsTab tab;
  final ReportStatus? selectedFilter;
  final String? actionReportId;
  final AppError? error;

  List<ReportModel> get currentList => switch (tab) {
        SupervisorReportsTab.inbox => inbox,
        SupervisorReportsTab.sent => sent,
        SupervisorReportsTab.fromAdmin => fromAdmin,
      };

  List<ReportModel> get filteredList {
    final base = currentList;
    return selectedFilter == null
        ? base
        : base.where((r) => r.status == selectedFilter).toList();
  }

  int get unreadInbox => inbox.where((r) => r.isRead == false).length;

  SupervisorReportsState copyWith({
    SupervisorReportsStatus? status,
    List<ReportModel>? inbox,
    List<ReportModel>? sent,
    List<ReportModel>? fromAdmin,
    SupervisorReportsTab? tab,
    ReportStatus? selectedFilter,
    bool clearFilter = false,
    Object? actionReportId = _clearId,
    AppError? error,
  }) {
    return SupervisorReportsState(
      status: status ?? this.status,
      inbox: inbox ?? this.inbox,
      sent: sent ?? this.sent,
      fromAdmin: fromAdmin ?? this.fromAdmin,
      tab: tab ?? this.tab,
      selectedFilter:
          clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      actionReportId: identical(actionReportId, _clearId)
          ? this.actionReportId
          : actionReportId as String?,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        inbox,
        sent,
        fromAdmin,
        tab,
        selectedFilter,
        actionReportId,
        error,
      ];
}
