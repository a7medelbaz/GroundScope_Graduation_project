import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';
import '../../data/models/service_request_model.dart';

class ServiceRequestCard extends StatelessWidget {
  const ServiceRequestCard({
    super.key,
    required this.request,
    required this.onAssignTap,
    this.onDetailsTap,
  });

  final ServiceRequestModel request;
  final VoidCallback onAssignTap;
  final VoidCallback? onDetailsTap;

  Color get _accentColor =>
      request.status == 'pending' ? AppColors.primary200 : AppColors.amber200;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final flight = request.flight;

    return Container(
      margin: EdgeInsets.only(bottom: rh(12)),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: rw(4),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(rr(16)),
                bottomLeft: Radius.circular(rr(16)),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(rw(12), rh(12), rw(12), rh(6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderRow(
                        flightNumber: flight?.flightNumber ?? '-',
                        standCode: flight?.stand?.code ?? '-',
                        status: request.status,
                        accentColor: _accentColor,
                      ),
                      verticalSpacing(8),
                      _MetaChipsRow(
                        arrivalTime: flight?.scheduledArrival.formattedTime,
                        aircraftType: flight?.aircraftType,
                        paxCount: flight?.paxCount,
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: cc.divider,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(12),
                    vertical: rh(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextButton.outlined(
                          text: 'details'.tr(),
                          onPressed: onDetailsTap,
                          size: CustomButtonSize.small,
                        ),
                      ),
                      horizontalSpacing(8),
                      Expanded(
                        child: CustomTextButton(
                          text: 'assign_unit'.tr(),
                          onPressed: onAssignTap,
                          size: CustomButtonSize.small,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.flightNumber,
    required this.standCode,
    required this.status,
    required this.accentColor,
  });

  final String flightNumber;
  final String standCode;
  final String status;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Row(
      children: [
        Text(
          flightNumber,
          style: AppTextStyles.font16SemiBold.copyWith(color: cc.textPrimary),
        ),
        horizontalSpacing(6),
        Text(
          '· $standCode',
          style: AppTextStyles.font14Light.copyWith(color: cc.textSecondary),
        ),
        const Spacer(),
        _StatusBadge(status: status, color: accentColor),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final String status;
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
        status,
        style: AppTextStyles.font12SemiBold.copyWith(color: color),
      ),
    );
  }
}

class _MetaChipsRow extends StatelessWidget {
  const _MetaChipsRow({
    this.arrivalTime,
    this.aircraftType,
    this.paxCount,
  });

  final String? arrivalTime;
  final String? aircraftType;
  final int? paxCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: rw(8),
      runSpacing: rh(4),
      children: [
        _MetaChip(
          icon: Icons.access_time_outlined,
          label: arrivalTime ?? '-',
        ),
        _MetaChip(
          icon: Icons.flight_outlined,
          label: aircraftType ?? '-',
        ),
        _MetaChip(
          icon: Icons.people_outline,
          label: paxCount != null ? '$paxCount' : '-',
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: rf(13), color: cc.iconSecondary),
        horizontalSpacing(3),
        Text(
          label,
          style: AppTextStyles.font12Light.copyWith(color: cc.textSecondary),
        ),
      ],
    );
  }
}
