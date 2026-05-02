import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_font_weight.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/utils/task_ui_helpers.dart';

// ─── Status Style Model ───────────────────────────────────────────────────────

class _StatusStyle {
  const _StatusStyle({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

_StatusStyle _statusStyle(TaskStatus status) => switch (status) {
  TaskStatus.pending    => const _StatusStyle(icon: Icons.schedule_rounded,        label: 'PENDING'),
  TaskStatus.assigned   => const _StatusStyle(icon: Icons.assignment_ind_rounded,  label: 'ASSIGNED'),
  TaskStatus.inProgress => const _StatusStyle(icon: Icons.play_circle_rounded,     label: 'IN PROGRESS'),
  TaskStatus.paused     => const _StatusStyle(icon: Icons.pause_circle_rounded,    label: 'PAUSED'),
  TaskStatus.completed  => const _StatusStyle(icon: Icons.check_circle_rounded,    label: 'COMPLETED'),
  TaskStatus.cancelled  => const _StatusStyle(icon: Icons.cancel_rounded,          label: 'CANCELLED'),
};

// ─── Main Tile ────────────────────────────────────────────────────────────────

class AddReportTaskTile extends StatelessWidget {
  const AddReportTaskTile({super.key, required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final status = task.status ?? TaskStatus.pending;
    final style = _statusStyle(status);
    final color = TaskUiHelpers.statusColor(status, context);

    return Container(
      decoration: BoxDecoration(
        color: customColors.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rr(16)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent bar ───────────────────────────────────────────
              Container(
                width: rw(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color, color.withValues(alpha: 0.3)],
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(14),
                    vertical: rh(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top row: title + badge ──────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.flightNumber ?? task.flightId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.font14SemiBold.copyWith(
                                color: customColors.textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          horizontalSpacing(10),
                          _StatusBadge(style: style, color: color),
                        ],
                      ),

                      verticalSpacing(6),

                      // ── Service type ────────────────────────────────────
                      Row(
                        children: [
                          Text(
                            'SERVICE',
                            style: AppTextStyles.font12Light.copyWith(
                              color: color.withValues(alpha: 0.8),
                              fontSize: rf(10),
                              fontWeight: AppFontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          horizontalSpacing(6),
                          Expanded(
                            child: Text(
                              task.serviceTypeName ?? '—',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.font12Light.copyWith(
                                color: customColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      verticalSpacing(6),

                      // ── Bottom metadata row ─────────────────────────────
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: rr(11),
                            color: customColors.textHint,
                          ),
                          horizontalSpacing(3),
                          Text(
                            'Stand ${task.standCode ?? '—'}',
                            style: AppTextStyles.font12Light.copyWith(
                              color: customColors.textHint,
                            ),
                          ),

                          horizontalSpacing(12),

                          Icon(
                            Icons.access_time_rounded,
                            size: rr(11),
                            color: customColors.textHint,
                          ),
                          horizontalSpacing(3),
                          Text(
                            task.scheduledTimeRange,
                            style: AppTextStyles.font12Light.copyWith(
                              color: customColors.textHint,
                            ),
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
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.style, required this.color});

  final _StatusStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: rr(11), color: color),
          horizontalSpacing(4),
          Text(
            style.label,
            style: AppTextStyles.font12SemiBold.copyWith(
              color: color,
              fontSize: rf(10),
              fontWeight: AppFontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
