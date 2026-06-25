import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/notifications/logic/cubit/notification_cubit.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: rw(44),
                height: rw(44),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.2)),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              if (state.unreadCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: EdgeInsets.all(rw(3)),
                    decoration: const BoxDecoration(
                      color: AppColors.red200,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: rw(16),
                      minHeight: rw(16),
                    ),
                    child: Text(
                      state.unreadCount > 99
                          ? '99+'
                          : '${state.unreadCount}',
                      style: AppTextStyles.font12ExtraBold.copyWith(
                        color: AppColors.white,
                        fontSize: rf(9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
