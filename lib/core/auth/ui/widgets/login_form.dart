import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/extensions/context_ext.dart';
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
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
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
          CustomTextForm(
            controller: _emailController,
            hintText: 'auth.email'.tr(),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          verticalSpacing(24),
          CustomTextForm(
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

          verticalSpacing(60),
          CustomTextButton(
            text: 'auth.login'.tr(),
            onPressed: () {
              context.hideKeyboard();
              _submit();
            },
          ),
          verticalSpacing(60),
          GestureDetector(
            child: Text(
              'auth.forgot_password'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.font14Light.copyWith(
                color: AppColors.primary300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
