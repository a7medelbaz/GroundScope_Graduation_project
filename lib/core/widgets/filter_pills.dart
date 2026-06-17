import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';

class FilterPills extends StatelessWidget {
  const FilterPills({
    super.key,
    required this.filters,
    required this.filterLabels,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final List<String> filters;
  final List<String> filterLabels;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(10)),
      child: Row(
        children: List.generate(filters.length, (i) {
          return Padding(
            padding: EdgeInsets.only(right: rw(8)),
            child: _FilterPill(
              label: filterLabels[i],
              isActive: activeFilter == filters[i],
              onTap: () => onFilterChanged(filters[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(6)),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary200 : cc.surfaceVariant,
          borderRadius: BorderRadius.circular(rr(20)),
          border: Border.all(
            color: isActive ? AppColors.primary200 : cc.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.font12SemiBold.copyWith(
            color: isActive ? AppColors.white : cc.textSecondary,
          ),
        ),
      ),
    );
  }
}
