import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.isObscureText = false,
    this.maxLines = 1,
    this.innerBackgroundColor,
    this.inputTextStyle,
    this.hintStyle,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.borderRadius,
    this.autofocus = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isObscureText;
  final int maxLines;
  final Color? innerBackgroundColor;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final double? borderRadius;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? 16.0);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      obscureText: isObscureText,
      maxLines: maxLines,
      autofocus: autofocus,
      style: inputTextStyle ?? AppTextStyles.font16WhiteRegular,
      validator: validator,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        filled: true,
        fillColor: innerBackgroundColor ?? Colors.transparent,
        hintText: hintText,
        hintStyle: hintStyle ?? AppTextStyles.font16greyRegular,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        focusedBorder:
            focusedBorder ??
            OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white, width: 1.3),
              borderRadius: radius,
            ),
        enabledBorder:
            enabledBorder ??
            OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.grayColor,
                width: 1,
              ),
              borderRadius: radius,
            ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
          borderRadius: radius,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
          borderRadius: radius,
        ),
      ),
    );
  }
}
