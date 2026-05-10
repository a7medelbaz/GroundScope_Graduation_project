import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/profile_app_bar.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/profile_body.dart';

import '../logic/cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _unitId;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      _userModel = authState.userModel;
      _unitId = authState.userModel.unitId;
      if (_unitId != null) {
        context.read<ProfileCubit>().loadProfile(_unitId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          ProfileAppBar(userModel: _userModel),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state.status == ProfileStatus.loading ||
                    state.status == ProfileStatus.initial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary200,
                    ),
                  );
                }

                if (state.status == ProfileStatus.failure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: rf(48),
                          color: context.customColors.textDisabled,
                        ),
                        verticalSpacing(12),
                        Text(
                          state.error?.messageKey ?? 'Something went wrong',
                          style: AppTextStyles.font14Light.copyWith(
                            color: context.customColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        verticalSpacing(8),
                        if (_unitId != null)
                          TextButton.icon(
                            onPressed: () => context
                                .read<ProfileCubit>()
                                .loadProfile(_unitId!),
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.primary200,
                            ),
                            label: Text(
                              'errors.error_screen_button'.tr(),
                              style: AppTextStyles.font14SemiBold.copyWith(
                                color: AppColors.primary200,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ProfileBody(
                  state: state,
                  userModel: _userModel,
                  unitId: _unitId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
