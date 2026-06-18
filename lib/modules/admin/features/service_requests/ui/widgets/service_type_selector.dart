import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ServiceTypeSelector extends StatelessWidget {
  const ServiceTypeSelector({
    super.key,
    required this.serviceTypes,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<ServiceTypeModel> serviceTypes;
  final Set<String> selectedIds;
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    if (serviceTypes.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: rh(12)),
        child: Text(
          'all_services_requested'.tr(),
          style: AppTextStyles.font14Light
              .copyWith(color: context.customColors.textHint),
        ),
      );
    }

    return Column(
      children: serviceTypes
          .map((st) => _ServiceTypeRow(
                serviceType: st,
                isSelected:  selectedIds.contains(st.id),
                onToggle:    () => onToggle(st.id),
              ))
          .toList(),
    );
  }
}

class _ServiceTypeRow extends StatelessWidget {
  const _ServiceTypeRow({
    required this.serviceType,
    required this.isSelected,
    required this.onToggle,
  });

  final ServiceTypeModel serviceType;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(rr(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: rh(4)),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primary200,
              side: BorderSide(color: cc.border, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rr(4)),
              ),
            ),
            horizontalSpacing(4),
            if (serviceType.icon != null) ...[
              Text(serviceType.icon!, style: AppTextStyles.font16SemiBold),
              horizontalSpacing(8),
            ],
            Expanded(
              child: Text(
                serviceType.name,
                style: AppTextStyles.font14SemiBold
                    .copyWith(color: cc.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
