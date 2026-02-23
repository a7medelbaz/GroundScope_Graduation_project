import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashed_border_painter.dart';

/// Photo upload section with dashed border container
/// Handles camera/photo picker functionality
class PhotoSection extends StatelessWidget {
  final VoidCallback onTap;

  const PhotoSection({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photo (optional)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFCBD5E1),
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 358.w,
            height: 200.h,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: const Color(0xFF334155),
                strokeWidth: 2,
                dashWidth: 6,
                dashSpace: 4,
                borderRadius: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Camera icon button
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E293B).withOpacity(0.5),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFFCBD5E1),
                      size: 24,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Tap to add photo',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF8FAFC),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Up to 5MB',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}




