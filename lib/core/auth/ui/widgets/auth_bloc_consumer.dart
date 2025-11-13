import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/extensions.dart';

import '../../../router/routes.dart';
import '../../../widgets/custom_text_button.dart';
import '../../logic/cubit/auth_cubit.dart';

class AuthBlocConsumer extends StatelessWidget {
  const AuthBlocConsumer({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is AuthLoading) {
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) =>
                  const Center(child: CircularProgressIndicator()),
            );
          }
        }

        if (state is AuthSuccess) {
          if (context.mounted) {
            if (Navigator.canPop(context)) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Welcome ${state.userData.firstName}! 🎉',
                ),
                backgroundColor: Colors.green,
              ),
            );

            await Future.delayed(const Duration(milliseconds: 300));

            if (context.mounted) {
              context.pushReplacementNamed(Routes.homeScreen);
            }
          }
        }

        if (state is AuthFailure) {
          if (context.mounted) {
            if (Navigator.canPop(context)) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Login Failed'),
                content: Text(state.errorMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return CustomTextButton(
          buttonText: 'Login',
          onPressed: () {
            final authCubit = context.read<AuthCubit>();
            authCubit.emitLogin(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );
          },
        );
      },
    );
  }
}
