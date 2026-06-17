import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class UnitSkeletonTile extends StatefulWidget {
  const UnitSkeletonTile({super.key});

  @override
  State<UnitSkeletonTile> createState() => _UnitSkeletonTileState();
}

class _UnitSkeletonTileState extends State<UnitSkeletonTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Opacity(
        opacity: _animation.value,
        child: Container(
          margin: EdgeInsets.only(bottom: rh(8)),
          padding: EdgeInsets.symmetric(
            horizontal: rw(16),
            vertical: rh(14),
          ),
          decoration: BoxDecoration(
            color: context.customColors.surface,
            borderRadius: BorderRadius.circular(rr(16)),
            border: Border.all(color: context.customColors.border),
          ),
          child: Row(
            children: [
              _shimmerBox(rw(44), rw(44), radius: rr(12)),
              horizontalSpacing(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(rh(14), rw(140)),
                    verticalSpacing(6),
                    _shimmerBox(rh(12), rw(100)),
                    verticalSpacing(6),
                    _shimmerBox(rh(12), rw(80)),
                  ],
                ),
              ),
              _shimmerBox(rh(24), rw(72), radius: rr(20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(double height, double width, {double? radius}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.customColors.border,
        borderRadius: BorderRadius.circular(radius ?? rr(6)),
      ),
    );
  }
}
