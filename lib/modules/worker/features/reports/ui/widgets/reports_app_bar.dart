import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import '../../logic/cubit/reports_cubit.dart';

class ReportsAppBar extends StatelessWidget {
  const ReportsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<ReportsCubit, int>(
      (c) => c.state.reports.length,
    );

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
        top: rh(52),
        bottom: rh(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon bubble
          Container(
            width: rw(46),
            height: rw(46),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.analytics_outlined,
              color: AppColors.white,
              size: rf(22),
            ),
          ),
          horizontalSpacing(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Reports',
                  style: AppTextStyles.font22ExtraBold.copyWith(
                    color: AppColors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                verticalSpacing(2),
                Text(
                  'Track your submitted reports',
                  style: AppTextStyles.font12Light.copyWith(
                    color: AppColors.primary100,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: rw(12),
                vertical: rh(6),
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(rr(20)),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.font16SemiBold.copyWith(
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
