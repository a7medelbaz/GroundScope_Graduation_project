import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/widgets/info_card.dart';
import 'package:ground_scope/core/widgets/info_row_data.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.user,
    required this.unitCount,
    required this.memberCount,
  });

  final UserModel user;
  final int unitCount;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      rows: [
        InfoRowData(
          icon: Icons.mail_outline,
          label: 'email'.tr(),
          value: user.email,
        ),
        InfoRowData(
          icon: Icons.phone_outlined,
          label: 'phone'.tr(),
          value: user.phone ?? '—',
        ),
        InfoRowData(
          icon: Icons.bolt_outlined,
          label: 'service_type'.tr(),
          value: user.serviceTypeId ?? '—',
          highlight: true,
        ),
        InfoRowData(
          icon: Icons.local_shipping_outlined,
          label: 'units_managed'.tr(),
          value: '$unitCount ${'units'.tr()} · $memberCount ${'crew_members'.tr()}',
        ),
      ],
    );
  }
}
