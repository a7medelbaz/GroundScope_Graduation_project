import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/models/task_assignment_input.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/remote/supervisor_dashboard_remote_ds.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/repo/supervisor_dashboard_repo.dart';

class SupervisorDashboardRepoImpl implements SupervisorDashboardRepo {
  SupervisorDashboardRepoImpl({required this.remoteDs});

  final SupervisorDashboardRemoteDs remoteDs;

  @override
  Future<int> fetchActiveUnitsCount() => remoteDs.fetchActiveUnitsCount();

  @override
  Future<int> fetchCompletedTasksTodayCount() =>
      remoteDs.fetchCompletedTasksTodayCount();

  @override
  Future<int> fetchDelayedTasksCount() => remoteDs.fetchDelayedTasksCount();

  @override
  Future<int> fetchReportsTodayCount() => remoteDs.fetchReportsTodayCount();

  @override
  Future<List<Map<String, dynamic>>> fetchTodaysTasksForSummary() =>
      remoteDs.fetchTodaysTasksForSummary();

  @override
  Future<List<FlightModel>> fetchUpcomingFlights() =>
      remoteDs.fetchUpcomingFlights();

  @override
  Future<List<UnitModel>> fetchAllActiveUnits() =>
      remoteDs.fetchAllActiveUnits();

  @override
  Future<List<ServiceTypeModel>> fetchAllServiceTypes() =>
      remoteDs.fetchAllServiceTypes();

  @override
  Future<TaskModel> assignTask(TaskAssignmentInput input, String assignedBy) =>
      remoteDs.assignTask(input, assignedBy);
}
