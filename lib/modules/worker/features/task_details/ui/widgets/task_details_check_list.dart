import 'package:flutter/material.dart';
import 'package:ground_scope/core/extensions/context_extensions.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class TaskDetailsCheckList extends StatefulWidget {
  const TaskDetailsCheckList({super.key, required this.statusColor});

  final Color statusColor;

  @override
  State<TaskDetailsCheckList> createState() => _TaskDetailsCheckListState();
}

class _TaskDetailsCheckListState extends State<TaskDetailsCheckList> {
  final List<Map<String, dynamic>> checklist = [
    {'title': 'Check equipment', 'done': false},
    {'title': 'Confirm location', 'done': false},
    {'title': 'Safety inspection', 'done': false},
    {'title': 'Report to supervisor', 'done': false},
  ];

  int get completedCount => checklist.where((e) => e['done'] == true).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Checklist', style: AppTextStyles.font16Bold),
            Text(
              '$completedCount/${checklist.length}',
              style: AppTextStyles.font14Regular.copyWith(
                color: widget.statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        verticalSpacing(12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: checklist.length,
          separatorBuilder: (_, __) => verticalSpacing(8),
          itemBuilder: (context, index) {
            final item = checklist[index];
            final isDone = item['done'] as bool;

            return GestureDetector(
              onTap: () {
                setState(() {
                  checklist[index]['done'] = !isDone;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveWidth(16),
                  vertical: responsiveHeight(14),
                ),
                decoration: BoxDecoration(
                  color: isDone
                      ? context.customColors.successContainer
                      : context.customColors.divider.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDone
                        ? context.customColors.successContainer.withValues(
                            alpha: 0.4,
                          )
                        : context.customColors.divider.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    /// Circle indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: responsiveWidth(22),
                      height: responsiveHeight(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.green100 : Colors.transparent,
                        border: Border.all(
                          color: isDone
                              ? context.customColors.successContainer
                              : context.customColors.divider,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    horizontalSpacing(12),
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: AppTextStyles.font14Regular.copyWith(
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: isDone
                              ? context.customColors.textSecondary
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
