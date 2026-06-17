import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/utils/task_ui_helpers.dart';

class SupervisorTaskCard extends StatelessWidget {
  const SupervisorTaskCard({super.key, required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final status = task.status ?? TaskStatus.pending;
    final statusColor = TaskUiHelpers.statusColor(status, context);
    final priorityColor = TaskUiHelpers.priorityColor(task.priority);

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: rh(12)),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: BorderRadius.circular(rr(16)),
          border: Border.all(color: cc.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(rr(16)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(
                width: rw(4),
                color: statusColor,
              ),
              // Body
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(rw(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: title + status badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.serviceTypeName ??
                                  task.flight?.flightNumber ??
                                  'task'.tr(),
                              style: AppTextStyles.font16SemiBold
                                  .copyWith(color: cc.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          horizontalSpacing(8),
                          _Badge(
                            label: status.label,
                            color: statusColor,
                          ),
                        ],
                      ),
                      verticalSpacing(4),
                      // Row 2: unit · flight · stand
                      Text(
                        _buildSubtitle(),
                        style: AppTextStyles.font14Light
                            .copyWith(color: cc.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpacing(6),
                      // Row 3: time range + priority badge
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: rf(12),
                            color: cc.textHint,
                          ),
                          horizontalSpacing(4),
                          Expanded(
                            child: Text(
                              '${task.scheduledStart.formattedTime} – ${task.scheduledEnd.formattedTime}',
                              style: AppTextStyles.font12Light
                                  .copyWith(color: cc.textHint),
                            ),
                          ),
                          _Badge(
                            label: task.priority.label,
                            color: priorityColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[
      if (task.unit?.name != null) task.unit!.name,
      if (task.flight?.flightNumber != null) task.flight!.flightNumber,
      if (task.flight?.stand?.code != null) task.flight!.stand!.code,
    ];
    return parts.isEmpty ? '-' : parts.join(' · ');
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(8)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }
}
