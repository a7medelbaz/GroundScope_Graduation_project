import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ground_scope/core/notifications/logic/cubit/notification_cubit.dart';
import 'package:ground_scope/core/notifications/service/notification_navigator.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/add_report_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../features/home/ui/home_screen.dart';
import '../../../features/notifications/ui/notifications_screen.dart';
import '../../../features/profile/ui/profile_screen.dart';
import '../../../features/reports/ui/reports_screen.dart';

class WorkerScaffold extends StatefulWidget {
  const WorkerScaffold({super.key});

  @override
  State<WorkerScaffold> createState() => _WorkerScaffoldState();
}

class _WorkerScaffoldState extends State<WorkerScaffold> {
  late PersistentTabController _controller;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await GetIt.instance<UserService>().getUser();
      if (user != null && mounted) {
        context.read<NotificationCubit>().startUnreadWatch(user.id);
        context.read<NotificationCubit>().load();
      }
      if (mounted) {
        await NotificationNavigator.handleInitialMessage(context);
        NotificationNavigator.listenForTaps(context);
      }
    });
  }

  List<PersistentBottomNavBarItem> _navBarItems(final BuildContext context) {
    final activeColor = AppColors.primary300;
    final inactiveColor = context.customColors.textSecondary;

    return [
      // Home
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home_outlined, size: rr(28), color: activeColor),
        inactiveIcon: Icon(Icons.home, size: rr(28), color: inactiveColor),
      ),
      // RReport
      PersistentBottomNavBarItem(
        icon: Icon(Icons.analytics_outlined, size: rr(28), color: activeColor),
        inactiveIcon: Icon(Icons.analytics_outlined, size: rr(28), color: inactiveColor),
      ),
      // Add Report
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add, color: AppColors.white, size: rr(24)),
        inactiveIcon: Icon(Icons.add, color: inactiveColor, size: rr(24)),
      ),
      // Notifications
      PersistentBottomNavBarItem(
        icon: Icon(Icons.notifications_outlined, color: activeColor, size: rr(24)),
        inactiveIcon: Icon(Icons.notifications, color: inactiveColor, size: rr(24)),
      ),
      // Profile
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person_outline, size: rr(28), color: activeColor),
        inactiveIcon: Icon(Icons.person, size: rr(28), color: inactiveColor),
      ),
    ];
  }

  @override
  Widget build(final BuildContext context) {
    _screens = [const HomeScreen(), const ReportsScreen(), const AddReportScreen(), const NotificationsScreen(), const ProfileScreen()];
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _screens,
      items: _navBarItems(context),
      navBarStyle: NavBarStyle.style15,
      backgroundColor: context.customColors.background.withValues(alpha: 0.95),
      navBarHeight: rh(60),
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      decoration: NavBarDecoration(
        colorBehindNavBar: context.customColors.background,
        boxShadow: [BoxShadow(color: context.customColors.textPrimary.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, -2))],
      ),
      confineToSafeArea: true,
    );
  }
}
