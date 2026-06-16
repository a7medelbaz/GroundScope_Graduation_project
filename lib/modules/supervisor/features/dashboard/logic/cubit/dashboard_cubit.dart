import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/repo/dashboard_repo.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required this.dashboardRepo}) : super(DashboardInitial());

  final DashboardRepo dashboardRepo;

  Future<void> loadDashboardStats() async {
    emit(DashboardLoading());
    try {
      final stats = await dashboardRepo.loadDashboardStats();
      emit(DashboardLoaded(stats: stats));
    } on AppError catch (e) {
      emit(DashboardFailure(error: e));
    } catch (_) {
      emit(DashboardFailure(error: AppError.unknown()));
    }
  }
}
