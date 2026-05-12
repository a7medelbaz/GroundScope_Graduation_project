import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';

class MemberListCard extends StatelessWidget {
  const MemberListCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  final UnitMemberModel member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(rw(14)),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: BorderRadius.circular(rr(14)),
          border: Border.all(color: cc.border.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            _MemberAvatar(
              imageUrl: member.imageUrl,
              fullName: member.fullName,
              radius: rr(24),
            ),
            horizontalSpacing(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: AppTextStyles.font14SemiBold.copyWith(
                      color: cc.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpacing(2),
                  Text(
                    member.position,
                    style: AppTextStyles.font12Light.copyWith(
                      color: cc.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: rf(14),
              color: cc.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.imageUrl,
    required this.fullName,
    required this.radius,
  });

  final String? imageUrl;
  final String fullName;
  final double radius;

  String _initials() {
    final parts =
        fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _backgroundColor() {
    const palette = [
      AppColors.primary200,
      AppColors.secondary200,
      AppColors.green300,
      AppColors.amber300,
      AppColors.blue300,
      AppColors.grey500,
    ];
    return palette[fullName.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(imageUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: _backgroundColor(),
      child: Text(
        _initials(),
        style: TextStyle(
          color: AppColors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
