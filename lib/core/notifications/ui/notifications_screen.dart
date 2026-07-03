import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/notifications/data/models/notification_model.dart';
import 'package:ground_scope/core/notifications/logic/cubit/notification_cubit.dart';
import 'package:ground_scope/core/notifications/service/notification_navigator.dart';
import 'package:ground_scope/core/service/user_service.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:get_it/get_it.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().load();
  }

  Future<void> _markAllRead() async {
    final user = await GetIt.instance<UserService>().getUser();
    if (user != null && mounted) {
      context.read<NotificationCubit>().markAllAsRead(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Scaffold(
      backgroundColor: cc.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onMarkAllRead: _markAllRead),
            Expanded(
              child: BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  if (state.status == NotificationListStatus.loading) {
                    return _ShimmerList();
                  }

                  if (state.notifications.isEmpty) {
                    return _EmptyState();
                  }

                  return RefreshIndicator(
                    color: AppColors.primary200,
                    onRefresh: () =>
                        context.read<NotificationCubit>().load(),
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(16),
                        vertical: rh(8),
                      ),
                      children: [
                        if (state.unread.isNotEmpty) ...[
                          _SectionLabel(
                            label: 'unread'.tr(),
                            count: state.unread.length,
                          ),
                          ...state.unread.map(
                            (n) => _NotificationTile(notification: n),
                          ),
                          SizedBox(height: rh(8)),
                        ],
                        if (state.read.isNotEmpty) ...[
                          _SectionLabel(label: 'earlier'.tr()),
                          ...state.read.map(
                            (n) => _NotificationTile(notification: n),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onMarkAllRead});
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final canPop = Navigator.of(context).canPop();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(12), vertical: rh(14)),
      decoration: BoxDecoration(
        color: cc.surface,
        border: Border(bottom: BorderSide(color: cc.border, width: 0.5)),
      ),
      child: Row(
        children: [
          if (canPop)
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: rw(36),
                height: rw(36),
                decoration: BoxDecoration(
                  color: cc.surfaceVariant,
                  borderRadius: BorderRadius.circular(rr(10)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: rf(16),
                  color: cc.iconPrimary,
                ),
              ),
            ),
          if (canPop) horizontalSpacing(12),
          Text(
            'notifications'.tr(),
            style:
                AppTextStyles.font18ExtraBold.copyWith(color: cc.textPrimary),
          ),
          const Spacer(),
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return GestureDetector(
                onTap: onMarkAllRead,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(6)),
                  decoration: BoxDecoration(
                    color: AppColors.primary200.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(rr(20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: rf(14),
                        color: AppColors.primary200,
                      ),
                      horizontalSpacing(4),
                      Text(
                        'mark_all_read'.tr(),
                        style: AppTextStyles.font12SemiBold.copyWith(
                          color: AppColors.primary200,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.count});
  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Padding(
      padding: EdgeInsets.only(bottom: rh(8), top: rh(4)),
      child: Row(
        children: [
          Text(
            count != null ? '$label ($count)' : label,
            style: AppTextStyles.font12SemiBold.copyWith(
              color: cc.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});
  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: () {
        context.read<NotificationCubit>().markAsRead(notification.id);
        NotificationNavigator.navigateToReference(context, notification);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: rh(8)),
        padding: EdgeInsets.all(rw(12)),
        decoration: BoxDecoration(
          color: isUnread
              ? notification.type.color.withValues(alpha: 0.07)
              : cc.surface,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(
            color: isUnread
                ? notification.type.color.withValues(alpha: 0.25)
                : cc.border,
            width: 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: rw(36),
              height: rw(36),
              decoration: BoxDecoration(
                color: notification.type.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(rr(10)),
              ),
              child: Icon(
                notification.type.icon,
                color: notification.type.color,
                size: rf(18),
              ),
            ),
            SizedBox(width: rw(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(8),
                          vertical: rh(3),
                        ),
                        decoration: BoxDecoration(
                          color: notification.type.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(rr(6)),
                        ),
                        child: Text(
                          notification.type.labelKey.tr(),
                          style: AppTextStyles.font12SemiBold.copyWith(
                            color: notification.type.color,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        notification.createdAt.timeAgo,
                        style: AppTextStyles.font12Light.copyWith(
                          color: cc.textHint,
                        ),
                      ),
                      if (isUnread) ...[
                        SizedBox(width: rw(4)),
                        Container(
                          width: rw(6),
                          height: rw(6),
                          decoration: BoxDecoration(
                            color: notification.type.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: rh(4)),
                  Text(
                    notification.title,
                    style: isUnread
                        ? AppTextStyles.font14SemiBold
                            .copyWith(color: cc.textPrimary)
                        : AppTextStyles.font14Light
                            .copyWith(color: cc.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: rh(2)),
                  Text(
                    notification.body,
                    style: AppTextStyles.font12Light.copyWith(
                      color: cc.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(
          begin: 0.08,
          end: 0,
          duration: 250.ms,
          curve: Curves.easeOut,
        );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: rf(64),
            color: cc.textSecondary.withValues(alpha: 0.4),
          ),
          SizedBox(height: rh(16)),
          Text(
            'no_notifications'.tr(),
            style: AppTextStyles.font16SemiBold.copyWith(
              color: cc.textSecondary,
            ),
          ),
          SizedBox(height: rh(4)),
          Text(
            'no_notifications_subtitle'.tr(),
            style: AppTextStyles.font12Light.copyWith(
              color: cc.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(12)),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        margin: EdgeInsets.only(bottom: rh(10)),
        padding: EdgeInsets.all(rw(12)),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(color: cc.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: rw(36), height: rw(36), radius: rr(10)),
            horizontalSpacing(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: rw(70), height: rh(12), radius: rr(4)),
                  verticalSpacing(8),
                  _ShimmerBox(
                      width: double.infinity, height: rh(12), radius: rr(4)),
                  verticalSpacing(6),
                  _ShimmerBox(width: rw(180), height: rh(10), radius: rr(4)),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 1100.ms,
            color: cc.surfaceVariant.withValues(alpha: 0.6),
          ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.customColors.surfaceVariant,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
