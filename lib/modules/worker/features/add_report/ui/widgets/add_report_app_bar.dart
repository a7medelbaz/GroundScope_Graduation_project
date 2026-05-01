import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class AddReportAppBar extends StatelessWidget {
  const AddReportAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final canPop = Navigator.canPop(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: rh(56),
          left: rw(20),
          right: rw(20),
          bottom: rh(16),
        ),
        child: Row(
          children: [
            if (canPop)
              GestureDetector(
                onTap: context.pop,
                child: Container(
                  width: rw(40),
                  height: rw(40),
                  decoration: BoxDecoration(
                    color: customColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(rr(12)),
                    border: Border.all(color: customColors.border),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: rf(16),
                    color: customColors.iconPrimary,
                  ),
                ),
              )
            else
              SizedBox(width: rw(40)),
            const Spacer(),
            Text(
              'Add Report',
              style: AppTextStyles.font18SemiBold.copyWith(
                color: customColors.textPrimary,
              ),
            ),
            const Spacer(),
            SizedBox(width: rw(40)),
          ],
        ),
      ),
    );
  }
}
