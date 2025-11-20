import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Worker Notifications Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
