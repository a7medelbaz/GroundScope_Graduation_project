import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/extensions/context_extensions.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/shift_task_tile.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/work_status_card.dart';
import 'package:ground_scope/modules/worker/features/profile/ui/widgets/worker_profile_container.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/functions/app_setting_method.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../core/widgets/custom_rounded_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          CustomRoundedAppBar(
            title: 'worker_profile.profile'.tr(),
            onBackPressed: () => switchTheme(context),
          ),
          verticalSpacing(5),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(responsiveRadius(20)),
                child: Column(
                  children: <Widget>[
                    WorkerProfileContainer(
                      onTap: () {
                        context.pushNamed(
                          Routes.personaInfoAndSettings,
                        );
                      },
                      name: "Ahmed Ali",
                      workerId: "GS-8829",
                      unit: "Ground Handling",
                      shift: "08:00 - 16:00",
                      imageUrl: "assets/images/worker_test.png",
                    ),
                    verticalSpacing(25),
                    // 3. Stats Row Section
                    // ... inside your Column in WorkerProfileContainer ...
                    verticalSpacing(20),
                    // 2. Statistics Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: WorkerStatCard(
                            label: 'worker_profile.tasks'.tr(),
                            value: '12',
                            icon: Icons.task,
                            iconColor: AppColors.green100,
                            isDark: isDark,
                          ),
                        ),
                        horizontalSpacing(12),
                        Expanded(
                          child: WorkerStatCard(
                            label: 'worker_profile.on_time'.tr(),
                            value: '92%',
                            icon: Icons.timer_off,
                            iconColor: AppColors.amberLight,
                            isDark: isDark,
                          ),
                        ),
                        horizontalSpacing(12),
                        Expanded(
                          child: WorkerStatCard(
                            label: 'worker_profile.duration'.tr(),
                            value: '7h 30m',
                            icon: Icons.timelapse,
                            iconColor: AppColors.electricBlue,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(25),
                    _buildShiftSummarySection(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftSummarySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'worker_profile.Shift_Summary'.tr(),
          style: AppTextStyles.font18SemiBold.copyWith(
            color: isDark ? AppColors.white : AppColors.grey900,
          ),
        ),
        verticalSpacing(16),
        // List of tasks
        const ShiftTaskTile(
          title: 'Baggage Handling',
          time: '10:00 AM - 11:00 AM',
          isFirst: true,
        ),
        const ShiftTaskTile(
          title: 'Aircraft Refueling',
          time: '11:00 AM - 12:00 PM',
        ),
        const ShiftTaskTile(
          title: 'Cabin Cleaning',
          time: '12:00 PM - 01:00 PM',
        ),
        const ShiftTaskTile(
          title: 'Passenger Assistance',
          time: '01:00 PM - 02:00 PM',
          isLast: true,
        ),
      ],
    );
  }
}
