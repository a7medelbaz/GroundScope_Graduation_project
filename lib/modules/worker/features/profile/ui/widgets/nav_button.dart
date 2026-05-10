import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class NavButton extends StatelessWidget {
  const NavButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: rw(36),
        height: rh(36),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(rr(10)),
        ),
        child: Center(
          child: Icon(icon, color: AppColors.white, size: rf(18)),
        ),
      ),
    );
  }
}
