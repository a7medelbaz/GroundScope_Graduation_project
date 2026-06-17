import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/users/logic/cubit/users_list_cubit.dart';

class UserFilterChips extends StatelessWidget {
  const UserFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final UsersFilter selected;
  final ValueChanged<UsersFilter> onChanged;

  static const _labels = {
    UsersFilter.all: 'all',
    UsersFilter.supervisors: 'supervisors',
    UsersFilter.unitManagers: 'unit_managers',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(6)),
      child: Row(
        children: UsersFilter.values.map((f) {
          final isSelected = f == selected;
          return Padding(
            padding: EdgeInsets.only(right: rw(8)),
            child: FilterChip(
              label: Text(
                _labels[f]!.tr(),
                style: AppTextStyles.font12SemiBold.copyWith(
                  color: isSelected
                      ? AppColors.white
                      : AppColors.grey400,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onChanged(f),
              backgroundColor: Colors.transparent,
              selectedColor: AppColors.primary200,
              side: BorderSide(
                color: isSelected ? AppColors.primary200 : AppColors.grey200,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rr(20)),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: rw(12), vertical: rh(4)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
