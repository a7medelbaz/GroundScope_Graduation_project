import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_form_.dart';

class ServiceTypeFormFields extends StatelessWidget {
  const ServiceTypeFormFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.durationController,
    required this.iconController,
    required this.isActive,
    required this.onActiveChanged,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController durationController;
  final TextEditingController iconController;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'service_type_name'.tr(), isRequired: true),
        verticalSpacing(8),
        CustomTextForm(
          hintText: 'service_type_name'.tr(),
          controller: nameController,
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'auth.validation.required'.tr();
            }
            if (v.trim().length < 2) return 'auth.validation.name'.tr();
            return null;
          },
        ),
        verticalSpacing(16),
        _FieldLabel(label: 'service_type_description'.tr()),
        verticalSpacing(8),
        CustomTextForm(
          hintText: 'service_type_description'.tr(),
          controller: descriptionController,
          maxLines: 3,
          textInputAction: TextInputAction.next,
        ),
        verticalSpacing(16),
        _FieldLabel(
          label: 'service_type_duration'.tr(),
          isRequired: true,
        ),
        verticalSpacing(8),
        CustomTextForm(
          hintText: 'service_type_duration'.tr(),
          controller: durationController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'auth.validation.required'.tr();
            }
            final parsed = int.tryParse(v.trim());
            if (parsed == null || parsed <= 0) {
              return 'auth.validation.required'.tr();
            }
            return null;
          },
        ),
        verticalSpacing(16),
        _FieldLabel(label: 'service_type_icon'.tr()),
        verticalSpacing(8),
        CustomTextForm(
          hintText: 'service_type_icon'.tr(),
          controller: iconController,
          textInputAction: TextInputAction.done,
        ),
        verticalSpacing(16),
        SwitchListTile(
          value: isActive,
          onChanged: onActiveChanged,
          title: Text(
            'service_type_active'.tr(),
            style: AppTextStyles.font14SemiBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.isRequired = false});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.font14SemiBold.copyWith(
            color: context.customColors.textPrimary,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: AppTextStyles.font14SemiBold.copyWith(color: Colors.red),
          ),
      ],
    );
  }
}
