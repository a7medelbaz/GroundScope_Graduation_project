import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.user,
    required this.serviceTypeName,
    required this.unitCount,
    required this.memberCount,
  });

  final UserModel user;
  final String? serviceTypeName;
  final int unitCount;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── About section ─────────────────────────────────────────────────
        _SectionLabel(text: 'profile_about'.tr()),
        verticalSpacing(8),
        _Card(
          children: [
            _Row(
              icon: Icons.mail_outline_rounded,
              label: 'email'.tr(),
              value: user.email,
            ),
            _Divider(),
            _Row(
              icon: Icons.phone_outlined,
              label: 'phone'.tr(),
              value: user.phone?.isNotEmpty == true ? user.phone! : '—',
            ),
            _Divider(),
            _Row(
              icon: Icons.bolt_rounded,
              label: 'service_type'.tr(),
              value: serviceTypeName ?? '—',
              highlight: serviceTypeName != null,
            ),
            _Divider(),
            _StatusRow(isActive: user.isActive),
          ],
        ),
        verticalSpacing(20),
        // ── Team overview ─────────────────────────────────────────────────
        _SectionLabel(text: 'profile_my_team'.tr()),
        verticalSpacing(8),
        _Card(
          children: [
            _StatRow(
              icon: Icons.local_shipping_rounded,
              label: 'units_managed'.tr(),
              count: unitCount,
              unit: 'units'.tr(),
              color: AppColors.primary200,
            ),
            _Divider(),
            _StatRow(
              icon: Icons.people_alt_rounded,
              label: 'crew_members'.tr(),
              count: memberCount,
              unit: 'crew_members'.tr(),
              color: AppColors.blue200,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Private sub-widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.font12SemiBold.copyWith(
        color: context.customColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: cc.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final valueColor =
        highlight ? AppColors.primary200 : cc.textPrimary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
      child: Row(
        children: [
          Icon(icon, size: rf(18), color: AppColors.primary200),
          horizontalSpacing(12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.font14Light.copyWith(
                color: cc.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.font14SemiBold.copyWith(color: valueColor),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final color = isActive ? AppColors.green200 : AppColors.grey400;
    final label = isActive ? 'status_active'.tr() : 'status_inactive'.tr();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined,
              size: rf(18), color: AppColors.primary200),
          horizontalSpacing(12),
          Expanded(
            child: Text(
              'profile_status'.tr(),
              style:
                  AppTextStyles.font14Light.copyWith(color: cc.textSecondary),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: rw(8),
                height: rw(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              horizontalSpacing(6),
              Text(
                label,
                style: AppTextStyles.font14SemiBold.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.unit,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
      child: Row(
        children: [
          Container(
            width: rw(36),
            height: rw(36),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rr(10)),
            ),
            child: Center(
              child: Icon(icon, size: rf(18), color: color),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Text(
              label,
              style:
                  AppTextStyles.font14Light.copyWith(color: cc.textSecondary),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$count ',
                  style: AppTextStyles.font18ExtraBold.copyWith(color: color),
                ),
                TextSpan(
                  text: unit,
                  style: AppTextStyles.font12Light
                      .copyWith(color: cc.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.customColors.divider,
      indent: rw(46),
    );
  }
}
