import 'package:flutter/material.dart';

class ShiftStatistics extends StatelessWidget {
  const ShiftStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatContainer('12', 'Tasks', 108.67),
          const SizedBox(width: 16),
          _buildStatContainer('92%', 'On-time', 108.67),
          const SizedBox(width: 16),
          _buildStatContainer('7h 30m', 'Duration', 120),
        ],
      ),
    );
  }

  Widget _buildStatContainer(String value, String label, double width) {
    final isDuration = value == '7h 30m';
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 39),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty)
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: isDuration ? TextOverflow.clip : TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.33, // Line height 32px / font size 24px
              ),
            ),
          if (value.isNotEmpty && label.isNotEmpty)
            const SizedBox(height: 4), // Minimal spacing
          if (label.isNotEmpty)
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43, // Line height 20px / font size 14px
              ),
            ),
        ],
      ),
    );
  }
}








