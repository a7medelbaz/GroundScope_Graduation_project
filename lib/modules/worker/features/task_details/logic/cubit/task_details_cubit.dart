import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/error/models/app_error.dart';
import 'package:ground_scope/core/error/types/error_handler.dart';
import 'package:ground_scope/core/service/secure_storage.dart';
import 'package:ground_scope/core/shared/data/models/task_check_list_model.dart';
import 'package:ground_scope/core/shared/data/repo/task_repo.dart';
import 'package:ground_scope/core/utils/app_constants.dart';
import 'package:ground_scope/modules/worker/features/task_details/data/repo/task_details_repo.dart';

part 'task_details_state.dart';

class TaskDetailsCubit extends Cubit<TaskDetailsState> {
  TaskDetailsCubit({required this.taskDetailsRepo, required this.taskRepo})
    : super(const TaskDetailsState());
  final TaskDetailsRepo taskDetailsRepo;
  final TaskRepo taskRepo;

  Future<UserModel?> _getUser() async {
    final jsonString = await getIt<SecureStorage>().read(
      key: AppConstants.userDataKey,
    );

    if (jsonString == null) {
      print("❌ ERROR: No data found in Secure Storage. User is not logged in.");
      return null;
    }

    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return UserModel.fromJson(map);
    } catch (e) {
      // This print is the most important one!
      print("❌ MODEL PARSING FAILED: $e");
    }
    return null;
  }

  Future<void> fetchTaskCheckList({required String taskId}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final checkList = await taskRepo.getTaskCheckList(taskId: taskId);

      emit(state.copyWith(checklist: checkList, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e is AppError ? e : ErrorHandler.handle(e),
        ),
      );
    }
  }

  Future<void> updateChecklistItem({
    required String itemId,
    required bool isChecked,
  }) async {
    final currentList = state.checklist;

    /// ✅ Optimistic Update
    final updatedList = currentList.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isChecked: isChecked);
      }
      return item;
    }).toList();

    emit(state.copyWith(checklist: updatedList));

    try {
      final user = await _getUser();

      if (user == null) {
        throw AppError.unauthorized('Please log in again.');
      }

      await taskDetailsRepo.updateChecklistItem(
        itemId: itemId,
        isChecked: isChecked,
        userId: user.id,
      );
    } catch (e) {
      /// ❗ Rollback لو فشل
      emit(state.copyWith(checklist: currentList));

      emit(state.copyWith(error: e is AppError ? e : ErrorHandler.handle(e)));
    }
  }
}
