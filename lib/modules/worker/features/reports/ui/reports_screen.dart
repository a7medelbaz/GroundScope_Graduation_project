import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Worker Report Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
