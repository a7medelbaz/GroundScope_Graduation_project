import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/flights/logic/cubit/flights_list_cubit.dart';

class FlightFilterChips extends StatelessWidget {
  const FlightFilterChips({super.key, required this.selected, required this.onSelected});

  final FlightsFilter selected;
  final ValueChanged<FlightsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: FlightsFilter.values.map((filter) {
        final isSelected = filter == selected;
        return Padding(
          padding: EdgeInsets.only(right: rw(8)),
          child: FilterChip(
            label: Text(
              _label(filter),
              style: AppTextStyles.font12SemiBold.copyWith(
                color: isSelected ? AppColors.white : context.customColors.textSecondary,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
            backgroundColor: context.customColors.surface,
            selectedColor: AppColors.blue200,
            checkmarkColor: AppColors.white,
            side: BorderSide(
              color: isSelected ? AppColors.blue200 : context.customColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rr(20)),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(FlightsFilter filter) {
    return switch (filter) {
      FlightsFilter.all        => 'all'.tr(),
      FlightsFilter.active     => 'filter_active'.tr(),
      FlightsFilter.scheduled  => 'scheduled'.tr(),
      FlightsFilter.ready      => 'filter_ready'.tr(),
      FlightsFilter.departed   => 'filter_departed'.tr(),
      FlightsFilter.arrivals   => 'filter_arrivals'.tr(),
      FlightsFilter.departures => 'filter_departures'.tr(),
      FlightsFilter.cancelled  => 'cancelled'.tr(),
    };
  }
}
