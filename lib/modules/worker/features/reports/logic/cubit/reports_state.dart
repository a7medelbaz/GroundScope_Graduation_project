part of 'reports_cubit.dart';

enum ReportsStatus { initial, loading, loaded, failure }

enum ReportsTab { sent, received }

class ReportsState extends Equatable {
  const ReportsState({
    this.status = ReportsStatus.initial,
    this.sent = const [],
    this.received = const [],
    this.tab = ReportsTab.sent,
    this.error,
    this.selectedFilter,
  });

  final ReportsStatus status;
  final List<ReportModel> sent;
  final List<ReportModel> received;
  final ReportsTab tab;
  final AppError? error;
  final ReportStatus? selectedFilter;

  // Legacy getter — used by ReportDetailsScreen
  List<ReportModel> get reports => tab == ReportsTab.sent ? sent : received;

  List<ReportModel> get filteredReports {
    final base = tab == ReportsTab.sent ? sent : received;
    return selectedFilter == null
        ? base
        : base.where((r) => r.status == selectedFilter).toList();
  }

  int get unreadCount =>
      received.where((r) => r.recipientUserIds == null).length;

  ReportsState copyWith({
    ReportsStatus? status,
    List<ReportModel>? sent,
    List<ReportModel>? received,
    ReportsTab? tab,
    AppError? error,
    bool clearError = false,
    ReportStatus? selectedFilter,
    bool clearFilter = false,
  }) {
    return ReportsState(
      status: status ?? this.status,
      sent: sent ?? this.sent,
      received: received ?? this.received,
      tab: tab ?? this.tab,
      error: clearError ? null : (error ?? this.error),
      selectedFilter:
          clearFilter ? null : (selectedFilter ?? this.selectedFilter),
    );
  }

  @override
  List<Object?> get props =>
      [status, sent, received, tab, error, selectedFilter];
}
