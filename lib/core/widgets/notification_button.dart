import 'package:flutter/material.dart';

import '../themes/app_colors.dart';
import '../utils/spacing.dart';

class NotificationButton extends StatelessWidget {
  final Function onTap;
  const NotificationButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: AppColors.white.withAlpha(20),
      onTap: () {
        onTap;
      },
      child: Container(
        width: rw(44),
        height: rw(44),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 22,
            ),
            // Unread dot
            Positioned(
              top: rh(8),
              right: rw(8),
              child: Container(
                width: rw(8),
                height: rw(8),
                decoration: const BoxDecoration(
                  color: AppColors.secondary200,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
