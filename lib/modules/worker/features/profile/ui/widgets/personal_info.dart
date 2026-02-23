import 'package:flutter/material.dart';
import 'profile_header.dart';
import 'shift_statistics.dart';

/// Personal information section combining profile header and statistics
class PersonalInfo extends StatelessWidget {
  const PersonalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProfileHeader(),
        const SizedBox(height: 40),
        const ShiftStatistics(),
      ],
    );
  }
}








