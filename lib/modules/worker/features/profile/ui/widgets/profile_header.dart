import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Picture
        Container(
          margin: const EdgeInsets.only(top: 24, bottom: 16),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF374151), // Background fallback
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile_picture.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF374151),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 60,
                  ),
                );
              },
            ),
          ),
        ),
        // Name
        const Text(
          'Ethan Carter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Unit
        const Text(
          'Unit 3',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        // Shift Time
        const Text(
          'Shift: 8:00 AM - 4:00 PM',
          style: TextStyle(
            color: Color(0xFFB0B0B0),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}








