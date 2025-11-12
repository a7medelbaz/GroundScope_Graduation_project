import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.buttonText,
    this.textStyle,
    required this.onPressed,
    this.borderRadius,
    this.backgroundColor,
    this.buttonWidth,
    this.buttonHeight,
    this.verticalPadding,
    this.horizontalPadding,
    this.isLoading = false,
    this.icon,
  });

  final String buttonText;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final double? borderRadius;
  final Color? backgroundColor;
  final double? buttonWidth;
  final double? buttonHeight;
  final double? verticalPadding;
  final double? horizontalPadding;
  final bool isLoading;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth ?? double.infinity,
      height: buttonHeight?.h ?? 52.h,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => backgroundColor ?? AppColors.lightBlue,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
            ),
          ),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              vertical: verticalPadding?.h ?? 12.h,
              horizontal: horizontalPadding?.w ?? 16.w,
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => Colors.white.withAlpha(20),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, SizedBox(width: 8.w)],
                  Flexible(
                    child: Text(
                      buttonText,
                      style: textStyle ?? AppTextStyles.font16WhiteRegular,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
