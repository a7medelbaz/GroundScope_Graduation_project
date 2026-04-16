import 'package:flutter/material.dart';
import 'checklist_row.dart';

import '../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../data/models/checklist_item_model.dart';

class TaskDetailsChecklist extends StatelessWidget {
  const TaskDetailsChecklist({
    super.key,
    required this.items,
    required this.taskStatus,
    required this.onToggle,
  });

  final List<ChecklistItemModel> items;
  final TaskStatus taskStatus;
  final void Function(ChecklistItemModel item) onToggle;

  bool get _canCheck => taskStatus == TaskStatus.inProgress;

  int get _doneCount => items.where((i) => i.isChecked).length;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final progress = items.isEmpty ? 0.0 : _doneCount / items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────
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
              'Checklist',
              style: AppTextStyles.font18ExtraBold.copyWith(
                color: cc.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '$_doneCount / ${items.length}',
              style: AppTextStyles.font14SemiBold.copyWith(
                color: AppColors.primary200,
              ),
            ),
          ],
        ),
        verticalSpacing(12),
        ClipRRect(
          borderRadius: BorderRadius.circular(rr(4)),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: rh(6),
            backgroundColor: AppColors.primary200.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary200),
          ),
        ),
        verticalSpacing(32),
        if (items.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: rh(16)),
              child: Text(
                'No checklist items for this task',
                style: AppTextStyles.font14Light.copyWith(color: cc.textHint),
              ),
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => verticalSpacing(8),
            itemBuilder: (context, index) {
              final item = items[index];
              return ChecklistRow(
                item: item,
                index: index,
                canCheck: _canCheck,
                onToggle: () => onToggle(item),
              );
            },
          ),
      ],
    );
  }
}
