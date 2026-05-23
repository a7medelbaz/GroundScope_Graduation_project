import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ServiceTypeSearchBar extends StatelessWidget {
  const ServiceTypeSearchBar({
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
        hintText: 'search_service_types'.tr(),
        hintStyle: TextStyle(color: context.customColors.textHint),
        prefixIcon: Icon(
          Icons.search,
          color: context.customColors.iconSecondary,
          size: rw(20),
        ),
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
          borderSide: const BorderSide(color: Color(0xff2FA4D7)),
        ),
      ),
    );
  }
}
