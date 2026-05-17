import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ground_scope/modules/supervisor/core/main_navigation/cubit/supervisor_bottom_nav_cubit.dart';
import 'package:ground_scope/modules/supervisor/features/dashboard/logic/cubit/supervisor_dashboard_cubit.dart';
import 'package:ground_scope/modules/supervisor/features/reports/logic/cubit/supervisor_reports_cubit.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../core/utils/spacing.dart';
import '../../features/dashboard/ui/supervisor_dashboard_screen.dart';
import '../../features/profile/ui/supervisor_profile_screen.dart';
import '../../features/reports/ui/supervisor_reports_screen.dart';
import '../../features/tasks/ui/supervisor_tasks_screen.dart';

class SupervisorScaffold extends StatefulWidget {
  const SupervisorScaffold({super.key});

  @override
  State<SupervisorScaffold> createState() => _SupervisorScaffoldState();
}

class _SupervisorScaffoldState extends State<SupervisorScaffold> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      const SupervisorDashboardScreen(),
      const SupervisorReportsScreen(),
      Container(),
      const SupervisorTasksScreen(),
      const SupervisorProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems(BuildContext context) {
    final activeColor = AppColors.primary300;
    final inactiveColor = context.customColors.textSecondary;

    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.dashboard_outlined, size: rr(28), color: activeColor),
        inactiveIcon: Icon(Icons.dashboard, size: rr(28), color: inactiveColor),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.analytics_outlined, size: rr(28), color: activeColor),
        inactiveIcon: Icon(Icons.analytics, size: rr(28), color: inactiveColor),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add, size: rr(32), color: Colors.white),
        activeColorPrimary: AppColors.primary300,
        inactiveColorPrimary: AppColors.primary300,
        onPressed: (context) {},
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.assignment_outlined, size: rr(28), color: activeColor),
        inactiveIcon: Icon(
          Icons.assignment,
          size: rr(28),
          color: inactiveColor,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person_outline, size: rr(28), color: activeColor),
        inactiveIcon: Icon(Icons.person, size: rr(28), color: inactiveColor),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SupervisorBottomNavCubit>(
          create: (_) => SupervisorBottomNavCubit(),
        ),
        BlocProvider<SupervisorDashboardCubit>(
          create: (_) =>
              GetIt.I<SupervisorDashboardCubit>()..loadDashboard(),
        ),
        BlocProvider<SupervisorReportsCubit>(
          create: (_) =>
              GetIt.I<SupervisorReportsCubit>()..loadReports(),
        ),
      ],
      child: BlocListener<SupervisorBottomNavCubit, int>(
        listener: (context, tabIndex) {
          _controller.jumpToTab(tabIndex);
        },
        child: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarItems(context),
          navBarStyle: NavBarStyle.style15,
          navBarHeight: rh(70),
          padding: EdgeInsets.only(top: rh(2), bottom: rh(8)),
          backgroundColor:
              context.customColors.background.withValues(alpha: 0.95),
          decoration: NavBarDecoration(
            colorBehindNavBar: context.customColors.background,
            boxShadow: [
              BoxShadow(
                color: context.customColors.textPrimary.withValues(alpha: 0.15),
                blurRadius: 15,
                spreadRadius: 3,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          confineToSafeArea: true,
        ),
      ),
    );
  }
}
