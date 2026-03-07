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
              firstName: 'Mustafa',
              id: '123',
              email: 'mustafa@example.com',
              lastName: 'Elbaz',
              imageUrl:
                  'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
              position: 'Ramp Agent, Unit 3',
            ),
          ),

          const WorkerTasksListView(tasks: _tasks),
        ],
      ),
    );
  }
}
