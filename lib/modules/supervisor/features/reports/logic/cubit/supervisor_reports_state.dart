part of 'supervisor_reports_cubit.dart';

sealed class SupervisorReportsState extends Equatable {
  const SupervisorReportsState();

  @override
  List<Object?> get props => [];
}

final class SupervisorReportsInitial extends SupervisorReportsState {}

final class SupervisorReportsLoading extends SupervisorReportsState {}

final class SupervisorReportsLoaded extends SupervisorReportsState {
  const SupervisorReportsLoaded({
    required this.allReports,
    required this.filteredReports,
    this.searchQuery = '',
  });

  final List<ReportModel> allReports;
  final List<ReportModel> filteredReports;
  final String searchQuery;

  SupervisorReportsLoaded copyWith({
    List<ReportModel>? allReports,
    List<ReportModel>? filteredReports,
    String? searchQuery,
  }) {
    return SupervisorReportsLoaded(
      allReports: allReports ?? this.allReports,
      filteredReports: filteredReports ?? this.filteredReports,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allReports, filteredReports, searchQuery];
}

final class SupervisorReportsFailure extends SupervisorReportsState {
  const SupervisorReportsFailure({required this.error});

  final AppError error;

  @override
  List<Object?> get props => [error];
}
