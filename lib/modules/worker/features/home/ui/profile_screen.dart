import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Worker Profile Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
