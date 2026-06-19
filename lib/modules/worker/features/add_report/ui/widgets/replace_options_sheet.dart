import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/add_report/logic/cubit/add_report_cubit.dart';
import 'package:image_picker/image_picker.dart';

class ReplaceOptionsSheet extends StatelessWidget {
  const ReplaceOptionsSheet({super.key, required this.cubit});

  final AddReportCubit cubit;

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Container(
      margin: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: customColors.background,
        borderRadius: BorderRadius.circular(rr(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          verticalSpacing(8),
          Container(
            width: rw(36),
            height: rh(4),
            decoration: BoxDecoration(
              color: customColors.divider,
              borderRadius: BorderRadius.circular(rr(2)),
            ),
          ),
          verticalSpacing(16),

          ListTile(
            leading: Icon(
              Icons.camera_alt_rounded,
              color: customColors.iconPrimary,
            ),
            title: Text(
              'image_picker.take_photo'.tr(),
              style: AppTextStyles.font14SemiBold.copyWith(
                color: customColors.textPrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              cubit.pickImage(ImageSource.camera);
            },
          ),

          ListTile(
            leading: Icon(
              Icons.photo_library_rounded,
              color: customColors.iconPrimary,
            ),
            title: Text(
              'image_picker.choose_from_gallery'.tr(),
              style: AppTextStyles.font14SemiBold.copyWith(
                color: customColors.textPrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              cubit.pickImage(ImageSource.gallery);
            },
          ),

          verticalSpacing(16),
        ],
      ),
    );
  }
}
