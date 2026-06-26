import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/widgets/notification_button.dart';

class SupervisorDashboardHeader extends StatelessWidget {
  const SupervisorDashboardHeader({
    super.key,
    required this.userName,
    required this.serviceTypeName,
    required this.activeTaskCount,
  });

  final String userName;
  final String serviceTypeName;
  final int activeTaskCount;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr();
    if (hour < 17) return 'good_afternoon'.tr();
    return 'good_evening'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary400,
            AppColors.primary300,
            AppColors.primary200,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: rw(20),
        right: rw(20),
        top: rh(52),
        bottom: rh(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: AppTextStyles.font14Light.copyWith(
                        color: AppColors.primary100,
                        letterSpacing: 0.4,
                      ),
                    ),
                    verticalSpacing(2),
                    Text(
                      userName,
                      style: AppTextStyles.font22ExtraBold.copyWith(
                        color: AppColors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    verticalSpacing(4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(10),
                        vertical: rh(3),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(rr(20)),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        serviceTypeName,
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: AppColors.primary50,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              NotificationButton(
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .pushNamed(Routes.notificationsScreen),
              ),
            ],
          ),
          verticalSpacing(20),
          Container(height: 1, color: AppColors.white.withValues(alpha: 0.15)),
          verticalSpacing(16),
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: rw(8),
                    height: rw(8),
                    decoration: BoxDecoration(
                      color: AppColors.green200,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green200.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  horizontalSpacing(8),
                  Text(
                    '$activeTaskCount ${'active_tasks'.tr()}',
                    style: AppTextStyles.font12Light.copyWith(
                      color: AppColors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                DateTime.now().formattedDateTimeWithWeekday,
                style: AppTextStyles.font12Light.copyWith(
                  color: AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
