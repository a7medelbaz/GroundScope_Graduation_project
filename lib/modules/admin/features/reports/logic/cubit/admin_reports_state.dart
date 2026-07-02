part of 'admin_reports_cubit.dart';

enum AdminReportsStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitSuccess,
  failure,
}

enum AdminReportsTab { all, communication, myReports }

class AdminReportsState extends Equatable {
  const AdminReportsState({
    this.status = AdminReportsStatus.initial,
    this.all = const [],
    this.myReports = const [],
    this.tab = AdminReportsTab.all,
    this.directionFilter,
    this.searchQuery = '',
    this.error,
  });

  final AdminReportsStatus status;
  final List<ReportModel> all;
  final List<ReportModel> myReports;
  final AdminReportsTab tab;
  final ReportDirection? directionFilter;
  final String searchQuery;
  final AppError? error;

  List<ReportModel> get displayList {
    List<ReportModel> base = switch (tab) {
      AdminReportsTab.all => all,
      // "Communication" = admin <-> supervisor direct exchanges, excluding
      // worker-originated reports and broadcasts.
      AdminReportsTab.communication => all
          .where((r) =>
              r.direction == ReportDirection.adminToSupervisor ||
              r.direction == ReportDirection.supervisorToAdmin)
          .toList(),
      AdminReportsTab.myReports => myReports,
    };

    if (directionFilter != null) {
      base = base.where((r) => r.direction == directionFilter).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      base = base
          .where((r) =>
              r.description.toLowerCase().contains(q) ||
              (r.reporterName?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return base;
  }

  AdminReportsState copyWith({
    AdminReportsStatus? status,
    List<ReportModel>? all,
    List<ReportModel>? myReports,
    AdminReportsTab? tab,
    ReportDirection? directionFilter,
    bool clearFilter = false,
    String? searchQuery,
    AppError? error,
  }) {
    return AdminReportsState(
      status: status ?? this.status,
      all: all ?? this.all,
      myReports: myReports ?? this.myReports,
      tab: tab ?? this.tab,
      directionFilter:
          clearFilter ? null : (directionFilter ?? this.directionFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, all, myReports, tab, directionFilter, searchQuery, error];
}
