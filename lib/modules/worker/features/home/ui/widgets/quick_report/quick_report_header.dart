import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header widget for Quick Report screen
/// Displays the title and close button
class QuickReportHeader extends StatelessWidget {
  const QuickReportHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78.h,
      padding: EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF101922).withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quick Report',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 28 / 18,
              color: const Color(0xFFF8FAFC),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Color(0xFFF8FAFC),
              size: 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}




