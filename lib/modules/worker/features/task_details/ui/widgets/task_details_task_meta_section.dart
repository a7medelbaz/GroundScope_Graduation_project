import 'package:flutter/material.dart';
import 'package:ground_scope/core/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class TaskDetailsTaskMetaSection extends StatelessWidget {
  const TaskDetailsTaskMetaSection({super.key, required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    String fmt(DateTime? dt) {
      if (dt == null) return '—';
      return '${dt.day}/${dt.month}/${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: rw(4),
              height: rh(18),
              decoration: BoxDecoration(
                color: AppColors.primary200,
                borderRadius: BorderRadius.circular(rr(2)),
              ),
            ),
            horizontalSpacing(10),
            Text(
              'Task Info',
              style: AppTextStyles.font18ExtraBold.copyWith(
                color: cc.textPrimary,
              ),
            ),
          ],
        ),
        verticalSpacing(12),
        Container(
          decoration: BoxDecoration(
            color: cc.surface,
            borderRadius: BorderRadius.circular(rr(12)),
            border: Border.all(color: cc.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              _MetaRow(
                label: 'Task ID',
                value: task.id.substring(0, 8).toUpperCase(),
              ),
              _MetaDivider(),
              _MetaRow(label: 'Created At', value: fmt(task.createdAt)),
              _MetaDivider(),
              _MetaRow(label: 'Last Updated', value: fmt(task.updatedAt)),
              if (task.actualStart != null) ...[
                _MetaDivider(),
                _MetaRow(label: 'Actual Start', value: fmt(task.actualStart)),
              ],
              if (task.actualEnd != null) ...[
                _MetaDivider(),
                _MetaRow(label: 'Actual End', value: fmt(task.actualEnd)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(11)),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.font12Light.copyWith(color: cc.textHint),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.font12SemiBold.copyWith(
              color: cc.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.customColors.divider,
      indent: rw(14),
      endIndent: rw(14),
    );
  }
}
