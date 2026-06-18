import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ServiceRequestEmptyState extends StatelessWidget {
  const ServiceRequestEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(20)),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: rf(36), color: cc.iconSecondary),
          verticalSpacing(8),
          Text(
            'no_services_requested'.tr(),
            style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
          ),
        ],
      ),
    );
  }
}
