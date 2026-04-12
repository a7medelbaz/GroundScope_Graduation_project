import 'package:flutter/material.dart';

enum EventType { system, action, pause, complete }

class TaskTimelineModel {
  const TaskTimelineModel({
    required this.time,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.type,
  });
  final DateTime time;
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final EventType type;
}
