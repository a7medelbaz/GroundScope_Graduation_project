// lib/modules/worker/features/task_info/ui/widgets/task_timeline_row.dart

import 'package:flutter/material.dart';

import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../data/model/task_time_line_model.dart';
import '../task_info_screen.dart';

class TaskTimelineRow extends StatelessWidget {
  const TaskTimelineRow({super.key, required this.event, required this.isLast});

  final TaskTimelineModel event;
  final bool isLast;

  bool get _isResume => event.type == EventType.resume;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline spine ──────────────────────────────
          SizedBox(
            width: rw(44),
            child: Column(
              children: [
                Text(
                  TaskInfoScreen.fmt(event.time),
                  style: AppTextStyles.font12SemiBold.copyWith(
                    color: event.color,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpacing(4),
                Container(
                  width: rw(32),
                  height: rw(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: event.color.withValues(alpha: 0.12),
                    border: Border.all(color: event.color, width: 1.5),
                  ),
                  child: Icon(event.icon, color: event.color, size: rf(14)),
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
                            event.color.withValues(alpha: 0.4),
                            event.color.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          horizontalSpacing(12),

          // ── Event card ──────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: rh(isLast ? 0 : 16)),
              child: Container(
                padding: EdgeInsets.all(rw(12)),
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(rr(12)),
                  border: Border.all(color: event.color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Text(
                      event.label,
                      style: AppTextStyles.font14ExtraBold.copyWith(
                        color: cc.textPrimary,
                      ),
                    ),
                    verticalSpacing(3),

                    // Sublabel
                    Text(
                      event.sublabel,
                      style: AppTextStyles.font12Light.copyWith(
                        color: cc.textHint,
                      ),
                    ),
                    verticalSpacing(6),
                    // ── Resume: show paused-at → resumed-at ─
                    if (_isResume && event.secondaryTime != null) ...[
                      Row(
                        children: [
                          // Paused at
                          _TimeChip(
                            label: 'Paused',
                            time: TaskInfoScreen.fmt(event.secondaryTime),
                            color: event.color.withValues(alpha: 0.5),
                          ),
                          horizontalSpacing(6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: rf(11),
                            color: cc.textHint,
                          ),
                          horizontalSpacing(6),
                          // Resumed at
                          _TimeChip(
                            label: 'Resumed',
                            time: TaskInfoScreen.fmt(event.time),
                            color: event.color,
                          ),
                        ],
                      ),
                    ] else ...[
                      // All other events: just the event time
                      Text(
                        TaskInfoScreen.fmt(event.time),
                        style: AppTextStyles.font12Light.copyWith(
                          color: event.color,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Time chip ─────────────────────────────────────────────────

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.time,
    required this.color,
  });

  final String label;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.font12Light.copyWith(
            color: context.customColors.textHint,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        verticalSpacing(1),
        Text(
          time,
          style: AppTextStyles.font12SemiBold.copyWith(
            color: color,
            fontSize: 10,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
