import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/shared/data/repo/report_repo.dart';

part 'supervisor_reports_state.dart';

class SupervisorReportsCubit extends Cubit<SupervisorReportsState> {
  SupervisorReportsCubit({required this.reportRepo})
      : super(const SupervisorReportsState());

  final ReportRepo reportRepo;

  Future<void> loadReports() async {
    emit(state.copyWith(status: SupervisorReportsStatus.loading));
    try {
      final reports = await reportRepo.fetchAllReports();
      emit(state.copyWith(
        status: SupervisorReportsStatus.success,
        reports: reports,
      ));
    } on AppError catch (e) {
      emit(state.copyWith(status: SupervisorReportsStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
        status: SupervisorReportsStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }

  Future<bool> deleteReport(String id) async {
    final originalReports = List<ReportModel>.from(state.reports);

    // Optimistic removal
    emit(state.copyWith(
      reports: state.reports.where((r) => r.id != id).toList(),
      deletingReportId: id,
      status: SupervisorReportsStatus.deleting,
    ));

    try {
      await reportRepo.deleteReport(id);
      emit(state.copyWith(
        status: SupervisorReportsStatus.success,
        clearDeletingId: true,
      ));
      return true;
    } on AppError catch (e) {
      emit(state.copyWith(
        reports: originalReports,
        status: SupervisorReportsStatus.failure,
        error: e,
        clearDeletingId: true,
      ));
      return false;
    } catch (_) {
      emit(state.copyWith(
        reports: originalReports,
        status: SupervisorReportsStatus.failure,
        error: AppError.unknown(),
        clearDeletingId: true,
      ));
      return false;
    }
  }
}
