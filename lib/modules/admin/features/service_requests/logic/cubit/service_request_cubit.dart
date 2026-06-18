import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/shared/data/models/service_request_model.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/shared/data/repo/service_request_repo.dart';
import 'package:ground_scope/core/shared/data/repo/service_type_repo.dart';

part 'service_request_state.dart';

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  ServiceRequestCubit(
    this._requestRepo,
    this._serviceTypeRepo,
    this._userService,
  ) : super(const ServiceRequestState());

  final ServiceRequestRepo _requestRepo;
  final ServiceTypeRepo _serviceTypeRepo;
  final UserService _userService;

  Future<void> init(FlightModel flight) async {
    emit(state.copyWith(
      status: SrLoadStatus.loading,
      flight: flight,
    ));
    try {
      final results = await Future.wait([
        _requestRepo.fetchForFlight(flight.id),
        _serviceTypeRepo.fetchAll(isActive: true),
      ]);

      emit(state.copyWith(
        status:          SrLoadStatus.success,
        existingRequests: results[0] as List<AdminServiceRequestModel>,
        allServiceTypes:  results[1] as List<ServiceTypeModel>,
      ));
    } on AppError catch (e) {
      emit(state.copyWith(status: SrLoadStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('ServiceRequestCubit.init: $e\n$st');
      emit(state.copyWith(
        status: SrLoadStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }

  void toggleServiceType(String serviceTypeId) {
    final selected = Set<String>.from(state.selectedServiceTypeIds);
    if (selected.contains(serviceTypeId)) {
      selected.remove(serviceTypeId);
    } else {
      selected.add(serviceTypeId);
    }
    emit(state.copyWith(selectedServiceTypeIds: selected));
  }

  void onNotesChanged(String notes) {
    emit(state.copyWith(notes: notes));
  }

  Future<void> submitRequests() async {
    if (state.selectedServiceTypeIds.isEmpty) return;
    if (state.flight == null) return;

    emit(state.copyWith(status: SrLoadStatus.submitting));
    try {
      final user = await _userService.getUser();
      final adminId = user?.id ?? '';

      for (final stId in state.selectedServiceTypeIds) {
        await _requestRepo.create(
          flightId:      state.flight!.id,
          serviceTypeId: stId,
          requestedBy:   adminId,
          notes:         state.notes.isEmpty ? null : state.notes,
        );
      }

      final allRequests =
          await _requestRepo.fetchForFlight(state.flight!.id);

      emit(state.copyWith(
        status:                 SrLoadStatus.success,
        existingRequests:       allRequests,
        selectedServiceTypeIds: {},
        notes:                  '',
      ));
    } on AppError catch (e) {
      emit(state.copyWith(status: SrLoadStatus.failure, error: e));
    } catch (e, st) {
      debugPrint('ServiceRequestCubit.submitRequests: $e\n$st');
      emit(state.copyWith(
        status: SrLoadStatus.failure,
        error: AppError.unknown(),
      ));
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _requestRepo.cancel(requestId);
      final updated = await _requestRepo.fetchForFlight(state.flight!.id);
      emit(state.copyWith(existingRequests: updated));
    } on AppError catch (e) {
      emit(state.copyWith(error: e));
    } catch (e, st) {
      debugPrint('ServiceRequestCubit.cancelRequest: $e\n$st');
      emit(state.copyWith(error: AppError.unknown()));
    }
  }
}
