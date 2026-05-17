import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../../core/service/user_service.dart';
import '../../../../../../../core/themes/app_colors.dart';
import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/spacing.dart';
import '../../data/repo/supervisor_dashboard_repo.dart';
import '../../logic/cubit/assign_task_cubit.dart';
import 'assign_task_bottom_sheet.dart';

class SupervisorQuickActionsRow extends StatelessWidget {
  const SupervisorQuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuickActionButton(
          icon: Icons.assignment_outlined,
          label: 'supervisor_dashboard.assign_task'.tr(),
          backgroundColor: AppColors.primary200,
          onTap: () => _openAssignTask(context),
        ),
      ],
    );
  }

  void _openAssignTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => AssignTaskCubit(
          repo: GetIt.I<SupervisorDashboardRepo>(),
          userService: GetIt.I<UserService>(),
        )..loadFormData(),
        child: const AssignTaskBottomSheet(),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rr(14)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: rw(20), vertical: rh(16)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(rr(14)),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: rw(36),
              height: rw(36),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(rr(10)),
              ),
              child: Icon(icon, color: AppColors.white, size: rf(18)),
            ),
            horizontalSpacing(14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.font16SemiBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.white.withValues(alpha: 0.7),
              size: rf(20),
            ),
          ],
        ),
      ),
    );
  }
}
