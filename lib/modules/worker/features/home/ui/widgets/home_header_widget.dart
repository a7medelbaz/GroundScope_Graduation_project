import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions.dart';
import '../../../profile/ui/profile_screen.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfilePicture(context),
        const SizedBox(width: 16),
        Expanded(
          child: _buildWorkerInfo(context),
        ),
        _buildShiftIndicator(),
      ],
    );
  }

  Widget _buildProfilePicture(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushSlideRight(const ProfileScreen());
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF374151), // Background fallback
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/profile_picture.png',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF374151),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            context.pushSlideRight(const ProfileScreen());
          },
          child: const Text(
            'Ethan Carter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ramp Agent, Unit 3',
          style: TextStyle(
            color: Color(0xFFB0B0B0),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildShiftIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '07:00 - 15:00',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

