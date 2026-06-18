import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/service_request_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';
import 'service_request_status_badge.dart';

class ServiceRequestTile extends StatelessWidget {
  const ServiceRequestTile({
    super.key,
    required this.request,
    required this.onCancel,
  });

  final AdminServiceRequestModel request;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Container(
      margin: EdgeInsets.only(bottom: rh(8)),
      padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(12)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(12)),
        border: Border.all(color: cc.border),
      ),
      child: Row(
        children: [
          Container(
            width: rw(36),
            height: rw(36),
            decoration: BoxDecoration(
              color: AppColors.primary200.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rr(10)),
            ),
            child: Icon(
              Icons.miscellaneous_services_outlined,
              color: AppColors.primary200,
              size: rf(18),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.serviceTypeName ?? request.serviceTypeId,
                  style: AppTextStyles.font14SemiBold
                      .copyWith(color: cc.textPrimary),
                ),
                verticalSpacing(4),
                ServiceRequestStatusBadge(status: request.status),
              ],
            ),
          ),
          if (request.isPending) ...[
            horizontalSpacing(8),
            CustomTextButton.outlined(
              text: 'cancel_request'.tr(),
              onPressed: onCancel,
              size: CustomButtonSize.small,
              isFullWidth: false,
            ),
          ],
        ],
      ),
    );
  }
}
