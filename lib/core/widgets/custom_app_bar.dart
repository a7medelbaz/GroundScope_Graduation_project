import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import '../themes/app_text_styles.dart';
import '../utils/spacing.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.title, this.iconData});
  final String title;
  final Widget? iconData;

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveWidth(16),
        vertical: responsiveHeight(24),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios_new),
          ),
          const Spacer(),
          Text(title, style: AppTextStyles.font18SemiBold),
          const Spacer(),
          iconData != null ? iconData! : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
