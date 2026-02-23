import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/checklist_item.dart';

/// Single checklist item widget with checkbox functionality
/// Used in the checklist section
class ChecklistItemWidget extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool?> onChanged;
  final bool isLast;

  const ChecklistItemWidget({
    super.key,
    required this.item,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(!item.checked),
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.checked
                    ? const Color(0xFF1A2633)
                    : Colors.transparent,
                border: Border.all(
                  color: item.checked
                      ? const Color(0xFF1A2633)
                      : const Color(0xFF8B95A5),
                  width: 2,
                ),
              ),
              child: item.checked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: item.checked ? const Color(0xFFF4F4F5).withOpacity(0.7) : const Color(0xFFF4F4F5),
                decoration: item.checked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




