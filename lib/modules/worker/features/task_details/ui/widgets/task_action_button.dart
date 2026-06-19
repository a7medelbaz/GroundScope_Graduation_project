import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../../../../../core/widgets/custom_text_button.dart';

class TaskActionButton extends StatelessWidget {
  const TaskActionButton({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onComplete,
    this.isLoading = false,
  });
  final TaskStatus? status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onComplete;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      TaskStatus.assigned => _singleButton(
        text: 'worker_task_details.start_task'.tr(),
        icon: Icons.play_arrow_rounded,
        color: AppColors.primary200,
        onTap: onStart,
      ),

      TaskStatus.inProgress => _doubleButton(
        leftText: 'worker_task_details.pause'.tr(),
        leftIcon: Icons.pause_rounded,
        leftColor: AppColors.amber200,
        onLeftTap: onPause,
        rightText: 'worker_task_details.finish'.tr(),
        rightIcon: Icons.check_rounded,
        rightColor: AppColors.green200,
        onRightTap: onComplete,
      ),

      TaskStatus.paused => _doubleButton(
        leftText: 'worker_task_details.resume_task'.tr(),
        leftIcon: Icons.play_arrow_rounded,
        leftColor: AppColors.primary200,
        onLeftTap: onResume,
        rightText: 'worker_task_details.finish'.tr(),
        rightIcon: Icons.check_rounded,
        rightColor: AppColors.green200,
        onRightTap: onComplete,
      ),

      _ => const SizedBox.shrink(),
    };
  }

  Widget _singleButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomTextButton(
      text: text,
      onPressed: onTap,
      isLoading: isLoading,
      backgroundColor: color,
      foregroundColor: Colors.white,
      prefixIcon: Icon(icon),
      size: CustomButtonSize.small,
    );
  }

  Widget _doubleButton({
    required String leftText,
    required IconData leftIcon,
    required Color leftColor,
    required VoidCallback onLeftTap,
    required String rightText,
    required IconData rightIcon,
    required Color rightColor,
    required VoidCallback onRightTap,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomTextButton.outlined(
            text: leftText,
            onPressed: onLeftTap,
            isLoading: false,
            foregroundColor: leftColor,
            borderColor: leftColor,
            prefixIcon: Icon(leftIcon),
            size: CustomButtonSize.small,
          ),
        ),
        horizontalSpacing(12),
        Expanded(
          flex: 3,
          child: CustomTextButton(
            text: rightText,
            onPressed: onRightTap,
            isLoading: isLoading,
            backgroundColor: rightColor,
            foregroundColor: Colors.white,
            prefixIcon: Icon(rightIcon),
            size: CustomButtonSize.small,
          ),
        ),
      ],
    );
  }
}
