import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    this.trailing,
    this.child,
    this.showBack = true,
  });

  final String title;
  final Widget? trailing;
  final Widget? child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.of(context).canPop();

    return Container(
      width: double.infinity,
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              rw(16),
              rh(12),
              rw(16),
              child != null ? rh(12) : rh(20),
            ),
            child: Row(
              children: [
                if (canPop)
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: rw(32),
                      height: rw(32),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(rr(10)),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: rf(14),
                        color: AppColors.white,
                      ),
                    ),
                  ),
                if (canPop) horizontalSpacing(12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.font22ExtraBold.copyWith(
                      color: AppColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...[
                  horizontalSpacing(12),
                  trailing!,
                ],
              ],
            ),
          ),
          if (child != null)
            Padding(
              padding: EdgeInsets.fromLTRB(rw(16), 0, rw(16), rh(20)),
              child: child,
            ),
        ],
      ),
    );
  }
}
