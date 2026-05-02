import 'package:flutter/material.dart';

import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/extensions/context_ext.dart';
import '../utils/spacing.dart';
import 'info_row_data.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.rows});
  final List<InfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Container(
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(14)),
        border: Border.all(color: cc.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          final row = entry.value;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(14),
                  vertical: rh(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: rw(32),
                      height: rw(32),
                      decoration: BoxDecoration(
                        color: AppColors.primary200.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(rr(8)),
                      ),
                      child: Icon(
                        row.icon,
                        color: AppColors.primary200,
                        size: rf(15),
                      ),
                    ),
                    horizontalSpacing(12),
                    Text(
                      row.label,
                      style: AppTextStyles.font12Light.copyWith(
                        color: cc.textHint,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      row.value,
                      style: AppTextStyles.font12SemiBold.copyWith(
                        color:
                            row.valueColor ??
                            (row.highlight ? cc.textPrimary : cc.textSecondary),
                        fontWeight: row.highlight
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: cc.divider,
                  indent: rw(14),
                  endIndent: rw(14),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
