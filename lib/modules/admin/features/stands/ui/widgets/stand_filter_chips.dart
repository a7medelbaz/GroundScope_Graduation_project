import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/stands/logic/cubit/stands_list_cubit.dart';

class StandFilterChips extends StatelessWidget {
  const StandFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final StandsFilter selected;
  final ValueChanged<StandsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: StandsFilter.values.map((filter) {
        final isSelected = filter == selected;
        return Padding(
          padding: EdgeInsets.only(right: rw(8)),
          child: FilterChip(
            label: Text(
              _label(filter),
              style: AppTextStyles.font12SemiBold.copyWith(
                color: isSelected
                    ? AppColors.white
                    : context.customColors.textSecondary,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
            backgroundColor: context.customColors.surface,
            selectedColor: AppColors.blue200,
            checkmarkColor: AppColors.white,
            side: BorderSide(
              color:
                  isSelected ? AppColors.blue200 : context.customColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rr(20)),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(StandsFilter filter) {
    return switch (filter) {
      StandsFilter.all => 'all'.tr(),
      StandsFilter.active => 'active'.tr(),
      StandsFilter.inactive => 'inactive'.tr(),
    };
  }
}
