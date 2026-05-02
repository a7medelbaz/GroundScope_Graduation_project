import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ReportsEmptyState extends StatelessWidget {
  const ReportsEmptyState({super.key, this.isFiltered = false});

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFiltered
                ? Icons.filter_list_off_rounded
                : Icons.analytics_outlined,
            size: rf(52),
            color: cc.textDisabled,
          ),
          verticalSpacing(12),
          Text(
            isFiltered ? 'No reports match this filter' : 'No reports yet',
            style: AppTextStyles.font16SemiBold.copyWith(
              color: cc.textSecondary,
            ),
          ),
          verticalSpacing(4),
          Text(
            isFiltered
                ? 'Try a different filter'
                : 'Submitted reports will appear here',
            style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
