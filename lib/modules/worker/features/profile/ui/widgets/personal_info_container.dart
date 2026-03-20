import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/info_tile.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';

class PersonalInfoContainer extends StatelessWidget {
  const PersonalInfoContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(responsiveWidth(14)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(responsiveRadius(16)),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.grey100,
          width: 1,
        ),
      ),
      child: Column(children: [_buildPersonalInfoSection(context)]),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'worker_profile.personal_information.personal_information'
              .tr(),
          style: AppTextStyles.font18SemiBold,
        ),
        verticalSpacing(15),
        InfoTile(
          label: 'worker_profile.personal_information.full_name'.tr(),
          value: 'Mohamed Osman Mohamed',
          icon: Icons.person_outline_rounded,
        ),
        InfoTile(
          label: 'worker_profile.personal_information.email'.tr(),
          value: 'mohamed.osman@example.com',
          icon: Icons.email_outlined,
          hasCopy: true,
        ),
        InfoTile(
          label: 'worker_profile.personal_information.worker_id'.tr(),
          value: '202100464',
          icon: Icons.badge_outlined,
          hasCopy: true,
        ),
        InfoTile(
          label: 'worker_profile.unit'
              .tr(), // Changed from Faculty/College
          value: 'Aviation - Ground Handling',
          icon: Icons.engineering_outlined,
        ),
        InfoTile(
          label: 'worker_profile.personal_information.phone_number'
              .tr(),
          value: '+20 123456789',
          icon: Icons.phone_android_outlined,
        ),
        InfoTile(
          label: 'worker_profile.personal_information.national_id'
              .tr(),
          value: '2990101XXXXXXX',
          icon: Icons.credit_card_outlined,
          hasCopy: true,
        ),
      ],
    );
  }
}
