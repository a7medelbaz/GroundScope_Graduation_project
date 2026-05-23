import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';

class AdminSectionHeader extends StatelessWidget {
  const AdminSectionHeader({
    super.key,
    required this.title,
    this.seeAllLabel,
    this.onSeeAll,
  });

  final String title;
  final String? seeAllLabel;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.font18ExtraBold.copyWith(
            color: context.customColors.textPrimary,
          ),
        ),
        if (seeAllLabel != null && onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              seeAllLabel!,
              style: AppTextStyles.font14SemiBold.copyWith(
                color: context.customColors.info,
              ),
            ),
          ),
      ],
    );
  }
}
