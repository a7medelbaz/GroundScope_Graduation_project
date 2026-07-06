import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/auth/data/models/user_date.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';

class SupervisorPersonalCard extends StatelessWidget {
  const SupervisorPersonalCard({
    super.key,
    required this.user,
    required this.serviceTypeName,
  });

  final UserModel user;
  final String? serviceTypeName;

  static String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  static String _memberSince(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: cc.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Gradient band with floating avatar ────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Band
              Container(
                width: double.infinity,
                height: rh(90),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary400.withValues(alpha: 0.18),
                      AppColors.primary200.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(rr(20)),
                    topRight: Radius.circular(rr(20)),
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(rw(14)),
                    child: _RoleBadge(),
                  ),
                ),
              ),
              // Avatar — centered, bottom half overflows the band
              Positioned(
                bottom: -rw(44),
                left: 0,
                right: 0,
                child: Center(
                  child: _AvatarCircle(initials: _initials(user.fullName)),
                ),
              ),
            ],
          ),

          // ── Space for avatar's lower half ──────────────────────────────
          SizedBox(height: rw(44) + rh(12)),

          // ── Name + role label ──────────────────────────────────────────
          Text(
            user.fullName,
            style: AppTextStyles.font18ExtraBold.copyWith(
              color: cc.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpacing(6),
          Text(
            'supervisor'.tr(),
            style: AppTextStyles.font12Light.copyWith(
              color: cc.textSecondary,
            ),
          ),
          verticalSpacing(20),

          // ── Info rows ──────────────────────────────────────────────────
          Divider(height: 1, thickness: 1, color: cc.divider),
          Padding(
            padding: EdgeInsets.fromLTRB(rw(20), 0, rw(20), rh(20)),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.mail_rounded,
                  label: 'email'.tr(),
                  value: user.email,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.phone_rounded,
                  label: 'phone'.tr(),
                  value: user.phone?.isNotEmpty == true ? user.phone! : '—',
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.bolt_rounded,
                  label: 'service_type'.tr(),
                  value: serviceTypeName ?? '—',
                  highlight: serviceTypeName != null,
                ),
                _Divider(),
                _StatusRow(isActive: user.isActive),
                _Divider(),
                _InfoRow(
                  icon: Icons.calendar_month_rounded,
                  label: 'worker_profile.member_since'.tr(),
                  value: _memberSince(user.createdAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Outer white ring
        Container(
          width: rw(88),
          height: rw(88),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cc.surface,
            border: Border.all(color: cc.border, width: 3),
          ),
          // Inner gradient circle
          child: Padding(
            padding: EdgeInsets.all(rw(3)),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary400,
                    AppColors.primary300,
                    AppColors.primary200,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppTextStyles.font22ExtraBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Camera badge
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: rw(26),
            height: rw(26),
            decoration: BoxDecoration(
              color: AppColors.primary200,
              shape: BoxShape.circle,
              border: Border.all(color: cc.surface, width: 2),
            ),
            child: Center(
              child: Icon(
                Icons.camera_alt_rounded,
                size: rf(12),
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(10), vertical: rh(5)),
      decoration: BoxDecoration(
        color: AppColors.primary200.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: AppColors.primary200.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: rw(6),
            height: rw(6),
            decoration: const BoxDecoration(
              color: AppColors.primary200,
              shape: BoxShape.circle,
            ),
          ),
          horizontalSpacing(5),
          Text(
            'supervisor'.tr(),
            style: AppTextStyles.font12SemiBold.copyWith(
              color: AppColors.primary200,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
    final valueColor = highlight ? AppColors.primary200 : cc.textPrimary;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(13)),
      child: Row(
        children: [
          Container(
            width: rw(34),
            height: rw(34),
            decoration: BoxDecoration(
              color: AppColors.primary200.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rr(9)),
            ),
            child: Center(
              child: Icon(icon, size: rf(16), color: AppColors.primary200),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.font12Light.copyWith(color: cc.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          horizontalSpacing(8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.font12SemiBold.copyWith(color: valueColor),
              textAlign: TextAlign.end,
              maxLines: 2,
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
      padding: EdgeInsets.symmetric(vertical: rh(13)),
      child: Row(
        children: [
          Container(
            width: rw(34),
            height: rw(34),
            decoration: BoxDecoration(
              color: AppColors.primary200.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(rr(9)),
            ),
            child: Center(
              child: Icon(
                Icons.verified_user_outlined,
                size: rf(16),
                color: AppColors.primary200,
              ),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Text(
              'profile_status'.tr(),
              style: AppTextStyles.font12Light.copyWith(color: cc.textSecondary),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: rw(7),
                height: rw(7),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              horizontalSpacing(5),
              Text(
                label,
                style: AppTextStyles.font12SemiBold.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 1,
        color: context.customColors.divider,
      );
}
