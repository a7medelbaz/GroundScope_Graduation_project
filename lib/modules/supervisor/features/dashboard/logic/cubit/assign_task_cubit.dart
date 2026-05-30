import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/models/task_assignment_input.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/data/repo/supervisor_dashboard_repo.dart';

part 'assign_task_state.dart';

class AssignTaskCubit extends Cubit<AssignTaskState> {
  AssignTaskCubit({required this.repo, required this.userService})
      : super(const AssignTaskState());

  final SupervisorDashboardRepo repo;
  final UserService userService;

  Future<void> loadFormData() async {
    emit(state.copyWith(status: AssignTaskStatus.loadingFormData));

    final results = await Future.wait<dynamic>([
      _safeCall<List<FlightModel>>(() => repo.fetchUpcomingFlights()),
      _safeCall<List<UnitModel>>(() => repo.fetchAllActiveUnits()),
      _safeCall<List<ServiceTypeModel>>(() => repo.fetchAllServiceTypes()),
    ]);

    final (List<FlightModel>? flights, _) =
        results[0] as (List<FlightModel>?, AppError?);
    final (List<UnitModel>? units, AppError? unitsError) =
        results[1] as (List<UnitModel>?, AppError?);
    final (List<ServiceTypeModel>? serviceTypes, AppError? serviceTypesError) =
        results[2] as (List<ServiceTypeModel>?, AppError?);

    if (serviceTypesError != null || unitsError != null) {
      emit(state.copyWith(
        status: AssignTaskStatus.failure,
        error: serviceTypesError ?? unitsError,
      ));
      return;
    }

    emit(state.copyWith(
      status: AssignTaskStatus.formReady,
      flights: flights ?? [],
      allUnits: units ?? [],
      serviceTypes: serviceTypes ?? [],
      filteredUnits: units ?? [],
    ));
  }

  Future<(T?, AppError?)> _safeCall<T>(Future<T> Function() fn) async {
    try {
      return (await fn(), null);
    } on AppError catch (e) {
      return (null, e);
    } catch (_) {
      return (null, AppError.unknown());
    }
  }

  void selectFlight(String id) {
    final flight = state.flights.firstWhere((f) => f.id == id);
    emit(state.copyWith(selectedFlight: flight, clearUnit: true));
  }

  void selectServiceType(String id) {
    final serviceType = state.serviceTypes.firstWhere((s) => s.id == id);
    final filtered = state.allUnits
        .where((u) => u.serviceTypeId == id)
        .toList();
    emit(state.copyWith(
      selectedServiceType: serviceType,
      filteredUnits: filtered,
      clearUnit: true,
    ));
  }

  void selectUnit(String id) {
    final unit = state.allUnits.firstWhere((u) => u.id == id);
    emit(state.copyWith(selectedUnit: unit));
  }

  void setPriority(TaskPriority priority) {
    emit(state.copyWith(priority: priority));
  }

  void setScheduledStart(DateTime dt) {
    emit(state.copyWith(scheduledStart: dt));
  }

  void setScheduledEnd(DateTime dt) {
    emit(state.copyWith(scheduledEnd: dt));
  }

  void setNotes(String text) {
    emit(state.copyWith(notes: text));
  }

  void reset() {
    emit(const AssignTaskState());
    loadFormData();
  }

  Future<void> submit() async {
    if (!state.isFormValid) return;

    emit(state.copyWith(status: AssignTaskStatus.submitting));
    try {
      final user = await userService.getUser();
      final userId = user?.id ?? '';
      final input = TaskAssignmentInput(
        flightId: state.selectedFlight!.id,
        serviceTypeId: state.selectedServiceType!.id,
        unitId: state.selectedUnit!.id,
        priority: state.priority,
        scheduledStart: state.scheduledStart!,
        scheduledEnd: state.scheduledEnd!,
        notes: state.notes?.isEmpty == true ? null : state.notes,
      );
      await repo.assignTask(input, userId);
      emit(state.copyWith(status: AssignTaskStatus.success));
    } on AppError catch (e) {
      emit(state.copyWith(status: AssignTaskStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
        status: AssignTaskStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }
}
