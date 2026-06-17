import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class UnitSearchBar extends StatelessWidget {
  const UnitSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.font14Light.copyWith(
        color: context.customColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'search_units'.tr(),
        hintStyle: AppTextStyles.font14Light.copyWith(
          color: context.customColors.textHint,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: context.customColors.iconSecondary,
          size: rw(20),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded,
                    size: rw(18), color: context.customColors.iconSecondary),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: context.customColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: rw(16),
          vertical: rh(12),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rr(12)),
          borderSide: BorderSide(color: context.customColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rr(12)),
          borderSide: BorderSide(color: context.customColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rr(12)),
          borderSide: const BorderSide(color: AppColors.green200),
        ),
      ),
    );
  }
}
