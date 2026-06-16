import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import '../models/dashboard_stats_model.dart';
import '../remote/dashboard_remote_ds.dart';
import 'dashboard_repo.dart';

class DashboardRepoImpl implements DashboardRepo {
  const DashboardRepoImpl({required this.dashboardRemoteDs});

  final DashboardRemoteDs dashboardRemoteDs;

  @override
  Future<DashboardStatsModel> loadDashboardStats() async {
    try {
      return await dashboardRemoteDs.fetchDashboardStats();
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
