import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/ui/dialogs/app_dialogs.dart';
import 'package:ground_scope/modules/admin/features/units/logic/cubit/unit_detail_cubit.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_member_form_sheet.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_member_tile.dart';

class UnitMembersSection extends StatelessWidget {
  const UnitMembersSection({
    super.key,
    required this.unitId,
    required this.members,
  });

  final String unitId;
  final List<UnitMemberModel> members;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${'unit_members'.tr()} (${members.length})',
              style: AppTextStyles.font14SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddMember(context),
              icon: Icon(Icons.add, size: rw(16), color: AppColors.green200),
              label: Text(
                'add_member'.tr(),
                style: AppTextStyles.font12SemiBold
                    .copyWith(color: AppColors.green200),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: rw(8), vertical: rh(4)),
              ),
            ),
          ],
        ),
        verticalSpacing(8),
        if (members.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: rh(12)),
            child: Text(
              'no_members'.tr(),
              style: AppTextStyles.font14Light.copyWith(
                color: context.customColors.textSecondary,
              ),
            ),
          )
        else
          ...members.map(
            (m) => UnitMemberTile(
              member: m,
              onTap: () => _showEditMember(context, m),
              onRemove: () => _confirmRemove(context, m),
            ),
          ),
      ],
    );
  }

  Future<void> _showAddMember(BuildContext context) async {
    final cubit = context.read<UnitDetailCubit>();
    final added = await showUnitMemberFormSheet(
      context: context,
      unitId: unitId,
    );
    if (added) cubit.refreshMembers(unitId);
  }

  Future<void> _showEditMember(
      BuildContext context, UnitMemberModel member) async {
    final cubit = context.read<UnitDetailCubit>();
    final updated = await showUnitMemberFormSheet(
      context: context,
      unitId: unitId,
      editing: member,
    );
    if (updated) cubit.refreshMembers(unitId);
  }

  void _confirmRemove(BuildContext context, UnitMemberModel member) {
    final cubit = context.read<UnitDetailCubit>();
    AppDialogs.showConfirm(
      context,
      message: 'confirm_remove_member'.tr(),
      onConfirm: () {
        context.pop();
        cubit.deactivateMember(member.id);
      },
    );
  }
}
