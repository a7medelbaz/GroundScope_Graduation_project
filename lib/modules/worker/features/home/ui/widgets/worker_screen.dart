import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/modules/worker/core/utils/pages_of_bottom_bar.dart';

class WorkerScreen extends StatefulWidget {
  const WorkerScreen({super.key});

  @override
  State<WorkerScreen> createState() => _WorkerScreenState();
}

class _WorkerScreenState extends State<WorkerScreen> {
  int currentIndex = 0;
  int selectedIndex = 0;
  navigateBottomBar(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: pagesOfWorkerBottomNaveBar[selectedIndex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.lightBlue,
        unselectedItemColor: AppColors.grayColor,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.shifting,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          // Home
          BottomNavigationBarItem(
            backgroundColor: AppColors.darkBlue,
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          // Reports
          BottomNavigationBarItem(
            backgroundColor: AppColors.darkBlue,
            icon: Icon(Icons.article_outlined),
            label: 'Reports',
          ),
          // Notifications
          BottomNavigationBarItem(
            backgroundColor: AppColors.darkBlue,
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
          // Profile
          BottomNavigationBarItem(
            backgroundColor: AppColors.darkBlue,
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
