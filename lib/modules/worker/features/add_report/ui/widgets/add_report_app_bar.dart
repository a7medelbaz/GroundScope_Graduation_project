import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AddReportAppBar extends StatelessWidget {
  const AddReportAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: rh(56),
          left: rw(20),
          right: rw(20),
          bottom: rh(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Centered title ──────────────────────────────────────────────
            Text(
              'Add Report',
              style: AppTextStyles.font20ExtraBold.copyWith(
                color: customColors.textPrimary,
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}