import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/modules/worker/features/notifications/data/models/notification_model.dart';

class NotificationFilterChip extends StatelessWidget {
  final String label;
  final NotificationFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  const NotificationFilterChip({
    super.key,
    required this.label,
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.grayColor,
            ),
            child: Text(label),
          ),
          SizedBox(height: 4.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: isSelected ? 40.w : 0,
            height: 2.h,
            decoration: BoxDecoration(
              color: AppColors.buttonBlue,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
        ],
      ),
    );
  }
}

