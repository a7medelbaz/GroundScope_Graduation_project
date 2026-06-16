import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class StandSkeletonTile extends StatelessWidget {
  const StandSkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: rh(8)),
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: context.customColors.border),
      ),
      child: Row(
        children: [
          _Bone(width: rw(48), height: rh(48), radius: rr(12)),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: rw(80), height: rh(14), radius: rr(4)),
                verticalSpacing(6),
                _Bone(width: double.infinity, height: rh(11), radius: rr(4)),
                verticalSpacing(6),
                _Bone(width: rw(100), height: rh(11), radius: rr(4)),
              ],
            ),
          ),
          horizontalSpacing(12),
          _Bone(width: rw(48), height: rh(28), radius: rr(14)),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1500.ms, color: context.customColors.surfaceVariant);
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.customColors.surfaceVariant,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
