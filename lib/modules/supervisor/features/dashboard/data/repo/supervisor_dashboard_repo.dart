import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/models/task_assignment_input.dart';

abstract class SupervisorDashboardRepo {
  Future<int> fetchActiveUnitsCount();
  Future<int> fetchCompletedTasksTodayCount();
  Future<int> fetchDelayedTasksCount();
  Future<int> fetchReportsTodayCount();
  Future<List<Map<String, dynamic>>> fetchTodaysTasksForSummary();
  Future<List<FlightModel>> fetchUpcomingFlights();
  Future<List<UnitModel>> fetchAllActiveUnits();
  Future<List<ServiceTypeModel>> fetchAllServiceTypes();
  Future<TaskModel> assignTask(TaskAssignmentInput input, String assignedBy);
}
