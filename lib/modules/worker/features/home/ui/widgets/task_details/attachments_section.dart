import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_components/quick_report_button.dart';

/// Attachments section widget
/// Displays attachments title and Quick Report button
class AttachmentsSection extends StatelessWidget {
  final VoidCallback onQuickReportPressed;

  const AttachmentsSection({
    super.key,
    required this.onQuickReportPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
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
          child: QuickReportButton(
            onPressed: onQuickReportPressed,
          ),
        ),
      ],
    );
  }
}




