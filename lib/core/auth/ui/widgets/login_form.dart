import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/extensions/context_extensions.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';

import '../../../utils/spacing.dart';
import '../../../utils/validators.dart';
import '../../../widgets/custom_text_button.dart';
import '../../../widgets/custom_text_form_.dart';
import '../../logic/cubit/auth_cubit.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().emitLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// --- Email Field ---
          CustomTextFormField(
            controller: _emailController,
            hintText: 'auth.email'.tr(),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          verticalSpacing(24),

          /// --- Password Field ---
          CustomTextFormField(
            controller: _passwordController,
            hintText: 'auth.password'.tr(),
            keyboardType: TextInputType.visiblePassword,
            isPassword: !_isPasswordVisible,
            validator: Validators.password,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: _isPasswordVisible ? Colors.red : Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          Row(
            children: [
              Checkbox(
                checkColor: AppColors.white,
                activeColor: AppColors.primary300,
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              Text(
                'auth.remember_me'.tr(),
                style: AppTextStyles.font14Regular.copyWith(
                  color: context.customColors.textSecondary,
                ),
              ),
            ],
          ),
          verticalSpacing(60),
          CustomTextButton(text: 'auth.login'.tr(), onPressed: _submit),
          verticalSpacing(60),
          GestureDetector(
            // onTap: () => context.router.pushNamed(Routes.forgotPassword),
            child: Text(
              'auth.forgot_password'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.font14Regular.copyWith(
                color: AppColors.primary300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
