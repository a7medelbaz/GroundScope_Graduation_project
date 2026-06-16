import '../models/dashboard_stats_model.dart';

abstract class DashboardRepo {
  Future<DashboardStatsModel> loadDashboardStats();
}
