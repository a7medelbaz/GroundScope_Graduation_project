import 'package:flutter/material.dart';

class WorkerScreen extends StatelessWidget {
  const WorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Worker Screen',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
