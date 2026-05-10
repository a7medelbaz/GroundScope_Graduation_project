import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_font_weight.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/nav_button.dart';

class MemberDetailScreenHeader extends StatelessWidget {
  const MemberDetailScreenHeader({super.key, required this.member});

  final UnitMemberModel member;

  String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _avatarColor(String name) {
    const palette = [
      AppColors.primary200,
      AppColors.secondary200,
      AppColors.green300,
      AppColors.amber300,
      AppColors.blue300,
      AppColors.grey500,
    ];
    return palette[name.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(rw(20), topPadding + rh(12), rw(20), rh(28)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary400,
            AppColors.primary300,
            AppColors.primary200,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(rr(28))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          NavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => context.pop(),
          ),
          verticalSpacing(20),

          // Avatar + name + position
          Center(
            child: Column(
              children: [
                // Avatar
                member.imageUrl != null
                    ? CircleAvatar(
                        radius: rr(40),
                        backgroundImage: CachedNetworkImageProvider(
                          member.imageUrl!,
                        ),
                      )
                    : CircleAvatar(
                        radius: rr(40),
                        backgroundColor: _avatarColor(
                          member.fullName,
                        ).withValues(alpha: 0.85),
                        child: Text(
                          _initials(member.fullName),
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: rf(22),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                verticalSpacing(14),

                // Name
                Text(
                  member.fullName,
                  style: AppTextStyles.font18SemiBold.copyWith(
                    color: AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                verticalSpacing(8),

                // Position badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(14),
                    vertical: rh(5),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(rr(20)),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    member.position,
                    style: AppTextStyles.font12SemiBold.copyWith(
                      color: AppColors.white,
                      fontWeight: AppFontWeight.semiBold,
                      letterSpacing: 0.5,
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
