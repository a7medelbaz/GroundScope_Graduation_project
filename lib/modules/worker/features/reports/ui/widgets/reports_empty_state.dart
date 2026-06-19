import 'package:easy_localization/easy_localization.dart';
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
            isFiltered
                ? 'worker_reports.filtered_empty_title'.tr()
                : 'worker_reports.empty_title'.tr(),
            style: AppTextStyles.font16SemiBold.copyWith(
              color: cc.textSecondary,
            ),
          ),
          verticalSpacing(4),
          Text(
            isFiltered
                ? 'worker_reports.filtered_empty_subtitle'.tr()
                : 'worker_reports.empty_subtitle'.tr(),
            style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
