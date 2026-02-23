import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_components/timer_box.dart';

/// Timer display section widget
/// Displays task timer with hours, minutes, and seconds
class TimerDisplay extends StatelessWidget {
  final int hours;
  final int minutes;
  final int seconds;

  const TimerDisplay({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Timer',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 28 / 18, // Line Height: 28px / Font Size: 18px
            color: const Color(0xFFF4F4F5),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TimerBox(
                value: hours.toString().padLeft(2, '0'),
                label: 'Hours',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TimerBox(
                value: minutes.toString().padLeft(2, '0'),
                label: 'Minutes',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TimerBox(
                value: seconds.toString().padLeft(2, '0'),
                label: 'Seconds',
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Timer auto-started upon entering geofence.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF8B95A5),
          ),
        ),
      ],
    );
  }
}




