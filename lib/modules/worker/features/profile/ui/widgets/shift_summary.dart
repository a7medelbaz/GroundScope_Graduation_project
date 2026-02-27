import 'package:flutter/material.dart';
import 'task_history_item.dart';

class ShiftSummary extends StatelessWidget {
  const ShiftSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shift Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        TaskHistoryItem(
          title: 'Baggage Handling',
          timeRange: '10:00 AM - 11:00 AM',
        ),
        SizedBox(height: 12),
        TaskHistoryItem(
          title: 'Aircraft Refueling',
          timeRange: '11:00 AM - 12:00 PM',
        ),
        SizedBox(height: 12),
        TaskHistoryItem(
          title: 'Cabin Cleaning',
          timeRange: '12:00 PM - 1:00 PM',
        ),
        SizedBox(height: 12),
        TaskHistoryItem(
          title: 'Passenger Assistance',
          timeRange: '1:00 PM - 2:00 PM',
        ),
      ],
    );
  }
}








