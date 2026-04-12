import 'package:flutter/material.dart';

import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../data/models/task_time_line_model.dart';
import '../task_info_screen.dart';

class TaskTimelineRow extends StatelessWidget {
  const TaskTimelineRow({super.key, required this.event, required this.isLast});
  final TaskTimelineModel event;
  final bool isLast;

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
                // Time label
                Text(
                  TaskInfoScreen.fmt(event.time),
                  style: AppTextStyles.font12SemiBold.copyWith(
                    color: event.color,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpacing(4),
                // Dot
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
                // Line
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
                    Text(
                      event.label,
                      style: AppTextStyles.font14ExtraBold.copyWith(
                        color: cc.textPrimary,
                      ),
                    ),
                    verticalSpacing(3),
                    Text(
                      event.sublabel,
                      style: AppTextStyles.font12Light.copyWith(
                        color: cc.textHint,
                      ),
                    ),
                    verticalSpacing(4),
                    Text(
                      TaskInfoScreen.fmt(event.time),
                      style: AppTextStyles.font12Light.copyWith(
                        color: event.color,
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
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
