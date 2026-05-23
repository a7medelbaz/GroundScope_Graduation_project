import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/service_types/logic/cubit/service_types_list_cubit.dart';

class ServiceTypeFilterChips extends StatelessWidget {
  const ServiceTypeFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ServiceTypesFilter selected;
  final ValueChanged<ServiceTypesFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ServiceTypesFilter.values.map((filter) {
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
            selectedColor: AppColors.primary200,
            checkmarkColor: AppColors.white,
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary200
                  : context.customColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rr(20)),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(ServiceTypesFilter filter) {
    return switch (filter) {
      ServiceTypesFilter.all => 'all'.tr(),
      ServiceTypesFilter.active => 'active'.tr(),
      ServiceTypesFilter.inactive => 'inactive'.tr(),
    };
  }
}
