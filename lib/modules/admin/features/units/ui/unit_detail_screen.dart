import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/modules/admin/features/units/logic/cubit/unit_detail_cubit.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_members_section.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_status_badge.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_task_history_section.dart';

class UnitDetailScreen extends StatefulWidget {
  const UnitDetailScreen({super.key, required this.unit});

  final UnitModel unit;

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  bool _didChange = false;

  Future<void> _navigateToEdit(UnitModel unit) async {
    final result = await context.pushNamed(
      Routes.adminUnitFormScreen,
      arguments: {'model': unit},
    );
    if (result == true && mounted) {
      context.read<UnitDetailCubit>().load(unit.id);
      _didChange = true;
    }
  }

  Future<void> _showStatusSheet(UnitModel unit) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatusSheet(
        current: unit.unitStatus,
        onSelected: (status) async {
          Navigator.of(context).pop();
          final cubit = context.read<UnitDetailCubit>();
          final ok = await cubit.updateStatus(unit.id, status);
          if (ok && mounted) {
            context.showSuccessSnackBar('status_updated_success'.tr());
            _didChange = true;
          } else if (!ok && mounted) {
            final err = cubit.state.error;
            if (err != null) context.showErrorSnackBar(err.messageKey);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      body: SafeArea(
        child: BlocBuilder<UnitDetailCubit, UnitDetailState>(
          builder: (context, state) {
            if (state.status == UnitDetailStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == UnitDetailStatus.failure) {
              return ErrorScreen(
                onRetry: () =>
                    context.read<UnitDetailCubit>().load(widget.unit.id),
              );
            }

            final unit = state.unit ?? widget.unit;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildAppBar(context, unit)),
                SliverPadding(
                  padding:
                      EdgeInsets.fromLTRB(rw(20), rh(8), rw(20), rh(24)),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionHeader(context, ''),
                      _buildCard(
                        context,
                        child: _OverviewCard(
                          unit: unit,
                          onStatusTap: () => _showStatusSheet(unit),
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(
                            begin: 0.05,
                            end: 0,
                            duration: 300.ms,
                          ),
                      verticalSpacing(16),
                      _buildSectionHeader(context, 'task_history'.tr()),
                      verticalSpacing(8),
                      _buildCard(
                        context,
                        child: UnitTaskHistorySection(
                          activeTasks: state.activeTasks,
                          recentTasks: state.recentTasks,
                        ),
                      )
                          .animate(delay: 80.ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.05, end: 0, duration: 300.ms),
                      verticalSpacing(16),
                      _buildSectionHeader(context, 'unit_members'.tr()),
                      verticalSpacing(8),
                      _buildCard(
                        context,
                        child: UnitMembersSection(
                          unitId: unit.id,
                          members: state.members,
                        ),
                      )
                          .animate(delay: 160.ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.05, end: 0, duration: 300.ms),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UnitModel unit) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(8)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(_didChange),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              unit.name,
              style: AppTextStyles.font18SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                color: context.customColors.textSecondary),
            onPressed: () => _navigateToEdit(unit),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    if (title.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: rh(4)),
      child: Text(
        title,
        style: AppTextStyles.font16SemiBold.copyWith(
          color: context.customColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rw(16)),
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: context.customColors.border),
      ),
      child: child,
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.unit, required this.onStatusTap});

  final UnitModel unit;
  final VoidCallback onStatusTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(context,
            label: 'service_type'.tr(),
            value: unit.serviceTypeName ?? '—'),
        verticalSpacing(12),
        _statusRow(context),
        if (unit.compatibleAircraft.isNotEmpty) ...[
          verticalSpacing(12),
          _infoRow(context,
              label: 'unit_compatible_aircraft'.tr(),
              value: unit.compatibleAircraft.join('  ·  ')),
        ],
        if (unit.shiftStartTime != null && unit.shiftEndTime != null) ...[
          verticalSpacing(12),
          _infoRow(context,
              label: 'shift_start'.tr(),
              value: '${unit.shiftStartTime} → ${unit.shiftEndTime}'),
        ],
      ],
    );
  }

  Widget _infoRow(BuildContext context,
      {required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: rw(110),
          child: Text(
            label,
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
        ),
        horizontalSpacing(8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.font14SemiBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: rw(110),
          child: Text(
            'unit_status'.tr(),
            style: AppTextStyles.font12Light.copyWith(
              color: context.customColors.textSecondary,
            ),
          ),
        ),
        horizontalSpacing(8),
        GestureDetector(
          onTap: onStatusTap,
          child: UnitStatusBadge(status: unit.unitStatus),
        ),
        horizontalSpacing(4),
        Icon(Icons.edit_outlined,
            size: rw(14), color: context.customColors.iconSecondary),
      ],
    );
  }
}

class _StatusSheet extends StatelessWidget {
  const _StatusSheet({required this.current, required this.onSelected});

  final UnitStatus current;
  final ValueChanged<UnitStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.customColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(rr(24))),
      ),
      padding: EdgeInsets.fromLTRB(rw(20), rh(12), rw(20), rh(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: rw(40),
              height: rh(4),
              decoration: BoxDecoration(
                color: context.customColors.border,
                borderRadius: BorderRadius.circular(rr(4)),
              ),
            ),
          ),
          verticalSpacing(16),
          Text(
            'change_status'.tr(),
            style: AppTextStyles.font18SemiBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
          verticalSpacing(12),
          ...UnitStatus.values.map(
            (s) => _StatusOption(
              status: s,
              isSelected: s == current,
              onTap: () => onSelected(s),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final UnitStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = UnitStatusBadge.colorFor(status);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rr(12)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
        margin: EdgeInsets.only(bottom: rh(8)),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : context.customColors.surface,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(
            color: isSelected ? color : context.customColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: rw(10),
              height: rw(10),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            horizontalSpacing(12),
            Text(
              status.label.tr(),
              style: AppTextStyles.font14SemiBold.copyWith(
                color: isSelected ? color : context.customColors.textPrimary,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Icon(Icons.check_circle_rounded, color: color, size: rw(18)),
            ],
          ],
        ),
      ),
    );
  }
}
