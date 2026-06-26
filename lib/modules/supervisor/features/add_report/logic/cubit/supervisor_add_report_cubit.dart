import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/error/handlers/supabase_error_handler.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repo/supervisor_add_report_repo.dart';

part 'supervisor_add_report_state.dart';

class SupervisorAddReportCubit extends Cubit<SupervisorAddReportState> {
  SupervisorAddReportCubit({
    required SupervisorAddReportRepo repo,
    required UserService userService,
  })  : _repo = repo,
        _userService = userService,
        super(const SupervisorAddReportState());

  final SupervisorAddReportRepo _repo;
  final UserService _userService;
  final _picker = ImagePicker();

  void selectTarget(String target) => emit(state.copyWith(reportedTo: target));

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
        status: SupervisorAddReportStatus.failure,
        error: AppError.unknown('Description cannot be empty.'),
      ));
      return;
    }

    emit(state.copyWith(
      status: SupervisorAddReportStatus.loading,
      clearError: true,
    ));

    try {
      final user = await _userService.getUser();
      if (user == null) throw AppError.unknown();

      await _repo.submitReport(
        supervisorId: user.id,
        reportedTo: state.reportedTo,
        type: state.type,
        severity: state.severity,
        description: description.trim(),
        imageFile: state.imageFile,
      );

      emit(state.copyWith(status: SupervisorAddReportStatus.submitted));
    } on AppError catch (e) {
      emit(state.copyWith(
        status: SupervisorAddReportStatus.failure,
        error: e,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupervisorAddReportStatus.failure,
        error: SupabaseErrorHandler.handle(e),
      ));
    }
  }

  void resetForm() => emit(const SupervisorAddReportState());
}
