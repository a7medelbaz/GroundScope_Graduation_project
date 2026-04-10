import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';

import '../../../../../../core/auth/data/models/user_date.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.userModel});
  final UserModel userModel;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(12), vertical: rh(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          horizontalSpacing(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userModel.fullName, style: AppTextStyles.font18ExtraBold),
              Text(
                userModel.fullName,
                style: AppTextStyles.font14Light.copyWith(
                  color: context.customColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '07:00-15:00',
            style: AppTextStyles.font14Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          horizontalSpacing(8),
          CircleAvatar(radius: rr(8), backgroundColor: AppColors.green100),
        ],
      ),
    );
  }
}
