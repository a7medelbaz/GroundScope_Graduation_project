import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/modules/supervisor/core/widgets/supervisor_screen_header.dart';
import '../logic/cubit/supervisor_profile_cubit.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/supervisor_settings_tiles.dart';

class SupervisorProfileScreen extends StatefulWidget {
  const SupervisorProfileScreen({super.key});

  @override
  State<SupervisorProfileScreen> createState() =>
      _SupervisorProfileScreenState();
}

class _SupervisorProfileScreenState extends State<SupervisorProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupervisorProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Scaffold(
      backgroundColor: cc.background,
      body: BlocBuilder<SupervisorProfileCubit, SupervisorProfileState>(
        builder: (context, state) {
          if (state.status == SupervisorProfileStatus.loading ||
              state.status == SupervisorProfileStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary200),
            );
          }
          if (state.status == SupervisorProfileStatus.failure) {
            return ErrorScreen(
              error: state.error?.messageKey,
              onRetry: () =>
                  context.read<SupervisorProfileCubit>().loadProfile(),
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SupervisorScreenHeader(
                  icon: Icons.manage_accounts_outlined,
                  title: 'supervisor_profile_title'.tr(),
                  subtitle: state.user!.fullName,
                ),
                verticalSpacing(16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(16)),
                  child: ProfileInfoCard(
                    user: state.user!,
                    unitCount: state.unitCount,
                    memberCount: state.memberCount,
                  ),
                ),
                verticalSpacing(16),
                const SupervisorSettingsTiles(),
                verticalSpacing(32),
              ],
            ),
          );
        },
      ),
    );
  }
}
