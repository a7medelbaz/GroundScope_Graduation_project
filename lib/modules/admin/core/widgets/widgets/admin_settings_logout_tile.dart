import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/ui/dialogs/app_dialogs.dart';

class AdminSettingsLogoutTile extends StatelessWidget {
  const AdminSettingsLogoutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onLogoutTap(context),
      borderRadius: BorderRadius.circular(rr(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: rh(12)),
        child: Row(
          children: [
            Container(
              width: rw(36),
              height: rw(36),
              decoration: BoxDecoration(
                color: AppColors.red0,
                borderRadius: BorderRadius.circular(rr(10)),
              ),
              child: Icon(
                Icons.logout_rounded,
                size: rw(18),
                color: AppColors.error,
              ),
            ),
            horizontalSpacing(12),
            Text(
              'logout'.tr(),
              style: AppTextStyles.font14SemiBold.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLogoutTap(BuildContext context) {
    AppDialogs.showConfirm(
      context,
      message: 'logout_confirm_message'.tr(),
      onConfirm: () {
        context.read<AuthCubit>().logout();
      },
    );
  }
}
