import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/worker_assets.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // padding: EdgeInsets.only(right: 23.5.w, left: 23.5, top: 20.h),
      padding: EdgeInsets.only(top: 20.h),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            /// --- Profile Image ---
            Container(
              height: 48.w,
              width: 48.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(WorkerAssets.workerTest),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            /// --- Name & Job ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ethan Carter",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Ramp Agent, Unit 3",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            /// --- Vertical Divider ---
            Container(
              height: 25.h,
              width: 2.w,
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),

            SizedBox(width: 12.w),

            /// --- Shift Time ---
            Text(
              "07:00–15:00",
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),

            SizedBox(width: 8.w),

            /// --- Online Dot ---
            Container(
              height: 10.w,
              width: 10.w,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
