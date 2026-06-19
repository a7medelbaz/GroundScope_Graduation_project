import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import '../../logic/cubit/reports_cubit.dart';

class ReportsFilterStrip extends StatelessWidget {
  const ReportsFilterStrip({super.key});

  static const _filters = [
    null,
    ReportStatus.open,
    ReportStatus.acknowledged,
    ReportStatus.inProgress,
    ReportStatus.resolved,
  ];

  String _label(ReportStatus? filter) => switch (filter) {
    null => 'filter_all'.tr(),
    ReportStatus.open => 'filter_open'.tr(),
    ReportStatus.acknowledged => 'filter_acknowledged'.tr(),
    ReportStatus.inProgress => 'filter_in_progress'.tr(),
    ReportStatus.resolved => 'filter_resolved'.tr(),
  };

  @override
  Widget build(BuildContext context) {
    final selected = context.select<ReportsCubit, ReportStatus?>(
      (c) => c.state.selectedFilter,
    );
    final cc = context.customColors;

    return SizedBox(
      height: rh(52),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: rw(20), vertical: rh(10)),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => horizontalSpacing(8),
        itemBuilder: (context, i) {
          final filter = _filters[i];
          final isSelected = selected == filter;

          return GestureDetector(
            onTap: () => context.read<ReportsCubit>().setFilter(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: rw(14),
                vertical: rh(6),
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary200 : cc.surfaceVariant,
                borderRadius: BorderRadius.circular(rr(20)),
                border: Border.all(
                  color: isSelected ? AppColors.primary200 : cc.border,
                  width: 1,
                ),
              ),
              child: Text(
                _label(filter),
                style: AppTextStyles.font12SemiBold.copyWith(
                  color: isSelected ? AppColors.white : cc.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
