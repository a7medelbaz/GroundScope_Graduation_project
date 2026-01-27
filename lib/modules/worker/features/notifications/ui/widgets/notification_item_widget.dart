import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/modules/worker/features/notifications/data/models/notification_model.dart';
import 'package:ground_scope/modules/worker/features/reports/ui/screens/report_details_screen.dart';
import 'package:ground_scope/modules/worker/features/reports/data/models/report_model.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItemWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: 8.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconContainer(notification.type),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.font16WhiteBold.copyWith(
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        notification.time,
                        style: AppTextStyles.font12GreyRegular.copyWith(
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  notification.description,
                  style: AppTextStyles.font14GreyRegular,
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () {
                    if (notification.type == NotificationType.report) {
                      // Create a mock report for navigation
                      final mockReport = ReportModel(
                        id: notification.id,
                        flight: 'BA2490',
                        task: 'A380 Pushback',
                        stand: 'C34',
                        eta: '13:00 - 13:15',
                        date: '27-04-2024',
                        taskName: notification.title,
                        description: notification.description,
                        time: notification.time,
                      );
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              ReportDetailsScreen(report: mockReport),
                          opaque: true,
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            final tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    } else if (notification.type == NotificationType.task) {
                      // Show task details dialog or navigate when TaskDetailsScreen is available
                      _showTaskDetailsDialog(context);
                    } else {
                      // Show info details dialog
                      _showInfoDetailsDialog(context);
                    }
                  },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.buttonBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        notification.type == NotificationType.task
                            ? 'View Task'
                            : notification.type == NotificationType.report
                                ? 'View Report'
                                : 'View Details',
                        style: AppTextStyles.font14BlueSemiBold.copyWith(
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(NotificationType type) {
    Color backgroundColor;
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.task:
        backgroundColor = AppColors.buttonBlue.withValues(alpha: 0.1);
        iconData = Icons.assignment_turned_in;
        iconColor = AppColors.lightBlue;
        break;
      case NotificationType.report:
        backgroundColor = AppColors.warningYellowIcon.withValues(alpha: 0.1);
        iconData = Icons.warning_amber_rounded;
        iconColor = AppColors.warningYellowIcon;
        break;
      case NotificationType.info:
        backgroundColor = AppColors.buttonBlue.withValues(alpha: 0.1);
        iconData = Icons.info_outline;
        iconColor = AppColors.lightBlue;
        break;
    }

    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(iconData, color: iconColor, size: 24.sp),
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBlue,
          title: Text(
            notification.title,
            style: AppTextStyles.font18WhiteBold,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.description,
                style: AppTextStyles.font14WhiteRegular,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.greySecondary, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    notification.time,
                    style: AppTextStyles.font12GreyRegular,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTextStyles.font14BlueSemiBold,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkBlue,
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.lightBlue, size: 24.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  notification.title,
                  style: AppTextStyles.font18WhiteBold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.description,
                style: AppTextStyles.font14WhiteRegular,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.greySecondary, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    notification.time,
                    style: AppTextStyles.font12GreyRegular,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTextStyles.font14BlueSemiBold,
              ),
            ),
          ],
        );
      },
    );
  }
}

