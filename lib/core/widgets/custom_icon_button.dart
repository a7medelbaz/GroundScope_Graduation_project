import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import '../themes/app_text_styles.dart';
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
    final borderRadius = BorderRadius.circular(responsiveRadius(12));
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
            horizontal: label == null
                ? responsiveWidth(10)
                : responsiveWidth(12),
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize ?? responsiveFontSize(20),
                color: context.customColors.textSecondary,
              ),
              if (_hasLabel) ...[
                horizontalSpacing(6),
                Text(
                  label!,
                  style: AppTextStyles.font16Bold.copyWith(
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
