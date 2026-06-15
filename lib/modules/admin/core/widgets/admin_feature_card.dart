import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AdminFeatureCardData {
  const AdminFeatureCardData({
    required this.title,
    required this.icon,
    this.route,
    this.iconColor,
    this.subtitle,
    this.isAvailable = true,
  });

  final String title;
  final IconData icon;
  final String? route;
  final Color? iconColor;
  final String? subtitle;
  final bool isAvailable;
}

class AdminFeatureCard extends StatefulWidget {
  const AdminFeatureCard({
    super.key,
    required this.data,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  final AdminFeatureCardData data;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  State<AdminFeatureCard> createState() => _AdminFeatureCardState();
}

class _AdminFeatureCardState extends State<AdminFeatureCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.data.iconColor ?? AppColors.primary200;
    return GestureDetector(
          onTapDown: (_) => setState(() => _scale = 0.97),
          onTapUp: (_) {
            setState(() => _scale = 1.0);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _scale = 1.0),
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 100),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(rw(18)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(rr(20)),
                    border: Border.all(color: context.customColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: rw(55),
                        height: rw(55),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.data.icon,
                          size: rw(32),
                          color: iconColor,
                        ),
                      ),
                      verticalSpacing(12),
                      Text(
                        widget.data.title.tr(),
                        style: AppTextStyles.font14SemiBold.copyWith(
                          color: context.customColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpacing(3),
                      Text(
                        widget.data.subtitle ?? 'manage'.tr(),
                        style: AppTextStyles.font12Light.copyWith(
                          color: context.customColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: widget.animationDelay)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
