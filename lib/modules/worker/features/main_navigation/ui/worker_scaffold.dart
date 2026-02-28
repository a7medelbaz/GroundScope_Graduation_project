import 'package:flutter/material.dart';
import 'package:ground_scope/modules/worker/features/notifications/ui/notifications_screen.dart';
import 'package:ground_scope/modules/worker/features/reports/ui/reports_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/utils/spacing.dart';
import '../../home/ui/home_screen.dart';
import '../../profile/ui/profile_screen.dart';

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
    _screens = [
      const HomeScreen(),
      const ReportsScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems(final BuildContext context) {
    final activeColor = AppColors.primary300;

    return [
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.article_outlined,
          size: responsiveRadius(28),
          color: activeColor,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.search,
          size: responsiveRadius(28),
          color: AppColors.grey0,
        ),
        activeColorPrimary: activeColor,
        activeColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.notifications_outlined,
          color: activeColor,
          size: responsiveRadius(24),
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          Icons.person_outline,
          size: responsiveRadius(28),
          color: activeColor,
        ),
      ),
    ];
  }

  @override
  Widget build(final BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _screens,
      items: _navBarItems(context),
      navBarStyle: NavBarStyle.style16,
      backgroundColor: context.customColors.background,
      navBarHeight: responsiveHeight(58),
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      decoration: NavBarDecoration(
        colorBehindNavBar: context.customColors.background,
        boxShadow: [
          BoxShadow(
            color: context.customColors.border.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      confineToSafeArea: true,
    );
  }
}
