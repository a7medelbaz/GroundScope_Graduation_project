import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/task_info/ui/widgets/quick_pill.dart';

class TaskInfoHeader extends StatelessWidget {
  const TaskInfoHeader({super.key, required this.task});
  final TaskModel task;

  IconData get _serviceIcon => switch (task.serviceTypeName?.toLowerCase()) {
    'fuel' => Icons.local_gas_station_rounded,
    'cleaning' => Icons.cleaning_services_rounded,
    'catering' => Icons.restaurant_rounded,
    'maintenance' => Icons.build_rounded,
    'baggage' => Icons.luggage_rounded,
    _ => Icons.miscellaneous_services_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary400,
            AppColors.primary300,
            AppColors.primary200,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: rw(20),
        right: rw(20),
        top: rh(56),
        bottom: rh(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: rw(38),
                  height: rw(38),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
              horizontalSpacing(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Info',
                      style: AppTextStyles.font18ExtraBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      task.serviceTypeName ?? 'Ground Service',
                      style: AppTextStyles.font12Light.copyWith(
                        color: AppColors.primary100,
                      ),
                    ),
                  ],
                ),
              ),
              // Service icon box
              Container(
                width: rw(46),
                height: rw(46),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(rr(12)),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(_serviceIcon, color: AppColors.white, size: rf(22)),
              ),
            ],
          ),

          verticalSpacing(20),

          // Quick stat pills row
          Row(
            children: [
              QuickPill(
                icon: Icons.flight_rounded,
                label: task.flightNumber ?? '—',
              ),
              horizontalSpacing(8),
              if (task.standCode != null) ...[
                QuickPill(
                  icon: Icons.location_on_rounded,
                  label: 'Stand ${task.standCode}',
                ),
                horizontalSpacing(8),
              ],
              QuickPill(
                icon: Icons.timer_outlined,
                label: '${task.durationMinutes} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
