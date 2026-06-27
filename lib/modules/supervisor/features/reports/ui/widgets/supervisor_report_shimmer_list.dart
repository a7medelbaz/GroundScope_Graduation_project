import 'package:flutter/material.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class SupervisorReportShimmerList extends StatelessWidget {
  const SupervisorReportShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(rw(16), rh(12), rw(16), rh(24)),
      itemCount: 5,
      itemBuilder: (_, _) => Container(
        margin: EdgeInsets.only(bottom: rh(12)),
        height: rh(80),
        decoration: BoxDecoration(
          color: context.customColors.surface,
          borderRadius: BorderRadius.circular(rr(16)),
        ),
      ),
    );
  }
}
