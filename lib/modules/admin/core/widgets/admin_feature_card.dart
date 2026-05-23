import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AdminFeatureCardData {
  const AdminFeatureCardData({
    required this.title,
    required this.icon,
    this.route,
    this.isAvailable = true,
  });

  final String title;
  final IconData icon;
  final String? route;
  final bool isAvailable;
}

class AdminFeatureCard extends StatelessWidget {
  const AdminFeatureCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  final AdminFeatureCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: data.isAvailable ? 1.0 : 0.5,
      child: Material(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(rr(16)),
          child: Container(
            padding: EdgeInsets.all(rw(16)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(rr(16)),
              border: Border.all(color: context.customColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  data.icon,
                  size: rw(32),
                  color: context.customColors.iconPrimary,
                ),
                verticalSpacing(8),
                Text(
                  data.title.tr(),
                  style: AppTextStyles.font14SemiBold.copyWith(
                    color: context.customColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
