import 'package:flutter/material.dart';
import 'package:ground_scope/modules/worker/features/home/ui/notifications_screen.dart';
import 'package:ground_scope/modules/worker/features/home/ui/reports_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/home/ui/profile_screen.dart';

final List<Widget> pagesOfWorkerBottomNaveBar = [
  const HomeScreen(),
  const ReportsScreen(),
  const NotificationsScreen(),
  const ProfileScreen(),
];
