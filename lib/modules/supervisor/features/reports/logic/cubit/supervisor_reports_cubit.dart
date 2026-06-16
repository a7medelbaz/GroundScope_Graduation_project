import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/shared/data/repo/report_repo.dart';

part 'supervisor_reports_state.dart';

class SupervisorReportsCubit extends Cubit<SupervisorReportsState> {
  SupervisorReportsCubit({required this.reportRepo})
      : super(SupervisorReportsInitial());

  final ReportRepo reportRepo;

  Future<void> loadReportsToday() async {
    emit(SupervisorReportsLoading());
    try {
      final reports = await reportRepo.fetchReportsToday();
      emit(SupervisorReportsLoaded(allReports: reports, filteredReports: reports));
    } on AppError catch (e) {
      emit(SupervisorReportsFailure(error: e));
    } catch (_) {
      emit(SupervisorReportsFailure(error: AppError.unknown()));
    }
  }

  void search(String query) {
    final current = state;
    if (current is! SupervisorReportsLoaded) return;

    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? current.allReports
        : current.allReports.where((r) {
            return r.type.label.toLowerCase().contains(q) ||
                r.description.toLowerCase().contains(q) ||
                r.severity.label.toLowerCase().contains(q);
          }).toList();

    emit(current.copyWith(filteredReports: filtered, searchQuery: query));
  }
}
