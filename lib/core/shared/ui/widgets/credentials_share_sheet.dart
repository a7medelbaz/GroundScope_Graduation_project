import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/shared/data/models/generated_credentials.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class CredentialsShareSheet extends StatelessWidget {
  const CredentialsShareSheet({
    super.key,
    required this.credentials,
    this.onDone,
  });

  final GeneratedCredentials credentials;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    // Capture the parent scaffold's messenger before the sheet context takes over.
    final messenger = ScaffoldMessenger.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: context.customColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(rr(24))),
        ),
        child: Column(
          children: [
            verticalSpacing(12),
            _DragHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: EdgeInsets.symmetric(
                  horizontal: rw(24),
                  vertical: rh(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    verticalSpacing(24),
                    Text(
                      'credentials'.tr(),
                      style: AppTextStyles.font12SemiBold.copyWith(
                        color: context.customColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    verticalSpacing(8),
                    _CredentialField(
                      label: 'copy_email'.tr(),
                      value: credentials.email,
                      messenger: messenger,
                    ),
                    verticalSpacing(10),
                    _CredentialField(
                      label: 'copy_password'.tr(),
                      value: credentials.password,
                      messenger: messenger,
                    ),
                    verticalSpacing(16),
                    _WarningBox(),
                    verticalSpacing(24),
                    _ShareButton(credentials: credentials),
                    verticalSpacing(10),
                    _DoneButton(onDone: onDone),
                    verticalSpacing(16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final contextName = credentials.contextName;
    final subtitleKey = credentials.role == UserRole.supervisor
        ? 'supervisor_account_created'
        : 'unit_manager_account_created';

    return Column(
      children: [
        Container(
          width: rw(56),
          height: rw(56),
          decoration: const BoxDecoration(
            color: AppColors.green50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: rw(32),
            color: AppColors.green200,
          ),
        ),
        verticalSpacing(12),
        Text(
          'account_created'.tr(),
          style: AppTextStyles.font18SemiBold.copyWith(
            color: context.customColors.textPrimary,
          ),
        ),
        verticalSpacing(4),
        Text(
          subtitleKey.tr(namedArgs: {'name': contextName}),
          style: AppTextStyles.font12Light.copyWith(
            color: context.customColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: rw(40),
      height: rh(4),
      decoration: BoxDecoration(
        color: context.customColors.border,
        borderRadius: BorderRadius.circular(rr(2)),
      ),
    );
  }
}

class _CredentialField extends StatelessWidget {
  const _CredentialField({
    required this.label,
    required this.value,
    required this.messenger,
  });

  final String label;
  final String value;
  final ScaffoldMessengerState messenger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(12)),
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(12)),
        border: Border.all(color: context.customColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.font14Light.copyWith(
                color: context.customColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          horizontalSpacing(8),
          GestureDetector(
            onTap: _copy,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(6)),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(rr(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded,
                      size: rw(14), color: AppColors.primary200),
                  horizontalSpacing(4),
                  Text(
                    label,
                    style: AppTextStyles.font12SemiBold
                        .copyWith(color: AppColors.primary200),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: value));
    messenger.showSnackBar(
      SnackBar(
        content: Text('copied'.tr()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.green200,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rw(12)),
      decoration: BoxDecoration(
        color: AppColors.amber0,
        borderRadius: BorderRadius.circular(rr(10)),
        border: Border.all(color: AppColors.amber100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: rw(18), color: AppColors.amber300),
          horizontalSpacing(8),
          Expanded(
            child: Text(
              'credentials_warning'.tr(),
              style: AppTextStyles.font12Light.copyWith(
                color: AppColors.amber400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.credentials});

  final GeneratedCredentials credentials;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: rh(50),
      child: OutlinedButton.icon(
        onPressed: _shareViaEmail,
        icon: Icon(Icons.email_outlined,
            size: rw(18), color: AppColors.primary200),
        label: Text(
          'share_via_email'.tr(),
          style: AppTextStyles.font14SemiBold
              .copyWith(color: AppColors.primary200),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rr(14)),
          ),
        ),
      ),
    );
  }

  Future<void> _shareViaEmail() async {
    final subject = Uri.encodeComponent('credentials_email_subject'.tr());
    final body = Uri.encodeComponent(credentials.shareMessage);
    final uri = Uri.parse('mailto:?subject=$subject&body=$body');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({this.onDone});

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: rh(50),
      child: ElevatedButton(
        onPressed: onDone ?? () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary200,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rr(14)),
          ),
        ),
        child: Text(
          'done'.tr(),
          style: AppTextStyles.font16SemiBold.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
