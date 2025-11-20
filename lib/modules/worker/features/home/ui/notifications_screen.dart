import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'report_details_screen.dart';
import 'task_details_screen.dart'; // Add this import

enum NotificationFilter { all, tasks, reports }

enum NotificationType { task, report, info }

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final NotificationType type;
  final VoidCallback? onAction;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    this.onAction,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationFilter _selectedFilter = NotificationFilter.all;

  final List<NotificationModel> _allNotifications = [
    NotificationModel(
      id: '1',
      title: 'Task Assigned',
      description: 'New baggage handling task at Gate A12.',
      time: '9:41 AM',
      type: NotificationType.task,
      onAction: () {},
    ),
    NotificationModel(
      id: '2',
      title: 'Incident Reported',
      description: 'Minor spill on the tarmac near Stand B3.',
      time: '9:32 AM',
      type: NotificationType.report,
      onAction: () {},
    ),
    NotificationModel(
      id: '3',
      title: 'Task Assigned',
      description: 'Aircraft cleaning required at Terminal 2.',
      time: '8:15 AM',
      type: NotificationType.task,
      onAction: () {},
    ),
    NotificationModel(
      id: '4',
      title: 'System Update',
      description: 'New safety protocols have been updated.',
      time: '7:30 AM',
      type: NotificationType.info,
      onAction: () {},
    ),
  ];

  List<NotificationModel> get _filteredNotifications {
    switch (_selectedFilter) {
      case NotificationFilter.all:
        return _allNotifications;
      case NotificationFilter.tasks:
        return _allNotifications
            .where((notification) => notification.type == NotificationType.task)
            .toList();
      case NotificationFilter.reports:
        return _allNotifications
            .where(
              (notification) => notification.type == NotificationType.report,
            )
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFF101922),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 20.h,
                bottom: 16.h,
              ),
              child: Center(
                child: Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            _FilterBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: _NotificationList(
                  key: ValueKey(_selectedFilter),
                  notifications: _filteredNotifications,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final NotificationFilter selectedFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;

  const _FilterBar({
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
          _FilterChip(
            label: 'All',
            filter: NotificationFilter.all,
            isSelected: selectedFilter == NotificationFilter.all,
            onTap: () => onFilterChanged(NotificationFilter.all),
          ),
          SizedBox(width: 16.w),
          _FilterChip(
            label: 'Tasks',
            filter: NotificationFilter.tasks,
            isSelected: selectedFilter == NotificationFilter.tasks,
            onTap: () => onFilterChanged(NotificationFilter.tasks),
          ),
          SizedBox(width: 16.w),
          _FilterChip(
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

class _FilterChip extends StatelessWidget {
  final String label;
  final NotificationFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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
              color: const Color(0xFF2E8AF0),
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationList extends StatefulWidget {
  final List<NotificationModel> notifications;

  const _NotificationList({super.key, required this.notifications});

  @override
  State<_NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<_NotificationList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.notifications.isEmpty) {
      return Container(
        color: const Color(0xFF101922),
        child: Center(
          child: Text(
            'No notifications',
            style: TextStyle(color: AppColors.grayColor, fontSize: 16.sp),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF101922),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: 16.h,
        ),
        itemCount: widget.notifications.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, thickness: 1, color: Color(0xFF1E2A35)),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: NotificationItemWidget(
              notification: widget.notifications[index],
            ),
          );
        },
      ),
    );
  }
}

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItemWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: 8.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconContainer(notification.type),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.font16WhiteRegular.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        notification.time,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFB0B0B0),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  notification.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF8B95A5),
                  ),
                ),
                if (notification.onAction != null) ...[
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () {
                      if (notification.type == NotificationType.report) {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ReportDetailsScreen(),
                            opaque: true,
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  final tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                          ),
                        );
                      } else if (notification.type == NotificationType.task) {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const TaskDetailsScreen(),
                            opaque: true,
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  final tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                          ),
                        );
                      } else {
                        notification.onAction?.call();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E8AF0).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        notification.type == NotificationType.task
                            ? 'View Task'
                            : notification.type == NotificationType.report
                            ? 'View Report'
                            : 'View Details',
                        style: TextStyle(
                          color: const Color(0xFF2E8AF0),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(NotificationType type) {
    Color backgroundColor;
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.task:
        backgroundColor = const Color(0xFF2E8AF0).withValues(alpha: 0.1);
        iconData = Icons.assignment_turned_in;
        iconColor = AppColors.lightBlue;
        break;
      case NotificationType.report:
        backgroundColor = const Color(0xFFFFC107).withValues(alpha: 0.1);
        iconData = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFFFC107);
        break;
      case NotificationType.info:
        backgroundColor = const Color(0xFF2E8AF0).withValues(alpha: 0.1);
        iconData = Icons.info_outline;
        iconColor = AppColors.lightBlue;
        break;
    }

    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Icon(iconData, color: iconColor, size: 24.sp),
      ),
    );
  }
}
