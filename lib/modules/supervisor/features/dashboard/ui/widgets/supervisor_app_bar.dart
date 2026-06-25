import 'package:flutter/material.dart';
import '../../../../../../../core/auth/data/models/user_date.dart';
import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/extensions/datetime_ext.dart';
import '../../../../../../../core/utils/spacing.dart';
import '../../../../../../core/router/routes.dart';
import '../../../../../../core/widgets/notification_button.dart';

class SupervisorAppBar extends StatelessWidget {
  const SupervisorAppBar({super.key, required this.user});

  final UserModel user;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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
              // Avatar circle
              Container(
                width: rw(46),
                height: rw(46),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : 'S',
                    style: AppTextStyles.font20ExtraBold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              horizontalSpacing(12),

              // Name + role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: AppTextStyles.font12Light.copyWith(
                        color: AppColors.primary100,
                        letterSpacing: 0.3,
                      ),
                    ),
                    verticalSpacing(2),
                    Text(
                      user.fullName,
                      style: AppTextStyles.font18ExtraBold.copyWith(
                        color: AppColors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        user.role.toUpperCase(),
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: AppColors.primary50,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Notification icon
              NotificationButton(
                onTap: () => Navigator.of(context)
                    .pushNamed(Routes.notificationsScreen),
              ),
            ],
          ),

          verticalSpacing(20),
          Container(height: 1, color: AppColors.white.withValues(alpha: 0.15)),
          verticalSpacing(16),

          // Date row
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AppColors.primary100,
              ),
              horizontalSpacing(6),
              Text(
                DateTime.now().formattedDateTimeWithWeekday,
                style: AppTextStyles.font12Light.copyWith(
                  color: AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
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
              horizontalSpacing(6),
              Text(
                'On Duty',
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
