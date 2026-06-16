import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class StandSearchBar extends StatelessWidget {
  const StandSearchBar({
    super.key,
    required this.onChanged,
    this.controller,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'search_stands'.tr(),
        hintStyle: TextStyle(color: context.customColors.textHint),
        prefixIcon: Icon(
          Icons.search,
          color: context.customColors.iconSecondary,
          size: rw(20),
        ),
        suffixIcon: controller != null
            ? ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller!,
                builder: (_, value, child) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(
                      Icons.close,
                      size: rw(18),
                      color: context.customColors.iconSecondary,
                    ),
                    onPressed: () {
                      controller!.clear();
                      onChanged('');
                    },
                  );
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
          borderRadius: BorderRadius.circular(rr(16)),
          borderSide: BorderSide(color: context.customColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rr(16)),
          borderSide: BorderSide(color: context.customColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rr(16)),
          borderSide: const BorderSide(color: AppColors.blue200),
        ),
      ),
    );
  }
}
