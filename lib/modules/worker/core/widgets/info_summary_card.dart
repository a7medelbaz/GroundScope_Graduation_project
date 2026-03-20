import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/reports/data/models/report_model.dart';

class InfoSummaryTile extends StatelessWidget {
  final ReportModel report;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String buttonText;
  final VoidCallback onTap;

  const InfoSummaryTile({
    super.key,
    this.icon = Icons.warning_amber_rounded,
    this.iconColor = AppColors.amberLight,
    this.iconBackgroundColor = AppColors.yellow300,
    this.buttonText = 'View Details',
    required this.onTap,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: responsiveHeight(12.0),
        horizontal: responsiveWidth(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dynamic Leading Icon
          CircleAvatar(
            radius: responsiveRadius(22),
            backgroundColor: iconBackgroundColor,
            child: Icon(
              icon,
              color: iconColor,
              size: responsiveHeight(24),
            ),
          ),

          horizontalSpacing(16),

          // 2. Middle Content (Flexible to avoid overflow)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: AppTextStyles.font16SemiBold,
                  maxLines: 1, // Ensures it stays on one line
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpacing(4),
                Text(
                  report.description,
                  style: AppTextStyles.font14Regular.copyWith(
                    color: AppColors.grayColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpacing(12),
                // Action Button
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary300.withValues(
                      alpha: 0.3,
                    ),
                    foregroundColor: AppColors.lightBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        responsiveRadius(20),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(16),
                      vertical: responsiveHeight(8),
                    ),
                  ),
                  child: Text(buttonText),
                ),
              ],
            ),
          ),
          horizontalSpacing(8),
          // 3. Trailing Time
          Text(
            _formatTime(report.date),
            style: AppTextStyles.font12Regular.copyWith(
              color: AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for time formatting
  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}
