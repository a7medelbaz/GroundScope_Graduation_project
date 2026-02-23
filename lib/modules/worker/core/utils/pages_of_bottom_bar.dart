import 'package:flutter/material.dart';
import '../../features/notifications/ui/notifications_screen.dart';
import '../../features/reports/ui/reports_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/profile/ui/profile_screen.dart';

final List<Widget> pagesOfWorkerBottomNaveBar = [
  const HomeScreen(),
  const ReportsScreen(),
  const NotificationsScreen(),
  const ProfileScreen(),
];
