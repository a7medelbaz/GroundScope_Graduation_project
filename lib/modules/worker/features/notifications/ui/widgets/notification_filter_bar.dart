import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/modules/worker/features/notifications/data/models/notification_model.dart';
import 'package:ground_scope/modules/worker/features/notifications/ui/widgets/notification_filter_chip.dart';

class NotificationFilterBar extends StatelessWidget {
  final NotificationFilter selectedFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;

  const NotificationFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: AppColors.darkBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NotificationFilterChip(
            label: 'All',
            filter: NotificationFilter.all,
            isSelected: selectedFilter == NotificationFilter.all,
            onTap: () => onFilterChanged(NotificationFilter.all),
          ),
          SizedBox(width: 16.w),
          NotificationFilterChip(
            label: 'Tasks',
            filter: NotificationFilter.tasks,
            isSelected: selectedFilter == NotificationFilter.tasks,
            onTap: () => onFilterChanged(NotificationFilter.tasks),
          ),
          SizedBox(width: 16.w),
          NotificationFilterChip(
            label: 'Reports',
            filter: NotificationFilter.reports,
            isSelected: selectedFilter == NotificationFilter.reports,
            onTap: () => onFilterChanged(NotificationFilter.reports),
          ),
        ],
      ),
    );
  }
}

