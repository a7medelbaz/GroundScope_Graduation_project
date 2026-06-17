import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/units/logic/cubit/units_list_cubit.dart';

class UnitFilterChips extends StatelessWidget {
  const UnitFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final UnitsFilter selected;
  final ValueChanged<UnitsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: UnitsFilter.values.map((filter) {
          final isSelected = selected == filter;
          return Padding(
            padding: EdgeInsets.only(right: rw(8)),
            child: FilterChip(
              label: Text(
                _label(filter).tr(),
                style: AppTextStyles.font12SemiBold.copyWith(
                  color: isSelected
                      ? AppColors.white
                      : context.customColors.textSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(filter),
              selectedColor: AppColors.green200,
              backgroundColor: context.customColors.surface,
              checkmarkColor: AppColors.white,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected
                    ? AppColors.green200
                    : context.customColors.border,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: rw(4),
                vertical: rh(0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(UnitsFilter filter) => switch (filter) {
        UnitsFilter.all => 'all',
        UnitsFilter.available => 'unit_status_available',
        UnitsFilter.busy => 'unit_status_busy',
        UnitsFilter.offline => 'unit_status_offline',
        UnitsFilter.maintenance => 'unit_status_maintenance',
      };
}
