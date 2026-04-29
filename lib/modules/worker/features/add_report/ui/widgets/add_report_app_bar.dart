import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AddReportAppBar extends StatelessWidget {
  const AddReportAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: rw(56),
          left: rw(20),
          right: rw(20),
          bottom: rw(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              onPressed: context.pop,
            ),
            const Text('Add Report', style: AppTextStyles.font22SemiBold),
          ],
        ),
      ),
    );
  }
}
