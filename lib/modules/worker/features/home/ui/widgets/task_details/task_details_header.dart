import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_components/detail_row.dart';

/// Header section widget for Task Details screen
/// Displays flight info, task title, stand, and ETA
class TaskDetailsHeader extends StatelessWidget {
  final String flightInfo;
  final String taskTitle;
  final String stand;
  final String eta;

  const TaskDetailsHeader({
    super.key,
    required this.flightInfo,
    required this.taskTitle,
    required this.stand,
    required this.eta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF27272A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            flightInfo,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF4F4F5),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            taskTitle,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF4F4F5),
            ),
          ),
          SizedBox(height: 16.h),
          DetailRow(icon: Icons.tag, label: '# Stand: $stand'),
          SizedBox(height: 10.h),
          DetailRow(
            icon: Icons.schedule,
            label: 'ETA: $eta',
          ),
        ],
      ),
    );
  }
}




