import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/shift_statistics.dart';
import 'widgets/shift_summary.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Profile Title
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                // Profile Section
                const ProfileHeader(),
                const SizedBox(height: 40),
                // Shift Statistics
                const ShiftStatistics(),
                const SizedBox(height: 32),
                // Shift Summary
                const ShiftSummary(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}








