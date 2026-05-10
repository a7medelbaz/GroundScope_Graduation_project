import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/profile/logic/cubit/profile_cubit.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/profile_section_header.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/profile_settings_section.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/profile_unit_info_section.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/unit_manager_card.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({
    super.key,
    required this.state,
    required this.userModel,
    required this.unitId,
  });

  final ProfileState state;
  final UserModel? userModel;
  final String? unitId;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return RefreshIndicator(
      color: AppColors.primary200,
      backgroundColor: cc.background,
      onRefresh: () async {
        if (unitId != null) {
          await context.read<ProfileCubit>().loadProfile(unitId: unitId!);
        }
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(rw(20), rh(20), rw(20), rh(32)),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // ── Unit Info Section ─────────────────────────────────────────
          if (state.unit != null) ProfileUnitInfoSection(unit: state.unit!),

          // ── Unit Manager Card ─────────────────────────────────────────
          if (userModel != null) ...[
            verticalSpacing(16),
            GestureDetector(
              onTap: () => context.pushNamed(
                Routes.workerManagerAndMembersScreen,
                arguments: {'manager': userModel, 'members': state.members},
                rootNavigator: true,
              ),
              child: UnitManagerCard(manager: userModel!),
            ),
          ],

          verticalSpacing(24),

          // ── Settings ─────────────────────────────────────────────────
          ProfileSectionHeader(title: 'worker_profile.settings.settings'.tr()),
          verticalSpacing(12),
          const ProfileSettingsSection(),
        ],
      ),
    );
  }
}
