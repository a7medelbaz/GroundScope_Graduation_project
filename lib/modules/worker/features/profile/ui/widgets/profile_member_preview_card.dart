import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

import '../../data/models/unit_member_model.dart';

class ProfileMemberPreviewCard extends StatelessWidget {
  const ProfileMemberPreviewCard({
    super.key,
    required this.member,
    this.onTap,
  });

  final UnitMemberModel member;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rw(12), vertical: rh(10)),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(color: cc.border.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            _Avatar(
              imageUrl: member.imageUrl,
              fullName: member.fullName,
              radius: rr(20),
            ),
            horizontalSpacing(10),
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
              size: rf(12),
              color: cc.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
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
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
