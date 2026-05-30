import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/networking/supabase_service.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/models/task_assignment_input.dart';

class SupervisorDashboardRemoteDs {
  SupervisorDashboardRemoteDs({required this.supabaseService});

  final SupabaseService supabaseService;

  Future<int> fetchActiveUnitsCount() async {
    try {
      final response = await supabaseService.client
          .from('units')
          .count()
          .eq('status', 'active');
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<int> fetchCompletedTasksTodayCount() async {
    try {
      final today = _todayStart();
      final tomorrow = _tomorrowStart();
      final response = await supabaseService.client
          .from('tasks')
          .count()
          .eq('status', 'completed')
          .gte('scheduled_start', today.toIso8601String())
          .lt('scheduled_start', tomorrow.toIso8601String());
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<int> fetchDelayedTasksCount() async {
    try {
      final response = await supabaseService.client
          .from('tasks')
          .count()
          .lt('scheduled_end', DateTime.now().toIso8601String())
          .not('status', 'in', '(completed,cancelled)');
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<int> fetchReportsTodayCount() async {
    try {
      final today = _todayStart();
      final tomorrow = _tomorrowStart();
      final response = await supabaseService.client
          .from('reports')
          .count()
          .gte('created_at', today.toIso8601String())
          .lt('created_at', tomorrow.toIso8601String());
      return response;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchTodaysTasksForSummary() async {
    try {
      final today = _todayStart();
      final tomorrow = _tomorrowStart();
      final data = await supabaseService.client
          .from('tasks')
          .select('status, scheduled_end')
          .gte('scheduled_start', today.toIso8601String())
          .lt('scheduled_start', tomorrow.toIso8601String());
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<FlightModel>> fetchUpcomingFlights() async {
    try {
      final now = DateTime.now();
      final in24h = now.add(const Duration(hours: 24));
      final data = await supabaseService.client
          .from('flights')
          .select('id, flight_number, airline, origin, destination, scheduled_arrival, status, stand_id, api_source')
          .gte('scheduled_arrival', now.toIso8601String())
          .lte('scheduled_arrival', in24h.toIso8601String())
          .not('status', 'in', '(cancelled,departed)')
          .order('scheduled_arrival', ascending: true);
      return (data as List).map((e) => FlightModel.fromMap(e)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<UnitModel>> fetchAllActiveUnits() async {
    try {
      final data = await supabaseService.client
          .from('units')
          .select()
          .eq('status', 'active')
          .order('name', ascending: true);
      return (data as List).map((e) => UnitModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<ServiceTypeModel>> fetchAllServiceTypes() async {
    try {
      final data = await supabaseService.client
          .from('service_types')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);
      return (data as List).map((e) => ServiceTypeModel.fromMap(e)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<TaskModel> assignTask(
    TaskAssignmentInput input,
    String assignedBy,
  ) async {
    try {
      final data = await supabaseService.client
          .from('tasks')
          .insert({
            'flight_id': input.flightId,
            'service_type_id': input.serviceTypeId,
            'unit_id': input.unitId,
            'assigned_by': assignedBy,
            'created_by': assignedBy,
            'status': 'assigned',
            'priority': input.priority.value,
            'scheduled_start': input.scheduledStart.toIso8601String(),
            'scheduled_end': input.scheduledEnd.toIso8601String(),
            'notes': input.notes,
          })
          .select('''
            *,
            service_types (*),
            flights (*, stands (*))
          ''')
          .single();
      return TaskModel.fromMap(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _tomorrowStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }
}
