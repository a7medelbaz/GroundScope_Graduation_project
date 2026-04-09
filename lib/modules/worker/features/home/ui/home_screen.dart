import 'package:flutter/material.dart';

import '../../../../../core/auth/data/models/user_date.dart';
import '../data/models/task_model.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/worker_tasks_list_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<TaskModel> _tasks = [
    TaskModel(
      title: 'Baggage Handling',
      timeRange: '07:30 - 08:30',
      location: 'A321, Stand 12',
      progress: 0.4,
      status: TaskStatus.inProgress,
      icon: Icons.luggage,
    ),
    TaskModel(
      title: 'Cabin Cleaning',
      timeRange: '09:30 - 10:30',
      location: 'A321, Stand 12',
      progress: 1.0,
      status: TaskStatus.done,
      icon: Icons.cleaning_services,
    ),
    TaskModel(
      title: 'Aircraft Refueling',
      timeRange: '08:45 - 09:15',
      location: 'A321, Stand 12',
      progress: 0.0,
      status: TaskStatus.pending,
      icon: Icons.local_gas_station,
    ),
    TaskModel(
      title: 'Baggage Handling',
      timeRange: '07:30 - 08:30',
      location: 'A321, Stand 12',
      progress: 0.4,
      status: TaskStatus.inProgress,
      icon: Icons.luggage,
    ),
    TaskModel(
      title: 'Cabin Cleaning',
      timeRange: '09:30 - 10:30',
      location: 'A321, Stand 12',
      progress: 1.0,
      status: TaskStatus.done,
      icon: Icons.cleaning_services,
    ),
    TaskModel(
      title: 'Aircraft Refueling',
      timeRange: '08:45 - 09:15',
      location: 'A321, Stand 12',
      progress: 0.0,
      status: TaskStatus.pending,
      icon: Icons.local_gas_station,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeAppBar(
            userModel: UserModel(
              fullName: 'Mustafa',
              id: '123',
              email: 'mustafa@example.com',
              role: 'unit_manager',
              isActive: true,
              createdAt: DateTime.now(),
            ),
          ),

          const WorkerTasksListView(tasks: _tasks),
        ],
      ),
    );
  }
}
