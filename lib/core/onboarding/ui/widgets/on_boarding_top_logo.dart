import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/app_assets.dart';
import '../../../../../../core/utils/spacing.dart';

class OnBoardingTopLogo extends StatelessWidget {
  const OnBoardingTopLogo({super.key});

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppAssets.appLogoSVG,
          height: responsiveHeight(40),
          width: responsiveWidth(40),
        ),
        horizontalSpacing(8),
        Text("app_title".tr(), style: AppTextStyles.font20Bold),
      ],
    );
  }
}
