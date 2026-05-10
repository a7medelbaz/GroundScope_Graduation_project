import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/members_screen_header.dart';

import '../data/models/unit_member_model.dart';
import 'widgets/member_list_card.dart';
import 'widgets/unit_manager_detail_card.dart';

class ManagerAndMembersScreen extends StatelessWidget {
  const ManagerAndMembersScreen({
    super.key,
    required this.manager,
    required this.members,
  });

  final UserModel manager;
  final List<UnitMemberModel> members;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Scaffold(
      backgroundColor: cc.background,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const MembersScreenHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(rw(20), rh(20), rw(20), rh(32)),
              children: [
                UnitManagerDetailCard(manager: manager),
                verticalSpacing(24),
                Text(
                  members.isEmpty
                      ? 'worker_profile.team_members'.tr()
                      : '${'worker_profile.team_members'.tr()} (${members.length})',
                  style: AppTextStyles.font16SemiBold.copyWith(
                    color: cc.textPrimary,
                  ),
                ),
                verticalSpacing(12),
                if (members.isEmpty)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      verticalSpacing(8),
                      Icon(
                        Icons.group_off_rounded,
                        size: rf(40),
                        color: cc.textDisabled,
                      ),
                      verticalSpacing(10),
                      Text(
                        'worker_profile.no_members'.tr(),
                        style: AppTextStyles.font14Light.copyWith(
                          color: cc.textSecondary,
                        ),
                      ),
                    ],
                  )
                else
                  ...members.asMap().entries.map(
                    (e) => Padding(
                      padding: EdgeInsets.only(top: e.key == 0 ? 0 : rh(10)),
                      child: MemberListCard(
                        member: e.value,
                        onTap: () => context.pushNamed(
                          Routes.workerMemberDetailScreen,
                          arguments: {'member': e.value},
                          rootNavigator: true,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
