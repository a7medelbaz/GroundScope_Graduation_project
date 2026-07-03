import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/notifications/data/models/notification_model.dart';
import 'package:ground_scope/core/notifications/logic/cubit/notification_cubit.dart';
import 'package:ground_scope/core/notifications/service/notification_navigator.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';
import 'package:ground_scope/core/widgets/gradient_header.dart';

class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({super.key, required this.notification});

  final NotificationModel notification;

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.notification.isRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<NotificationCubit>().markAsRead(widget.notification.id);
      });
    }
  }

  bool get _hasRelated =>
      widget.notification.referenceId != null &&
      widget.notification.referenceType != null &&
      _isHandledType(widget.notification.type.toDbString);

  bool _isHandledType(String typeStr) {
    return typeStr == 'report' ||
        typeStr == 'alert' ||
        typeStr == 'task_assigned' ||
        typeStr == 'flight_landed';
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final notification = widget.notification;

    return Scaffold(
      backgroundColor: cc.background,
      body: Column(
        children: [
          GradientHeader(
            title: 'notification_details'.tr(),
            trailing: Container(
              padding: EdgeInsets.symmetric(
                horizontal: rw(10),
                vertical: rh(4),
              ),
              decoration: BoxDecoration(
                color: notification.type.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(rr(8)),
                border: Border.all(
                  color: notification.type.color.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                notification.type.labelKey.tr(),
                style: AppTextStyles.font12SemiBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: rw(52),
                  height: rw(52),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(rr(14)),
                  ),
                  child: Icon(
                    notification.type.icon,
                    color: AppColors.white,
                    size: rf(26),
                  ),
                ),
                horizontalSpacing(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: AppTextStyles.font16SemiBold.copyWith(
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpacing(2),
                      Text(
                        notification.createdAt.timeAgo,
                        style: AppTextStyles.font12Light.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(rw(20), rh(20), rw(20), rh(40)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message section
                  _SectionCard(
                    title: 'message'.tr(),
                    child: Text(
                      notification.body,
                      style: AppTextStyles.font14Light.copyWith(
                        color: cc.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  verticalSpacing(24),

                  // Details section
                  _SectionCard(
                    title: 'details'.tr(),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'type'.tr(),
                          value: notification.type.labelKey.tr(),
                          valueColor: notification.type.color,
                        ),
                        _Divider(cc: cc),
                        _InfoRow(
                          label: 'received'.tr(),
                          value:
                              '${notification.createdAt.formattedDate} · ${notification.createdAt.formattedTime}',
                          valueColor: cc.textSecondary,
                        ),
                        _Divider(cc: cc),
                        _InfoRow(
                          label: 'status'.tr(),
                          value: notification.isRead ? 'read'.tr() : 'unread'.tr(),
                          valueColor: notification.isRead
                              ? AppColors.green200
                              : AppColors.primary200,
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(24),

                  // View related button
                  if (_hasRelated)
                    CustomTextButton(
                      text: 'notification.view_related'.tr(),
                      onPressed: () =>
                          NotificationNavigator.navigateToReference(
                        context,
                        notification,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.font12SemiBold.copyWith(
            color: cc.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        verticalSpacing(10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(rw(14)),
          decoration: BoxDecoration(
            color: cc.surface,
            borderRadius: BorderRadius.circular(rr(14)),
            border: Border.all(color: cc.border.withValues(alpha: 0.5)),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(10)),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.font12Light.copyWith(
              color: cc.textHint,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.font12SemiBold.copyWith(
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.cc});

  final dynamic cc;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: (cc as dynamic).divider,
    );
  }
}
