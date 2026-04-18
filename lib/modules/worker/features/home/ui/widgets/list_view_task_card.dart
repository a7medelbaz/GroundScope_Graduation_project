import 'package:flutter/material.dart';

import '../../../../../../core/shared/data/models/task_model.dart';
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

  String get _timeRange {
    final start =
        '${task.scheduledStart.hour.toString().padLeft(2, '0')}:${task.scheduledStart.minute.toString().padLeft(2, '0')}';
    final end =
        '${task.scheduledEnd.hour.toString().padLeft(2, '0')}:${task.scheduledEnd.minute.toString().padLeft(2, '0')}';
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = TaskUiHelpers.statusColor(task.status!, context);
    final priorityColor = TaskUiHelpers.priorityColor(task.priority);
    final cc = context.customColors;
    final bool isInProgress = task.status == TaskStatus.inProgress;

    return Padding(
      padding: EdgeInsets.only(bottom: rh(12)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline Indicator
            SizedBox(
              width: rw(40),
              child: Column(
                children: [
                  Container(
                    width: rw(40),
                    height: rw(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.12),
                      border: Border.all(
                        color: statusColor,
                        width: isInProgress ? 2.5 : 1.8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.font14ExtraBold.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: EdgeInsets.symmetric(vertical: rh(6)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              statusColor.withValues(alpha: 0.6),
                              statusColor.withValues(alpha: 0.08),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            horizontalSpacing(12),

            // Main Card
            Expanded(
              child: Container(
                padding: EdgeInsets.all(rw(16)),
                decoration: BoxDecoration(
                  color: cc.surface,
                  borderRadius: BorderRadius.circular(rr(16)),
                  border: Border.all(
                    color: isInProgress
                        ? statusColor.withValues(alpha: 0.4)
                        : cc.border.withValues(alpha: 0.6),
                    width: isInProgress ? 1.8 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Service + Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Icon
                        Container(
                          width: rw(46),
                          height: rw(46),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(rr(12)),
                          ),
                          child: Icon(
                            _serviceIcon,
                            color: statusColor,
                            size: rf(22),
                          ),
                        ),

                        horizontalSpacing(14),

                        // Service Name + Flight Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.flightNumber ?? '—',
                                style: AppTextStyles.font18SemiBold.copyWith(
                                  color: cc.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              verticalSpacing(4),

                              // Flight + Stand
                              if (task.flightNumber != null ||
                                  task.standCode != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.flight_rounded,
                                      size: rf(13),
                                      color: cc.textHint,
                                    ),
                                    horizontalSpacing(4),
                                    Text(
                                      task.standCode ?? '—',
                                      style: AppTextStyles.font12Light.copyWith(
                                        color: cc.textSecondary,
                                      ),
                                    ),
                                    if (task.standCode != null) ...[
                                      Text(
                                        '  •  Stand ${task.standCode}',
                                        style: AppTextStyles.font12Light
                                            .copyWith(color: cc.textSecondary),
                                      ),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // Status Badge
                        TaskStatusBadge(
                          label: task.status!.label,
                          color: statusColor,
                        ),
                      ],
                    ),

                    verticalSpacing(14),
                    Divider(color: cc.divider, thickness: 1, height: 1),

                    verticalSpacing(12),

                    // Time + Duration + Priority Row
                    Row(
                      children: [
                        // Time Range
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: rf(15),
                                color: cc.textHint,
                              ),
                              horizontalSpacing(6),
                              Text(
                                _timeRange,
                                style: AppTextStyles.font14SemiBold.copyWith(
                                  color: cc.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Duration Pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: rw(9),
                            vertical: rh(3),
                          ),
                          decoration: BoxDecoration(
                            color: cc.surfaceVariant,
                            borderRadius: BorderRadius.circular(rr(8)),
                          ),
                          child: Text(
                            '${task.durationMinutes} min',
                            style: AppTextStyles.font12Light.copyWith(
                              color: cc.textHint,
                            ),
                          ),
                        ),

                        horizontalSpacing(16),

                        // Priority
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: rw(8),
                              height: rw(8),
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            horizontalSpacing(5),
                            Text(
                              task.priority.label,
                              style: AppTextStyles.font12Light.copyWith(
                                color: priorityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Progress Bar (only for active tasks)
                    if (task.status == TaskStatus.inProgress ||
                        task.status == TaskStatus.paused ||
                        task.status == TaskStatus.completed) ...[
                      verticalSpacing(14),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(rr(6)),
                              child: LinearProgressIndicator(
                                value: task.progress,
                                minHeight: rh(6),
                                backgroundColor: statusColor.withValues(
                                  alpha: 0.15,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  statusColor,
                                ),
                              ),
                            ),
                          ),
                          horizontalSpacing(12),
                          // Text(
                          //   task > 0
                          //       ? '${task.checklistDone}/${task.checklistTotal}'
                          //       : '${(task.progress * 100).toInt()}%',
                          //   style: AppTextStyles.font12Light.copyWith(
                          //     color: statusColor,
                          //   ),
                          // ),
                        ],
                      ),
                    ],

                    // Notes (if any)
                    if (task.notes != null &&
                        task.notes!.trim().isNotEmpty) ...[
                      verticalSpacing(12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: rf(14),
                            color: cc.textHint,
                          ),
                          horizontalSpacing(6),
                          Expanded(
                            child: Text(
                              task.notes!.trim(),
                              style: AppTextStyles.font12Light.copyWith(
                                color: cc.textHint,
                              ),
                              maxLines: 2,
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
