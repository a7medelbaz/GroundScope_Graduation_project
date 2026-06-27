import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/notifications/data/models/notification_model.dart';
import 'package:ground_scope/core/notifications/service/notification_sender.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/remote/user_remote_ds.dart';
import 'package:ground_scope/core/shared/data/repo/report_repo.dart';
import 'package:ground_scope/core/shared/data/repo/task_repo.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../core/shared/data/models/report_model.dart';
import '../../../../../../core/shared/data/models/task_model.dart';

part 'add_report_state.dart';

class AddReportCubit extends Cubit<AddReportState> {
  AddReportCubit({
    required this.reportRepo,
    required this.userService,
    required this.taskRepo,
    required this.userRemoteDs,
  }) : super(const AddReportState());

  final ReportRepo reportRepo;
  final TaskRepo taskRepo;
  final UserService userService;
  final UserRemoteDs userRemoteDs;

  final _picker = ImagePicker();

  void preSelectTask(TaskModel task) {
    emit(
      state.copyWith(
        selectedTaskId: task.id,
        selectedFlightId: task.flightId,
        selectedTaskLabel:
            '${task.flightNumber ?? task.flightId} · ${task.serviceTypeName ?? ''}',
      ),
    );
  }

  Future<void> fetchTasks() async {
    emit(state.copyWith(status: AddReportStatus.loading, clearError: true));
    try {
      final user = await userService.getUser();
      if (user == null || user.unitId == null) {
        emit(state.copyWith(status: AddReportStatus.success, tasks: []));
        return;
      }
      final tasks = await taskRepo.fetchWorkerTasks(unitId: user.unitId!);
      emit(state.copyWith(status: AddReportStatus.success, tasks: tasks));
    } on AppError catch (e) {
      emit(state.copyWith(status: AddReportStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
          status: AddReportStatus.failure, error: AppError.unknown()));
    }
  }

  void selectTask(TaskModel task) {
    emit(state.copyWith(
      selectedTaskId: task.id,
      selectedFlightId: task.flightId,
      selectedTaskLabel:
          '${task.flightNumber ?? task.flightId} · ${task.serviceTypeName ?? ''}',
    ));
  }

  void clearTask() {
    emit(AddReportState(type: state.type, severity: state.severity));
  }

  void selectType(ReportType type) => emit(state.copyWith(type: type));

  void selectSeverity(ReportSeverity severity) =>
      emit(state.copyWith(severity: severity));

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1920,
    );
    if (picked == null) return;
    emit(state.copyWith(imageFile: File(picked.path)));
  }

  void removeImage() => emit(state.copyWith(clearImage: true));

  Future<void> submit({required String description}) async {
    if (description.trim().isEmpty) {
      emit(state.copyWith(
        status: AddReportStatus.failure,
        error: AppError.unknown('Description cannot be empty.'),
      ));
      return;
    }

    emit(state.copyWith(status: AddReportStatus.loading, clearError: true));

    try {
      final user = await userService.getUser();
      if (user == null) throw AppError.unknown();

      final supervisorIds = await _findSupervisors(user.serviceTypeId);

      final report = await reportRepo.submitReport(
        reportedBy: user.id,
        taskId: state.selectedTaskId,
        flightId: state.selectedFlightId,
        type: state.type,
        description: description.trim(),
        severity: state.severity,
        direction: ReportDirection.workerToSupervisor,
        recipientUserIds: supervisorIds,
        imageFile: state.imageFile,
      );

      for (final supId in supervisorIds) {
        NotificationSender.send(
          userId: supId,
          title: 'New Report',
          body: '${user.fullName} submitted a ${state.type.label} report',
          type: NotificationType.report,
          referenceId: report.id,
          referenceType: 'report',
        );
      }

      emit(state.copyWith(status: AddReportStatus.submitted));
    } on AppError catch (e) {
      emit(state.copyWith(status: AddReportStatus.failure, error: e));
    } catch (_) {
      emit(state.copyWith(
          status: AddReportStatus.failure, error: AppError.unknown()));
    }
  }

  Future<List<String>> _findSupervisors(String? serviceTypeId) async {
    if (serviceTypeId == null) return [];
    try {
      return await userRemoteDs.fetchSupervisorsByServiceType(serviceTypeId);
    } catch (_) {
      return [];
    }
  }

  void resetForm() => emit(const AddReportState());
}
