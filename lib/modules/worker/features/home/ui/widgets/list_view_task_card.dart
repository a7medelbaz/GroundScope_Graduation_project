import 'package:flutter/material.dart';
import '../../../../../../core/data/models/task_model.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../../../../../core/utils/task_ui_helpers.dart';

import 'task_status_badge.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.index,
    this.isLast = false,
  });

  final TaskModel task;
  final int index;
  final bool isLast;

  IconData get _serviceIcon => switch (task.serviceTypeName?.toLowerCase()) {
    'fuel' => Icons.local_gas_station_rounded,
    'cleaning' => Icons.cleaning_services_rounded,
    'catering' => Icons.restaurant_rounded,
    'maintenance' => Icons.build_rounded,
    'baggage' => Icons.luggage_rounded,
    _ => Icons.miscellaneous_services_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = TaskUiHelpers.statusColor(task.status, context);
    final priorityColor = TaskUiHelpers.priorityColor(task.priority);

    final cc = context.customColors;

    return Padding(
      padding: EdgeInsets.only(bottom: rh(12)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline column
            SizedBox(
              width: rw(36),
              child: Column(
                children: [
                  Container(
                    width: rw(36),
                    height: rw(36),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.12),
                      border: Border.all(color: statusColor, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.font12ExtraBold.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        margin: EdgeInsets.symmetric(vertical: rh(4)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              statusColor.withValues(alpha: 0.5),
                              statusColor.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            horizontalSpacing(12),

            // Card body
            Expanded(
              child: Container(
                padding: EdgeInsets.all(rw(14)),
                decoration: BoxDecoration(
                  color: cc.surface,
                  borderRadius: BorderRadius.circular(rr(14)),
                  border: Border.all(
                    color: task.status == TaskStatus.inProgress
                        ? statusColor.withValues(alpha: 0.3)
                        : cc.border.withValues(alpha: 0.5),
                    width: task.status == TaskStatus.inProgress ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: icon + title + status badge
                    Row(
                      children: [
                        Container(
                          width: rw(38),
                          height: rw(38),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(rr(10)),
                          ),
                          child: Icon(
                            _serviceIcon,
                            color: statusColor,
                            size: rf(18),
                          ),
                        ),
                        horizontalSpacing(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.serviceTypeName ?? 'Ground Service',
                                style: AppTextStyles.font16ExtraBold.copyWith(
                                  color: cc.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (task.flightNumber != null) ...[
                                verticalSpacing(2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.flight_rounded,
                                      size: rf(11),
                                      color: cc.textHint,
                                    ),
                                    horizontalSpacing(3),
                                    Text(
                                      task.flightNumber!,
                                      style: AppTextStyles.font12Light.copyWith(
                                        color: cc.textHint,
                                      ),
                                    ),
                                    if (task.standCode != null) ...[
                                      Text(
                                        '  ·  Stand ${task.standCode}',
                                        style: AppTextStyles.font12Light
                                            .copyWith(color: cc.textHint),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        horizontalSpacing(8),
                        TaskStatusBadge(
                          label: task.status.label,
                          color: statusColor,
                        ),
                      ],
                    ),

                    verticalSpacing(12),
                    Container(height: 1, color: cc.divider),
                    verticalSpacing(10),

                    // Bottom row: time + priority
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: rf(13),
                          color: cc.textHint,
                        ),
                        horizontalSpacing(4),
                        Text(
                          task.scheduledTimeRange,
                          style: AppTextStyles.font12SemiBold.copyWith(
                            color: cc.textSecondary,
                          ),
                        ),
                        horizontalSpacing(10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: rw(7),
                            vertical: rh(2),
                          ),
                          decoration: BoxDecoration(
                            color: cc.surfaceVariant,
                            borderRadius: BorderRadius.circular(rr(6)),
                          ),
                          child: Text(
                            '${task.durationMinutes}m',
                            style: AppTextStyles.font12Light.copyWith(
                              color: cc.textHint,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: rw(7),
                          height: rw(7),
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        horizontalSpacing(4),
                        Text(
                          task.priority.label,
                          style: AppTextStyles.font12Light.copyWith(
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),

                    // Progress bar
                    if (task.status == TaskStatus.inProgress ||
                        task.status == TaskStatus.paused ||
                        task.status == TaskStatus.completed) ...[
                      verticalSpacing(10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(rr(4)),
                              child: LinearProgressIndicator(
                                value: task.progress,
                                minHeight: rh(5),
                                backgroundColor: statusColor.withValues(
                                  alpha: 0.12,
                                ),
                                valueColor: AlwaysStoppedAnimation(statusColor),
                              ),
                            ),
                          ),
                          horizontalSpacing(8),
                          Text(
                            task.checklistTotal > 0
                                ? '${task.checklistDone}/${task.checklistTotal}'
                                : '${(task.progress * 100).toInt()}%',
                            style: AppTextStyles.font12SemiBold.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Notes
                    if (task.notes != null && task.notes!.isNotEmpty) ...[
                      verticalSpacing(8),
                      Row(
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: rf(12),
                            color: cc.textHint,
                          ),
                          horizontalSpacing(4),
                          Expanded(
                            child: Text(
                              task.notes!,
                              style: AppTextStyles.font12Light.copyWith(
                                color: cc.textHint,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
