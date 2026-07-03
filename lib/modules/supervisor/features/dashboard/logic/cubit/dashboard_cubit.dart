import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import '../../data/models/service_request_model.dart';
import '../../data/repo/dashboard_repo.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required DashboardRepo dashboardRepo,
    required UserService userService,
  })  : _dashboardRepo = dashboardRepo,
        _userService = userService,
        super(const DashboardState());

  final DashboardRepo _dashboardRepo;
  final UserService _userService;
  StreamSubscription<List<ServiceRequestModel>>? _requestSubscription;

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final user = await _userService.getUser();
      final serviceTypeId = user?.serviceTypeId;

      if (serviceTypeId == null || serviceTypeId.isEmpty) {
        emit(state.copyWith(
          status: DashboardStatus.failure,
          error: AppError.unknown('Supervisor service type not configured.'),
        ));
        return;
      }

      final results = await Future.wait(
        [
          _dashboardRepo.fetchTaskStats(serviceTypeId),
          _dashboardRepo.fetchUnitStats(serviceTypeId),
          _dashboardRepo.fetchOpenReportCount(serviceTypeId),
          _dashboardRepo.fetchPendingServiceRequests(serviceTypeId),
          _dashboardRepo.fetchUnitsPreview(serviceTypeId),
          _dashboardRepo.fetchServiceTypeName(serviceTypeId),
        ],
        eagerError: true,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw AppError.timeout(),
      );

      final taskStats = results[0] as Map<String, int>;
      final unitStats = results[1] as Map<String, int>;
      final openReportCount = results[2] as int;
      final pendingRequests = results[3] as List<ServiceRequestModel>;
      final unitsPreview = results[4] as List<UnitModel>;
      final serviceTypeName = results[5] as String?;

      final activeTaskCount =
          (taskStats['in_progress'] ?? 0) + (taskStats['assigned'] ?? 0);
      final availableUnitCount = unitStats['available'] ?? 0;
      final totalUnitCount = unitStats.values.fold(0, (a, b) => a + b);

      emit(DashboardState(
        status: DashboardStatus.loaded,
        activeTaskCount: activeTaskCount,
        pendingRequestCount: pendingRequests.length,
        availableUnitCount: availableUnitCount,
        totalUnitCount: totalUnitCount,
        openReportCount: openReportCount,
        pendingRequests: pendingRequests,
        unitsPreview: unitsPreview,
        serviceTypeName: serviceTypeName,
      ));

      await _startRealTimeSubscription(serviceTypeId);
    } on AppError catch (e) {
      emit(state.copyWith(status: DashboardStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('DashboardCubit.loadDashboard error: $e\n$st');
      emit(state.copyWith(
          status: DashboardStatus.failure, error: AppError.unknown()));
    }
  }

  Future<void> refresh() => loadDashboard();

  Future<void> _startRealTimeSubscription(String serviceTypeId) async {
    await _requestSubscription?.cancel();
    _requestSubscription = _dashboardRepo
        .watchPendingServiceRequests(serviceTypeId)
        .listen(
      (_) async {
        // The realtime stream cannot carry the flights(*) join, so its rows have
        // flight == null. Use the stream purely as a change signal and re-fetch
        // the joined list so flight details are populated.
        if (state.status != DashboardStatus.loaded) return;
        try {
          final joined =
              await _dashboardRepo.fetchPendingServiceRequests(serviceTypeId);
          emit(state.copyWith(
            pendingRequests: joined,
            pendingRequestCount: joined.length,
          ));
        } catch (e) {
          debugPrint('Dashboard re-fetch after stream event failed: $e');
        }
      },
      onError: (e) => debugPrint('Dashboard real-time error: $e'),
    );
  }

  @override
  Future<void> close() {
    _requestSubscription?.cancel();
    return super.close();
  }

  void onServiceRequestAssigned(String requestId) {
    final updated =
        state.pendingRequests.where((r) => r.id != requestId).toList();
    emit(state.copyWith(
      pendingRequests: updated,
      pendingRequestCount: updated.length,
    ));
  }
}
