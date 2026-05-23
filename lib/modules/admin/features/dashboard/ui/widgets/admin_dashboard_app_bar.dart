import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AdminDashboardAppBar extends StatelessWidget {
  const AdminDashboardAppBar({super.key, this.adminName});

  final String? adminName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(20), vertical: rh(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'admin_dashboard'.tr(),
                  style: AppTextStyles.font22ExtraBold.copyWith(
                    color: context.customColors.textPrimary,
                  ),
                ),
                if (adminName != null)
                  Text(
                    '${'welcome_back'.tr()}, $adminName',
                    style: AppTextStyles.font14Light.copyWith(
                      color: context.customColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.notifications_outlined,
            size: rw(24),
            color: context.customColors.iconPrimary,
          ),
          horizontalSpacing(16),
          Icon(
            Icons.person_outline_rounded,
            size: rw(24),
            color: context.customColors.iconPrimary,
          ),
        ],
      ),
    );
  }
}
