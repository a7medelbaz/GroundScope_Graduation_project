import 'package:flutter/material.dart';

import '../../../../../../core/auth/data/models/user_date.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.userModel});
  final UserModel userModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary200,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(rr(24)),
          bottomRight: Radius.circular(rr(24)),
        ),
      ),
      padding: EdgeInsets.only(
        left: rw(12),
        right: rw(12),
        top: rh(50),
        bottom: rh(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          horizontalSpacing(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userModel.fullName,
                style: AppTextStyles.font22ExtraBold.copyWith(
                  color: AppColors.white,
                ),
              ),
              verticalSpacing(4),
              Text(
                userModel.role,
                style: AppTextStyles.font14Light.copyWith(
                  color: AppColors.grey100,
                ),
              ),
              verticalSpacing(24),
              Row(
                children: [
                  CircleAvatar(
                    radius: rr(8),
                    backgroundColor: AppColors.green300,
                  ),
                  horizontalSpacing(8),
                  Text(
                    '07:00-15:00',
                    style: AppTextStyles.font14Light.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          CircleAvatar(
            radius: rr(24),
            backgroundColor: AppColors.primary100,
            child: const Icon(Icons.notifications, color: Colors.white),
          ),
          horizontalSpacing(8),
        ],
      ),
    );
  }
}
