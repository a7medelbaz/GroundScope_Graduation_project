import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/info_card.dart';
import 'package:ground_scope/core/widgets/info_row_data.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/member_detail_screen_header.dart';

import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';

class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({super.key, required this.member});

  final UnitMemberModel member;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Scaffold(
      backgroundColor: cc.background,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          MemberDetailScreenHeader(member: member),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(rw(20), rh(24), rw(20), rh(40)),
              child: InfoCard(
                rows: [
                  if (member.phone != null)
                    InfoRowData(
                      icon: Icons.phone_rounded,
                      label: 'worker_profile.phone'.tr(),
                      value: member.phone!,
                    ),
                  if (member.nationalId != null)
                    InfoRowData(
                      icon: Icons.badge_rounded,
                      label: 'worker_profile.personal_information.national_id'
                          .tr(),
                      value: member.nationalId!,
                    ),
                  InfoRowData(
                    icon: Icons.work_rounded,
                    label: 'worker_profile.position'.tr(),
                    value: member.position,
                  ),
                  InfoRowData(
                    icon: Icons.calendar_today_rounded,
                    label: 'worker_profile.member_since'.tr(),
                    value: member.createdAt.formattedDate,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
