import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class UnitMemberTile extends StatelessWidget {
  const UnitMemberTile({
    super.key,
    required this.member,
    required this.onTap,
    required this.onRemove,
  });

  final UnitMemberModel member;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(member.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onRemove();
        return false;
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: EdgeInsets.only(right: rw(20)),
        decoration: BoxDecoration(
          color: AppColors.red200.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(rr(12)),
        ),
        child: Icon(Icons.person_remove_outlined,
            color: AppColors.red200, size: rw(22)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: rh(8)),
        decoration: BoxDecoration(
          color: context.customColors.surface,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(color: context.customColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(rr(12)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rw(12),
              vertical: rh(10),
            ),
            child: Row(
              children: [
                _buildAvatar(context),
                horizontalSpacing(12),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final initials = member.fullName.trim().split(' ').take(2).map((w) {
      return w.isEmpty ? '' : w[0].toUpperCase();
    }).join();

    return Container(
      width: rw(40),
      height: rw(40),
      decoration: BoxDecoration(
        color: AppColors.green200.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.font14SemiBold.copyWith(
            color: AppColors.green200,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          member.fullName,
          style: AppTextStyles.font14SemiBold.copyWith(
            color: context.customColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        verticalSpacing(2),
        Text(
          [
            member.position,
            if (member.phone != null) member.phone!,
          ].join('  ·  '),
          style: AppTextStyles.font12Light.copyWith(
            color: context.customColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
