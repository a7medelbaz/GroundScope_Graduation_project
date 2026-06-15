import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ServiceTypeListTile extends StatelessWidget {
  const ServiceTypeListTile({
    super.key,
    required this.model,
    required this.onEdit,
    required this.onViewUsage,
    required this.onToggleActive,
    this.animationDelay = Duration.zero,
  });

  final ServiceTypeModel model;
  final VoidCallback onEdit;
  final VoidCallback onViewUsage;
  final ValueChanged<bool> onToggleActive;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    return Opacity(
          opacity: model.isActive ? 1.0 : 0.6,
          child: Container(
            margin: EdgeInsets.only(bottom: rh(8)),
            decoration: BoxDecoration(
              color: context.customColors.surface,
              borderRadius: BorderRadius.circular(rr(16)),
              border: Border.all(color: context.customColors.border),
            ),
            child: InkWell(
              onTap: onViewUsage,
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
                    _buildTrailing(context),
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
    if (model.icon != null && model.icon!.isNotEmpty) {
      return Container(
        width: rw(44),
        height: rw(44),
        decoration: BoxDecoration(
          color: context.customColors.infoBackground,
          borderRadius: BorderRadius.circular(rr(12)),
        ),
        child: Center(
          child: Text(
            model.icon ?? model.name[0].toUpperCase(),
            style: TextStyle(fontSize: rf(22)),
          ),
        ),
      );
    }
    return Container(
      width: rw(44),
      height: rw(44),
      decoration: BoxDecoration(
        color: context.customColors.infoBackground,
        borderRadius: BorderRadius.circular(rr(12)),
      ),
      child: Icon(
        Icons.build_circle_outlined,
        size: rw(22),
        color: AppColors.primary200,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          model.name,
          style: AppTextStyles.font14SemiBold.copyWith(
            color: context.customColors.textPrimary,
          ),
        ),
        verticalSpacing(4),
        Row(
          children: [
            Container(
              width: rw(6),
              height: rw(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: model.isActive ? AppColors.green200 : AppColors.grey400,
              ),
            ),
            horizontalSpacing(6),
            Text(
              '${model.defaultDurationMinutes} min · ${model.isActive ? 'active'.tr() : 'inactive'.tr()}',
              style: AppTextStyles.font12Light.copyWith(
                color: context.customColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Switch.adaptive(
            value: model.isActive,
            onChanged: onToggleActive,
            activeThumbColor: AppColors.primary200,
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            size: rw(20),
            color: context.customColors.iconSecondary,
          ),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, size: 18),
                  horizontalSpacing(8),
                  Text('edit_service_type'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'usage',
              child: Row(
                children: [
                  const Icon(Icons.analytics_outlined, size: 18),
                  horizontalSpacing(8),
                  Text('view_usage'.tr()),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'usage') onViewUsage();
          },
        ),
      ],
    );
  }
}
