import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

import '../../../../../../core/shared/data/models/report_model.dart';
import '../../logic/cubit/add_report_cubit.dart';

class ReportTypeSelector extends StatelessWidget {
  const ReportTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final selectedType = context.watch<AddReportCubit>().state.type;

    return Wrap(
      spacing: rw(10),
      runSpacing: rh(10),
      children: ReportType.values.map((type) {
        final isSelected = type == selectedType;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<AddReportCubit>().selectType(type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(10)),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary200.withOpacity(0.15)
                  : customColors.surfaceVariant,
              borderRadius: BorderRadius.circular(rr(12)),
              border: Border.all(
                color: isSelected ? AppColors.primary200 : customColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type.icon, style: const TextStyle(fontSize: 16)),
                horizontalSpacing(7),
                Text(
                  type.label,
                  style: isSelected
                      ? AppTextStyles.font14SemiBold.copyWith(
                          color: AppColors.primary200,
                        )
                      : AppTextStyles.font12Light.copyWith(
                          // Note: Added font13 if needed, or use font14Light
                          color: customColors.textSecondary,
                        ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
