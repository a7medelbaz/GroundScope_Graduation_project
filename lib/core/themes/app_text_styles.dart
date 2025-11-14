import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_font_weight.dart';

class AppTextStyles {
  static TextStyle font30WhiteBold = const TextStyle(
    fontSize: 30,
    fontWeight: FontWeightHelper.bold,
    color: Colors.white,
  );
  static TextStyle font16WhiteRegular = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
    color: Colors.white,
  );
  static TextStyle font18WhiteBold = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeightHelper.bold,
    color: Colors.white,
  );
  static TextStyle font16greyRegular = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.grayColor,
  );
}
