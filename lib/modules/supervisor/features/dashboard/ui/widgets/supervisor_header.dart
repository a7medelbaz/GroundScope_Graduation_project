import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/widgets/notification_button.dart';

class SupervisorHeader extends StatelessWidget {
  const SupervisorHeader({
    super.key,
    required this.userName,
    this.serviceTypeName,
  });

  final String userName;
  final String? serviceTypeName;

  String get _greetingKey {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning';
    if (hour < 17) return 'good_afternoon';
    return 'good_evening';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + rh(20);

    return Container(
      padding: EdgeInsets.fromLTRB(rw(16), topPadding, rw(16), rh(28)),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary200,
            AppColors.primary300,
            AppColors.primary400,
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greetingKey.tr(),
                  style: AppTextStyles.font14Light.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                verticalSpacing(4),
                Text(
                  userName,
                  style: AppTextStyles.font20ExtraBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
                if (serviceTypeName != null) ...[
                  verticalSpacing(10),
                  _ServiceTypeTag(name: serviceTypeName!),
                ],
              ],
            ),
          ),
          NotificationButton(
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.notificationsScreen),
          ),
        ],
      ),
    );
  }
}

class _ServiceTypeTag extends StatelessWidget {
  const _ServiceTypeTag({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(4)),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        name,
        style: AppTextStyles.font12SemiBold.copyWith(color: AppColors.white),
      ),
    );
  }
}
