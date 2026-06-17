import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/info_card.dart';
import 'package:ground_scope/core/widgets/info_row_data.dart';

class UnitDetailBottomSheet extends StatelessWidget {
  const UnitDetailBottomSheet({super.key, required this.unit});

  final UnitModel unit;

  Color _statusColor(BuildContext context) => switch (unit.status) {
        'available' => AppColors.green200,
        'busy' => AppColors.primary200,
        _ => context.customColors.textDisabled,
      };

  String get _statusLabel => switch (unit.status) {
        'available' => 'filter_available',
        'busy' => 'filter_busy',
        _ => 'filter_offline',
      };

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final statusColor = _statusColor(context);

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.80),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(rr(16))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: rh(12), bottom: rh(4)),
              width: rw(40),
              height: rh(4),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(rr(2)),
              ),
            ),
          ),
          // Header row
          Padding(
            padding: EdgeInsets.fromLTRB(rw(16), rh(8), rw(16), rh(4)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    unit.name,
                    style: AppTextStyles.font18ExtraBold
                        .copyWith(color: cc.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                horizontalSpacing(8),
                _Badge(label: _statusLabel.tr(), color: statusColor),
              ],
            ),
          ),
          Divider(height: 1, color: cc.border),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(rw(16), rh(16), rw(16), rh(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info rows
                  InfoCard(rows: [
                    InfoRowData(
                      icon: Icons.access_time_outlined,
                      label: 'shift'.tr(),
                      value: unit.shiftLabel,
                    ),
                    InfoRowData(
                      icon: Icons.bolt_outlined,
                      label: 'service_type'.tr(),
                      value: unit.serviceTypeName ?? '—',
                    ),
                    InfoRowData(
                      icon: Icons.airplanemode_active_outlined,
                      label: 'compatible_aircraft'.tr(),
                      value: unit.compatibleAircraft.isNotEmpty
                          ? unit.compatibleAircraft.join(', ')
                          : '—',
                    ),
                  ]),
                  verticalSpacing(20),
                  // Crew section title
                  Text(
                    'crew_members'.tr(),
                    style: AppTextStyles.font14ExtraBold
                        .copyWith(color: cc.textPrimary),
                  ),
                  verticalSpacing(10),
                  if (unit.members.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: rh(12)),
                      child: Text(
                        'no_results_found'.tr(),
                        style: AppTextStyles.font14Light
                            .copyWith(color: cc.textHint),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: unit.members.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: cc.divider),
                      itemBuilder: (_, i) =>
                          _MemberRow(member: unit.members[i]),
                    ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(8)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});

  final UnitMemberModel member;

  String get _initials {
    final words = member.fullName.trim().split(RegExp(r'\s+'));
    return words.map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(10)),
      child: Row(
        children: [
          // Avatar circle with initials
          Container(
            width: rw(36),
            height: rw(36),
            decoration: BoxDecoration(
              color: AppColors.primary200.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rr(18)),
            ),
            child: Center(
              child: Text(
                _initials,
                style: AppTextStyles.font12SemiBold
                    .copyWith(color: AppColors.primary200),
              ),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: AppTextStyles.font14SemiBold
                      .copyWith(color: cc.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpacing(2),
                Text(
                  member.position.tr(),
                  style: AppTextStyles.font12Light
                      .copyWith(color: cc.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
