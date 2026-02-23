import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'metadata_row.dart';

/// Metadata section displaying Location, Timestamp, and Worker ID
/// Uses horizontal layout with vertical and horizontal dividers
class MetadataSection extends StatelessWidget {
  final String? location;
  final String timestamp;
  final String? workerId;

  const MetadataSection({
    super.key,
    this.location,
    required this.timestamp,
    this.workerId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metadata',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFCBD5E1),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: 358.w,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Row 1: Location
              MetadataRow(
                label: 'Location',
                value: location ?? 'Gate A12',
              ),
              // Horizontal divider between Location and Timestamp
              Container(
                width: double.infinity,
                height: 1,
                margin: EdgeInsets.symmetric(vertical: 16.h),
                color: const Color(0xFF334155).withOpacity(0.5),
              ),
              // Row 2: Timestamp
              MetadataRow(
                label: 'Timestamp',
                value: timestamp,
              ),
              // Horizontal divider between Timestamp and Worker ID
              Container(
                width: double.infinity,
                height: 1,
                margin: EdgeInsets.symmetric(vertical: 16.h),
                color: const Color(0xFF334155).withOpacity(0.5),
              ),
              // Row 3: Worker ID
              MetadataRow(
                label: 'Worker ID',
                value: workerId ?? 'W123456',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

