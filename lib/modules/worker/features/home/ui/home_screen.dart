import 'package:flutter/material.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/task_list_widget.dart';
import '../data/models/task_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Task> _tasks = [
    const Task(
      title: 'Baggage Handling',
      statusLabel: 'In-progress',
      status: TaskStatus.inProgress,
      timeRange: '07:30 - 08:30',
      aircraftInfo: 'A321, Stand12',
      progress: 40,
      icon: Icons.luggage_outlined,
      iconColor: Color(0xFF1585F4),
      iconBackgroundColor: Color(0xFF123961),
    ),
    const Task(
      title: 'Cabin Cleaning',
      statusLabel: 'Done',
      status: TaskStatus.done,
      timeRange: '09:30 - 10:30',
      aircraftInfo: 'A321, Stand 12',
      progress: 100,
      icon: Icons.cleaning_services_outlined,
      iconColor: Color(0xFF22C55E),
      iconBackgroundColor: Color(0xFF1FA753),
    ),
    const Task(
      title: 'Aircraft Refueling',
      statusLabel: 'Pending',
      status: TaskStatus.pending,
      timeRange: '08:45 - 09:15',
      aircraftInfo: 'A321, Stand 12',
      progress: 0,
      icon: Icons.local_gas_station_outlined,
      iconColor: Color(0xFF1580EB),
      iconBackgroundColor: Color(0xFF123961),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                const HomeHeaderWidget(),
                const SizedBox(height: 56),
                TaskListWidget(tasks: _tasks),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
