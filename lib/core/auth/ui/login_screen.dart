import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../extensions/context_extensions.dart';
import '../../themes/app_text_styles.dart';
import '../../utils/spacing.dart';
import '../../widgets/ui/dialogs/app_dialogs.dart';
import '../../widgets/ui/loaders/overlay_loader.dart';
import '../logic/cubit/auth_cubit.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (final context, final state) {
            if (state is AuthFailure) {
              AppDialogs.showError(context, message: state.error.messageKey);
            }
          },
          builder: (final context, final state) {
            return OverlayLoader(
              isLoading: state is AuthChecking,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveWidth(16),
                  vertical: responsiveHeight(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpacing(40),
                      Text(
                        'auth.login_title'.tr(),
                        style: AppTextStyles.font20Bold,
                        textAlign: TextAlign.center,
                      ),
                      verticalSpacing(12),
                      Text(
                        'auth.login_desc'.tr(),
                        style: AppTextStyles.font14Regular.copyWith(
                          color: context.customColors.textSecondary,
                          height: 1.8,
                        ),
                      ),
                      verticalSpacing(80),
                      const LoginForm(),
                      verticalSpacing(60),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
