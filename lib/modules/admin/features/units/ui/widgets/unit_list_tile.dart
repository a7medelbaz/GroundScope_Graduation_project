import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_status_badge.dart';

class UnitListTile extends StatelessWidget {
  const UnitListTile({
    super.key,
    required this.model,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  final UnitModel model;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final isOffline = model.status == 'offline' || model.status == 'maintenance';
    return Opacity(
      opacity: isOffline ? 0.6 : 1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: rh(8)),
        decoration: BoxDecoration(
          color: context.customColors.surface,
          borderRadius: BorderRadius.circular(rr(16)),
          border: Border.all(color: context.customColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(rr(16)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rw(16),
              vertical: rh(14),
            ),
            child: Row(
              children: [
                _buildLeading(context),
                horizontalSpacing(12),
                Expanded(child: _buildContent(context)),
                horizontalSpacing(8),
                UnitStatusBadge(status: model.unitStatus),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: animationDelay)
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.1, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }

  Widget _buildLeading(BuildContext context) {
    final color = UnitStatusBadge.colorFor(model.unitStatus);
    return Container(
      width: rw(44),
      height: rw(44),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(12)),
      ),
      child: Icon(
        Icons.groups_outlined,
        size: rw(22),
        color: color,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final hasShift =
        model.shiftStartTime != null && model.shiftEndTime != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          model.name,
          style: AppTextStyles.font14SemiBold.copyWith(
            color: context.customColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (model.serviceTypeName != null) ...[
          verticalSpacing(2),
          Text(
            model.serviceTypeName!,
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        verticalSpacing(4),
        Row(
          children: [
            if (model.compatibleAircraft.isNotEmpty)
              Flexible(
                child: Text(
                  model.compatibleAircraft.join(', '),
                  style: AppTextStyles.font12Light.copyWith(
                    color: context.customColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (model.compatibleAircraft.isNotEmpty && hasShift)
              Text(
                '  ·  ',
                style: AppTextStyles.font12Light.copyWith(
                  color: context.customColors.textSecondary,
                ),
              ),
            if (hasShift)
              Text(
                '${model.shiftStartTime}–${model.shiftEndTime}',
                style: AppTextStyles.font12Light.copyWith(
                  color: context.customColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
