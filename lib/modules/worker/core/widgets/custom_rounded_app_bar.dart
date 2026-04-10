// import 'package:flutter/material.dart';
// import 'package:ground_scope/core/themes/app_colors.dart';
// import 'package:ground_scope/core/themes/app_text_styles.dart';
// import 'package:ground_scope/core/utils/spacing.dart';

// class CustomRoundedAppBar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final String title;
//   final VoidCallback? onBackPressed;
//   final Widget? leading; // Added this

//   const CustomRoundedAppBar({
//     super.key,
//     required this.title,
//     this.onBackPressed,
//     this.leading, // Added this
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return AppBar(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       elevation: 2,
//       shadowColor: AppColors.grey100,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(rr(30))),
//       ),
//       iconTheme: IconThemeData(color: theme.iconTheme.color),
//       titleTextStyle: AppTextStyles.font18SemiBold.copyWith(
//         color: theme.textTheme.titleLarge?.color,
//       ),
//       centerTitle: true,
//       title: Text(
//         title,
//         style: AppTextStyles.font20ExtraBold.copyWith(fontFamily: 'tajawal'),
//       ),
//       // If leading is null, it won't appear. If provided, it shows your icon.
//       leading: leading,
//     );
//   }

//   @override
//   Size get preferredSize => Size.fromHeight(rh(70));
// }
