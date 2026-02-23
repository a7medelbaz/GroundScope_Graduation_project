import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Detail row widget for displaying flight information
/// Used for stand and ETA information in the header section
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8B95A5), size: 18),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF8B95A5),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}




