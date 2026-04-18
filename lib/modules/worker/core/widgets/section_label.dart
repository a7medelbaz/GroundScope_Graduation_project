import 'package:flutter/material.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions/context_ext.dart';
import '../../../../core/utils/spacing.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.title, required this.color});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: rw(4),
          height: rh(18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(rr(2)),
          ),
        ),
        horizontalSpacing(10),
        Text(
          title,
          style: AppTextStyles.font18ExtraBold.copyWith(
            color: context.customColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
