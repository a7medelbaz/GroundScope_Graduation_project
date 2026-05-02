import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

// ─── Status Style Model ───────────────────────────────────────────────────────

class _StatusStyle {
  const _StatusStyle({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;
}

// ─── Main Tile ────────────────────────────────────────────────────────────────

class AddReportTaskTile extends StatelessWidget {
  const AddReportTaskTile({super.key, required this.task});

  final TaskModel task;

  _StatusStyle _getStatusStyle(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => const _StatusStyle(
        color: Color(0xFFF59E0B),
        icon: Icons.schedule_rounded,
        label: 'PENDING',
      ),
      TaskStatus.assigned => const _StatusStyle(
        color: Color(0xFF6366F1),
        icon: Icons.assignment_ind_rounded,
        label: 'ASSIGNED',
      ),
      TaskStatus.inProgress => const _StatusStyle(
        color: Color(0xFF3B82F6),
        icon: Icons.play_circle_rounded,
        label: 'IN PROGRESS',
      ),
      TaskStatus.paused => const _StatusStyle(
        color: Color(0xFFF97316),
        icon: Icons.pause_circle_rounded,
        label: 'PAUSED',
      ),
      TaskStatus.completed => const _StatusStyle(
        color: Color(0xFF22C55E),
        icon: Icons.check_circle_rounded,
        label: 'COMPLETED',
      ),
      TaskStatus.cancelled => const _StatusStyle(
        color: Color(0xFFEF4444),
        icon: Icons.cancel_rounded,
        label: 'CANCELLED',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final status = task.status ?? TaskStatus.pending;
    final style = _getStatusStyle(status);

    return Container(
      decoration: BoxDecoration(
        color: customColors.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(
          color: style.color.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: style.color.withValues(alpha: 0.06),
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
                    colors: [style.color, style.color.withValues(alpha: 0.3)],
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
                          _StatusBadge(style: style),
                        ],
                      ),

                      verticalSpacing(6),

                      // ── Service type ────────────────────────────────────
                      Row(
                        children: [
                          Text(
                            'SERVICE',
                            style: AppTextStyles.font12Light.copyWith(
                              color: style.color.withValues(alpha: 0.8),
                              fontSize: rr(10),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          horizontalSpacing(6),
                          // Text(
                          //   task.serviceTypeIcon ?? '🔧',
                          //   style: AppTextStyles.font12Light,
                          // ),
                          // horizontalSpacing(4),
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
                          // Stand
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

                          // Time
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
  const _StatusBadge({required this.style});

  final _StatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(4)),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: style.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: rr(11), color: style.color),
          horizontalSpacing(4),
          Text(
            style.label,
            style: AppTextStyles.font12SemiBold.copyWith(
              color: style.color,
              fontSize: rr(10),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
