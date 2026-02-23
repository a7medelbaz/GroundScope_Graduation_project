import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/checklist_item.dart';
import 'detail_components/checklist_item_widget.dart';

/// Checklist section widget for Pre-Task Checklist
/// Displays all checklist items with checkboxes
class ChecklistSection extends StatelessWidget {
  final List<ChecklistItem> checklistItems;
  final ValueChanged<int> onItemChanged;

  const ChecklistSection({
    super.key,
    required this.checklistItems,
    required this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pre-Task Checklist',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF4F4F5),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF27272A).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...checklistItems.asMap().entries.map(
                    (entry) {
                      final isLast = entry.key == checklistItems.length - 1;
                      return ChecklistItemWidget(
                        item: entry.value,
                        isLast: isLast,
                        onChanged: (value) {
                          onItemChanged(entry.key);
                        },
                      );
                    },
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

