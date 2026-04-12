import 'package:flutter/material.dart';

import '../../../../../../core/auth/data/models/user_date.dart';
import '../../../../../../core/data/models/unit_model.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/datetime_ext.dart';
import '../../../../../../core/utils/spacing.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.userModel,
    required this.unitModel,
  });
  final UserModel userModel;
  final UnitModel unitModel;

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
              // Avatar + name block
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
                      unitModel.name,
                      style: AppTextStyles.font22ExtraBold.copyWith(
                        color: AppColors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    verticalSpacing(4),
                    // Role chip
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
                        userModel.fullName,
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: AppColors.primary50,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Notification button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: rw(44),
                  height: rw(44),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.white,
                        size: 22,
                      ),
                      // Unread dot
                      Positioned(
                        top: rh(8),
                        right: rw(8),
                        child: Container(
                          width: rw(8),
                          height: rw(8),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary200,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          verticalSpacing(20),
          // Divider line
          Container(height: 1, color: AppColors.white.withValues(alpha: 0.15)),
          verticalSpacing(16),

          // Status row — shift + active indicator
          Row(
            children: [
              // Active shift
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
                    'On Shift',
                    style: AppTextStyles.font12Light.copyWith(
                      color: AppColors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  horizontalSpacing(8),
                  Text(
                    '${unitModel.shiftStartTime != null ? _formatTime(unitModel.shiftStartTime!) : '--:--'} - ${unitModel.shiftEndTime != null ? _formatTime(unitModel.shiftEndTime!) : '--:--'}',
                    style: AppTextStyles.font12SemiBold.copyWith(
                      color: AppColors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Date
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

String _formatTime(String time) {
  final parts = time.split(':');
  if (parts.length >= 2) {
    int hour = int.parse(parts[0]);
    String minute = parts[1];
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour; // Convert 0 to 12
    return '$hour:$minute $period';
  }
  return time;
}
