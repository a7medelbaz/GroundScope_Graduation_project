import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';

import '../../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../../core/utils/spacing.dart';
import '../../../../../../../core/widgets/custom_text_button.dart';
import '../../../data/models/task_filter_model.dart';
import '../../../data/models/task_model.dart';
import 'custom_filter_chip.dart';

class TaskFilterBottomSheet extends StatefulWidget {
  const TaskFilterBottomSheet({super.key, required this.initial});

  final TaskFilter initial;

  static Future<TaskFilter?> show(BuildContext context, TaskFilter current) {
    return showModalBottomSheet<TaskFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.customColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(rr(24))),
      ),
      builder: (_) => TaskFilterBottomSheet(initial: current),
    );
  }

  @override
  State<TaskFilterBottomSheet> createState() => _TaskFilterBottomSheetState();
}

class _TaskFilterBottomSheetState extends State<TaskFilterBottomSheet> {
  late TaskFilter _filter;

  static const _timeOptions = [null, 1, 4, 8, 12, 24];
  static const _statusOptions = [
    null,
    TaskStatus.pending,
    TaskStatus.inProgress,
    TaskStatus.done,
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(rw(20), rh(20), rw(20), rh(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(context),
          verticalSpacing(20),
          Row(
            children: [
              const Text('Filter Tasks', style: AppTextStyles.font16ExtraBold),
              const Spacer(),
              if (_filter.isActive)
                GestureDetector(
                  onTap: () => setState(() => _filter = TaskFilter.empty),

                  child: Text(
                    'Reset',
                    style: AppTextStyles.font16Light.copyWith(
                      color: context.customColors.background,
                    ),
                  ),
                ),
            ],
          ),
          verticalSpacing(20),
          const Text('Status', style: AppTextStyles.font14Light),
          verticalSpacing(10),
          Wrap(
            spacing: rw(8),
            children: _statusOptions
                .map(
                  (status) => CustomFilterChip(
                    label: status == null ? 'All' : status.name,
                    isSelected: _filter.status == status,
                    onTap: () => setState(
                      () => _filter = TaskFilter(
                        status: status,
                        hours: _filter.hours,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          verticalSpacing(20),
          const Text('Time Range', style: AppTextStyles.font14Light),
          verticalSpacing(10),
          Wrap(
            spacing: rw(8),
            runSpacing: rh(8),
            children: _timeOptions
                .map(
                  (hours) => CustomFilterChip(
                    label: hours == null ? 'All' : 'Last ${hours}h',
                    isSelected: _filter.hours == hours,
                    onTap: () => setState(
                      () => _filter = TaskFilter(
                        status: _filter.status,
                        hours: hours,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          verticalSpacing(24),
          SizedBox(
            width: double.infinity,
            child: CustomTextButton(
              text: 'Apply',
              onPressed: () => Navigator.pop(context, _filter),
              size: CustomButtonSize.small,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Center(
      child: Container(
        width: rw(40),
        height: rh(4),
        decoration: BoxDecoration(
          color: context.customColors.divider,
          borderRadius: BorderRadius.circular(rr(8)),
        ),
      ),
    );
  }
}
