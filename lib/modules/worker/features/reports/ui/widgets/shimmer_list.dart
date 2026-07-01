import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(rw(20), rh(12), rw(20), rh(24)),
      itemCount: 6,
      itemBuilder: (_, _) => _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Container(
      margin: EdgeInsets.only(bottom: rh(12)),
      height: rh(80),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(16)),
      ),
    );
  }
}
