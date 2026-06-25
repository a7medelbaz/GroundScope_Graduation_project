import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ground_scope/core/notifications/logic/cubit/notification_cubit.dart';
import 'package:ground_scope/core/notifications/service/notification_navigator.dart';
import 'package:ground_scope/core/service/user_service.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions/context_ext.dart';
import 'cubit/supervisor_nav_cubit.dart';
import '../../features/dashboard/ui/supervisor_dashboard_screen.dart';
import '../../features/tasks/ui/supervisor_tasks_screen.dart';
import '../../features/units/ui/supervisor_units_screen.dart';
import '../../features/reports/ui/supervisor_reports_screen.dart';
import '../../features/profile/ui/supervisor_profile_screen.dart';

class SupervisorScaffold extends StatelessWidget {
  const SupervisorScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupervisorNavCubit(),
      child: const _SupervisorScaffoldBody(),
    );
  }
}

class _SupervisorScaffoldBody extends StatefulWidget {
  const _SupervisorScaffoldBody();

  @override
  State<_SupervisorScaffoldBody> createState() =>
      _SupervisorScaffoldBodyState();
}

class _SupervisorScaffoldBodyState extends State<_SupervisorScaffoldBody> {
  final List<Widget> _screens = const [
    SupervisorDashboardScreen(),
    SupervisorTasksScreen(),
    SupervisorUnitsScreen(),
    SupervisorReportsScreen(),
    SupervisorProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocBuilder<SupervisorNavCubit, SupervisorNavState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: cc.border, width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: state.currentIndex,
              onTap: context.read<SupervisorNavCubit>().changeTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: cc.surface,
              selectedItemColor: AppColors.primary200,
              unselectedItemColor: AppColors.grey400,
              selectedLabelStyle: AppTextStyles.font12SemiBold,
              unselectedLabelStyle: AppTextStyles.font12Light,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.dashboard_outlined),
                  activeIcon: const Icon(Icons.dashboard),
                  label: 'supervisor_dashboard_title'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.check_box_outlined),
                  activeIcon: const Icon(Icons.check_box),
                  label: 'supervisor_tasks_title'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.local_shipping_outlined),
                  activeIcon: const Icon(Icons.local_shipping),
                  label: 'supervisor_units_title'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.flag_outlined),
                  activeIcon: const Icon(Icons.flag),
                  label: 'supervisor_reports_title'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.account_circle_outlined),
                  activeIcon: const Icon(Icons.account_circle),
                  label: 'supervisor_profile_title'.tr(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
