import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import '../../data/models/report_model.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;

  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
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
          // Leading Icon
          CircleAvatar(
            radius: responsiveRadius(20), // Added responsive radius
            backgroundColor: AppColors.yellow300,
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.amberLight,
              size: responsiveHeight(24), // Responsive icon size
            ),
          ),
          horizontalSpacing(16), // Using your custom helper
          // Middle Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: AppTextStyles.font16SemiBold,
                ),
                verticalSpacing(4), // Using your custom helper
                Text(
                  report.description,
                  style: AppTextStyles.font14Regular.copyWith(
                    color: AppColors.grayColor,
                  ),
                ),
                verticalSpacing(12),
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
                        responsiveRadius(20), // Responsive radius
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveWidth(16),
                      vertical: responsiveHeight(8),
                    ),
                  ),
                  child: const Text('View Report'),
                ),
              ],
            ),
          ),

          // Trailing Time
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

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}
