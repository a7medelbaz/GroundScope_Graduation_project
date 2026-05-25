import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AdminDashboardStatsShimmer extends StatelessWidget {
  const AdminDashboardStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: rw(12),
        mainAxisSpacing: rh(12),
        childAspectRatio: 1.2,
      ),
      itemCount: 4,
      itemBuilder: (context, _) => _ShimmerStatCard()
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1500.ms, color: context.customColors.surfaceVariant),
    );
  }
}

class _ShimmerStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: context.customColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: rw(36),
            height: rw(36),
            decoration: BoxDecoration(
              color: context.customColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          verticalSpacing(8),
          Container(
            width: rw(40),
            height: rh(28),
            decoration: BoxDecoration(
              color: context.customColors.surfaceVariant,
              borderRadius: BorderRadius.circular(rr(6)),
            ),
          ),
          verticalSpacing(6),
          Container(
            width: rw(80),
            height: rh(12),
            decoration: BoxDecoration(
              color: context.customColors.surfaceVariant,
              borderRadius: BorderRadius.circular(rr(4)),
            ),
          ),
        ],
      ),
    );
  }
}
