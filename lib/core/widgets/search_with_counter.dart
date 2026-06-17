import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_form_.dart';

class SearchWithCounter extends StatelessWidget {
  const SearchWithCounter({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.resultCount,
    this.resultLabel,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final int resultCount;
  final String? resultLabel;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final label = resultLabel ?? 'results'.tr();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextForm(
            hintText: hintText,
            prefixIcon: Icon(
              Icons.search_outlined,
              color: cc.iconSecondary,
              size: rf(20),
            ),
            onChanged: onChanged,
          ),
          verticalSpacing(8),
          Text(
            '$resultCount $label',
            style: AppTextStyles.font12SemiBold
                .copyWith(color: cc.textSecondary),
          ),
        ],
      ),
    );
  }
}
