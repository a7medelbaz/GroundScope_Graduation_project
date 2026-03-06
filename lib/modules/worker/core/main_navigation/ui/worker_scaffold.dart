import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/themes/app_colors.dart';
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
  }

  List<PersistentBottomNavBarItem> _navBarItems(final BuildContext context) {
    final activeColor = AppColors.primary300;
    final inactiveColor = context.customColors.textSecondary;

    return [
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.home_outlined,
          size: responsiveRadius(28),
          color: activeColor,
        ),
        inactiveIcon: Icon(
          Icons.home,
          size: responsiveRadius(28),
          color: inactiveColor,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.analytics_outlined,
          size: responsiveRadius(28),
          color: activeColor,
        ),
        inactiveIcon: Icon(
          Icons.analytics_outlined,
          size: responsiveRadius(28),
          color: inactiveColor,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.notifications_outlined,
          color: activeColor,
          size: responsiveRadius(24),
        ),
        inactiveIcon: Icon(
          Icons.notifications,
          color: inactiveColor,
          size: responsiveRadius(24),
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.person_outline,
          size: responsiveRadius(28),
          color: activeColor,
        ),
        inactiveIcon: Icon(
          Icons.person,
          size: responsiveRadius(28),
          color: inactiveColor,
        ),
      ),
    ];
  }

  @override
  Widget build(final BuildContext context) {
    _screens = [
      const HomeScreen(),
      const ReportsScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _screens,
      items: _navBarItems(context),
      navBarStyle: NavBarStyle.style9,
      backgroundColor: context.customColors.background.withValues(alpha: 0.95),
      navBarHeight: responsiveHeight(60),
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      decoration: NavBarDecoration(
        colorBehindNavBar: context.customColors.background,
        boxShadow: [
          BoxShadow(
            color: context.customColors.textPrimary.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      confineToSafeArea: true,
    );
  }
}
