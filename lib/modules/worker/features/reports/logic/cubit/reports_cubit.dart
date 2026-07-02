import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/shared/data/repo/report_repo.dart';
part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({required this.reportRepo, required this.userService})
      : super(const ReportsState());

  final ReportRepo reportRepo;
  final UserService userService;
  StreamSubscription<List<ReportModel>>? _receivedSub;

  Future<void> load() async {
    emit(state.copyWith(status: ReportsStatus.loading, clearError: true));
    String? userId;
    try {
      final user = await userService.getUser();
      if (user == null) {
        emit(state.copyWith(
            status: ReportsStatus.failure, error: AppError.unauthorized()));
        return;
      }
      userId = user.id;

      final results = await Future.wait([
        reportRepo.fetchSentReports(user.id),
        reportRepo.fetchReceivedReports(user.id),
      ]);

      emit(state.copyWith(
        status: ReportsStatus.loaded,
        sent: results[0],
        received: results[1],
      ));
    } on AppError catch (e) {
      emit(state.copyWith(status: ReportsStatus.failure, error: e));
      return;
    } catch (_) {
      emit(state.copyWith(
          status: ReportsStatus.failure, error: AppError.unknown()));
      return;
    }

    _watchReceived(userId);
  }

  // Keep for backward compat with any existing references
  Future<void> fetchMyReports() => load();

  void switchTab(ReportsTab tab) => emit(state.copyWith(tab: tab));

  void setFilter(ReportStatus? filter) {
    if (filter == null || state.selectedFilter == filter) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(selectedFilter: filter));
    }
  }

  void _watchReceived(String userId) {
    try {
      _receivedSub?.cancel();
      _receivedSub = reportRepo.watchReceivedReports(userId).listen(
        (received) => emit(state.copyWith(received: received)),
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
}
