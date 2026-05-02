import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/themes/custom_colors.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/add_report/logic/cubit/add_report_cubit.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/widgets/add_report_task_tile.dart';

class TaskSelectorSheet extends StatefulWidget {
  const TaskSelectorSheet({super.key});

  @override
  State<TaskSelectorSheet> createState() => _TaskSelectorSheetState();
}

class _TaskSelectorSheetState extends State<TaskSelectorSheet> {
  @override
  void initState() {
    super.initState();

    /// Fetch tasks once when sheet opens
    context.read<AddReportCubit>().fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Container(
      margin: EdgeInsets.only(top: rh(60)),
      decoration: BoxDecoration(
        color: customColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(rr(24))),
      ),
      child: Column(
        children: [
          _buildHandle(customColors),
          _buildHeader(customColors),

          Divider(height: 1, color: customColors.divider),

          Expanded(
            child: BlocBuilder<AddReportCubit, AddReportState>(
              builder: (context, state) {
                /// 🔄 Loading
                if (state.status == AddReportStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// ❌ Error
                if (state.status == AddReportStatus.failure) {
                  return _buildError(state, customColors);
                }

                final tasks = state.tasks ?? [];

                /// 📭 Empty
                if (tasks.isEmpty) {
                  return _buildEmptyState(customColors);
                }

                /// ✅ Data
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(16),
                    vertical: rh(12),
                  ),
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => verticalSpacing(8),
                  itemBuilder: (_, index) {
                    final task = tasks[index];

                    return GestureDetector(
                      onTap: () {
                        context.read<AddReportCubit>().selectTask(task);
                        Navigator.pop(context);
                      },
                      child: AddReportTaskTile(task: task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- UI PARTS ----------------

  Widget _buildHandle(CustomColors colors) {
    return Column(
      children: [
        verticalSpacing(12),
        Container(
          width: rw(40),
          height: rh(4),
          decoration: BoxDecoration(
            color: colors.divider,
            borderRadius: BorderRadius.circular(rr(2)),
          ),
        ),
        verticalSpacing(16),
      ],
    );
  }

  Widget _buildHeader(CustomColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(20)),
      child: Row(
        children: [
          Text(
            'Select Task',
            style: AppTextStyles.font18SemiBold.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.font14SemiBold.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AddReportState state, CustomColors colors) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(20)),
        child: Text(
          state.error?.messageKey ?? 'Something went wrong',
          style: AppTextStyles.font14Light.copyWith(color: colors.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmptyState(CustomColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: colors.iconSecondary),
          verticalSpacing(12),
          Text(
            'No active tasks found',
            style: AppTextStyles.font14Light.copyWith(
              color: colors.textSecondary,
            ),
          ),
          verticalSpacing(4),
          Text(
            'Please check back later',
            style: AppTextStyles.font12Light.copyWith(color: colors.textHint),
          ),
        ],
      ),
    );
  }
}
