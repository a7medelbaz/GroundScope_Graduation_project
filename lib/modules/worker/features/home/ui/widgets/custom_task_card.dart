import 'package:flutter/material.dart';

class CustomTaskCard extends StatelessWidget {
  final String title;
  final String timeRange;
  final String extraInfo;
  final double progress;
  final TaskStatus status;

  const CustomTaskCard({
    super.key,
    required this.title,
    required this.timeRange,
    required this.extraInfo,
    required this.progress,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case TaskStatus.inProgress:
        return const Color(0xFFFACC15); // yellow (matches your label)
      case TaskStatus.done:
        return const Color(0xFF22C55E); // green
      case TaskStatus.pending:
        return const Color(0xFF9CA3AF); // grey
    }
  }

  String get statusText {
    switch (status) {
      case TaskStatus.inProgress:
        return "In-progress";
      case TaskStatus.done:
        return "Done";
      case TaskStatus.pending:
        return "Pending";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1520), // exact dark card color like your image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON + TITLE + STATUS LABEL
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle (blue background)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF082F49),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.luggage, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 14),

              // Title + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Time + info
                    Text(
                      "$timeRange | $extraInfo",
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress %
          Text(
            "${(progress * 100).toInt()} %",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          // Custom progress bar EXACT like the image
          Container(
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFF374151), // background bar
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  color: const Color(0xFF3B82F6), // blue progress EXACT like image
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum TaskStatus { inProgress, done, pending }
