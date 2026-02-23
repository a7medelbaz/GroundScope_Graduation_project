import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable metadata row widget with label and value
/// Used for Location, Timestamp, and Worker ID rows in metadata section
class MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const MetadataRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFCBD5E1),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }
}

