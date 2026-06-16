import 'package:flutter/foundation.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRemoteDs {
  const DashboardRemoteDs({required this.supabaseService});

  final SupabaseService supabaseService;

  Future<DashboardStatsModel> fetchDashboardStats() async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();

      final today = DateTime.now().toUtc();
      final startOfDay = DateTime.utc(today.year, today.month, today.day)
          .toIso8601String();

      final results = await Future.wait([
        supabaseService.client
            .from('units')
            .select('id')
            .neq('status', 'offline'),
        supabaseService.client
            .from('tasks')
            .select('id')
            .eq('status', 'completed'),
        // neq chaining is safer than .not('status','in','(...)') across SDK versions
        supabaseService.client
            .from('tasks')
            .select('id')
            .lt('scheduled_end', now)
            .neq('status', 'completed')
            .neq('status', 'cancelled'),
        supabaseService.client
            .from('reports')
            .select('id')
            .gte('created_at', startOfDay),
      ]);

      return DashboardStatsModel(
        activeUnitsCount: (results[0] as List).length,
        completedTasksCount: (results[1] as List).length,
        delayedTasksCount: (results[2] as List).length,
        reportsTodayCount: (results[3] as List).length,
      );
    } catch (e) {
      debugPrint('❌ DashboardRemoteDs.fetchDashboardStats error: $e');
      throw ErrorHandler.handle(e);
    }
  }
}
