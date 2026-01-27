import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/modules/worker/features/notifications/data/models/notification_model.dart';
import 'package:ground_scope/modules/worker/features/notifications/ui/widgets/notification_item_widget.dart';

class NotificationList extends StatefulWidget {
  final List<NotificationModel> notifications;

  const NotificationList({super.key, required this.notifications});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.notifications.isEmpty) {
      return Container(
        color: AppColors.darkBlue,
        child: Center(
          child: Text(
            'No notifications',
            style: AppTextStyles.font16greyRegular.copyWith(fontSize: 16.sp),
          ),
        ),
      );
    }

    return Container(
      color: AppColors.darkBlue,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: 16.h,
        ),
        itemCount: widget.notifications.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: AppColors.dividerDark,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: NotificationItemWidget(
              notification: widget.notifications[index],
            ),
          );
        },
      ),
    );
  }
}

