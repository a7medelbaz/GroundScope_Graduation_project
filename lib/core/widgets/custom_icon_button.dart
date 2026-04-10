import 'package:flutter/material.dart';

import '../themes/app_text_styles.dart';
import '../utils/extensions/context_ext.dart';
import '../utils/spacing.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final String? tooltip;
  final double? iconSize;
  final Color? backgroundColor;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.tooltip,
    this.iconSize,
    this.backgroundColor,
  });

  bool get _hasLabel => label != null;

  @override
  Widget build(final BuildContext context) {
    final borderRadius = BorderRadius.circular(rr(12));
    final backgroundColor = this.backgroundColor ?? Colors.transparent;

    final Widget button = Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: label == null ? rw(10) : rw(12),
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize ?? rf(20),
                color: context.customColors.textSecondary,
              ),
              if (_hasLabel) ...[
                horizontalSpacing(6),
                Text(
                  label!,
                  style: AppTextStyles.font16ExtraBold.copyWith(
                    color: context.customColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (tooltip == null) return button;

    return Tooltip(message: tooltip!, child: button);
  }
}
