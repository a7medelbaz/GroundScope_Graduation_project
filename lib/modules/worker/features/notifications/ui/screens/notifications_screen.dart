import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/modules/worker/features/notifications/data/models/notification_model.dart';
import 'package:ground_scope/modules/worker/features/notifications/ui/widgets/notification_list.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  List<NotificationModel> get _allNotificationsList => _allNotifications;

  List<NotificationModel> get _tasksNotificationsList => _allNotifications
      .where((notification) => notification.type == NotificationType.task)
      .toList();

  List<NotificationModel> get _reportsNotificationsList => _allNotifications
      .where((notification) => notification.type == NotificationType.report)
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Update UI when tab changes via swipe
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.darkBlue,
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
                  style: AppTextStyles.font20WhiteSemiBold,
                ),
              ),
            ),
            // Custom TabBar
            _buildCustomTabBar(),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            // TabBarView for swiping
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // View 1: All Content
                  NotificationList(notifications: _allNotificationsList),
                  // View 2: Tasks Content
                  NotificationList(notifications: _tasksNotificationsList),
                  // View 3: Reports Content
                  NotificationList(notifications: _reportsNotificationsList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: AppColors.darkBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem('All', 0),
          SizedBox(width: 16.w),
          _buildTabItem('Tasks', 1),
          SizedBox(width: 16.w),
          _buildTabItem('Reports', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
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
