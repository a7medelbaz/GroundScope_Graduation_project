import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import '../logic/cubit/supervisor_profile_cubit.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/supervisor_personal_card.dart';
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

          final user = state.user!;

          return SafeArea(
            top: false,
            child: Column(
              children: [
                ProfileHeader(user: user),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary200,
                    backgroundColor: cc.background,
                    onRefresh: () =>
                        context.read<SupervisorProfileCubit>().loadProfile(),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                          rw(20), rh(24), rw(20), rh(40)),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SupervisorPersonalCard(
                          user: user,
                          serviceTypeName: state.serviceTypeName,
                        ),
                        verticalSpacing(24),
                        ProfileInfoCard(
                          unitCount: state.unitCount,
                          memberCount: state.memberCount,
                        ),
                        verticalSpacing(24),
                        _SectionLabel(
                            text: 'worker_profile.settings.settings'.tr()),
                        verticalSpacing(8),
                        const SupervisorSettingsTiles(),
                        verticalSpacing(16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.font12SemiBold.copyWith(
        color: context.customColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }
}
