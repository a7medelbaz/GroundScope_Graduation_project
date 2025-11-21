import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/modules/worker/features/home/ui/widgets/custom_task_card.dart';
import 'package:ground_scope/modules/worker/features/home/ui/widgets/profile_appbar.dart';

import '../../../../../core/utils/spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 23.5.w),
        child: Column(
          children: [
            const ProfileAppBar(),
            verticalSpacing(16),
            Align(
              alignment: AlignmentGeometry.topLeft,
              child: Text(
                'Today\'s Tasks',
                style: AppTextStyles.font24WhiteBold,
              ),
            ),
            const CustomTaskCard(
              title: "Baggage Handling",
              timeRange: "07:30 - 08:30",
              extraInfo: "A321, Stand12",
              progress: 0.40,
              status: TaskStatus.inProgress,
            ),

            const CustomTaskCard(
              title: "Fueling",
              timeRange: "05:00 - 06:00",
              extraInfo: "B737, Gate 9",
              progress: 1.0,
              status: TaskStatus.done,
            ),
            const CustomTaskCard(
              title: "Security Check",
              timeRange: "09:00 - 10:00",
              extraInfo: "Terminal 2",
              progress: 0.0,
              status: TaskStatus.pending,
            ),
          ],
        ),
      ),
    );
  }
}
