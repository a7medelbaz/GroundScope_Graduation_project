import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class SupervisorScreenHeader extends StatelessWidget {
  const SupervisorScreenHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.subtitleOnTop = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  /// When true, subtitle (small/dim) renders above title (big/white).
  /// Used by the Dashboard where greeting appears above the user's name.
  final bool subtitleOnTop;

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      style: AppTextStyles.font20ExtraBold.copyWith(color: AppColors.white),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final subtitleText = Text(
      subtitle,
      style: AppTextStyles.font12Light.copyWith(
        color: AppColors.white.withValues(alpha: 0.7),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        rw(20),
        rh(20) + MediaQuery.of(context).padding.top,
        rw(20),
        rh(24),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary400,
            AppColors.primary300,
            AppColors.primary200,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          // Left icon circle
          Container(
            width: rw(52),
            height: rw(52),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, color: AppColors.white, size: rf(22)),
          ),
          horizontalSpacing(rw(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subtitleOnTop
                  ? [subtitleText, verticalSpacing(rh(2)), titleText]
                  : [titleText, verticalSpacing(rh(2)), subtitleText],
            ),
          ),
          if (trailing != null) ...[
            horizontalSpacing(rw(8)),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Circular counter badge — used by Tasks and Reports headers.
class HeaderCountBadge extends StatelessWidget {
  const HeaderCountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: rw(40),
      height: rw(40),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$count',
          style: AppTextStyles.font14ExtraBold.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
