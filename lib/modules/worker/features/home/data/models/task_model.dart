import 'package:flutter/material.dart';

class TaskModel {
  final String title;
  final String timeRange;
  final String location;
  final double progress; 
  final TaskStatus status;
  final IconData icon;

  const TaskModel({
    required this.title,
    required this.timeRange,
    required this.location,
    required this.progress,
    required this.status,
    required this.icon,
  });
}

enum TaskStatus { inProgress, done, pending }
