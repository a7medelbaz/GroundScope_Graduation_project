import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/auth/data/models/user_date.dart';
import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.userModel});
  final UserModel userModel;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveWidth(12),
        vertical: responsiveHeight(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: responsiveWidth(55),
            height: responsiveHeight(55),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.customColors.background,
                width: 3,
              ),
              color: context.customColors.divider,
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: userModel.imageUrl,
                fit: BoxFit.cover,
                placeholder: (final context, final url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.customColors.accentBlue,
                  ),
                ),
                errorWidget: (final context, final url, final error) => Icon(
                  Icons.person,
                  color: context.customColors.textPrimary,
                  size: responsiveFontSize(60),
                ),
              ),
            ),
          ),
          horizontalSpacing(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userModel.firstName, style: AppTextStyles.font18Bold),
              Text(
                userModel.position,
                style: AppTextStyles.font14Regular.copyWith(
                  color: context.customColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '07:00-15:00',
            style: AppTextStyles.font14Regular.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
          horizontalSpacing(8),
          CircleAvatar(
            radius: responsiveRadius(8),
            backgroundColor: AppColors.green100,
          ),
        ],
      ),
    );
  }
}
