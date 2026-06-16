import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_app_bar.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import '../logic/cubit/units_list_cubit.dart';

class SupervisorUnitsScreen extends StatefulWidget {
  const SupervisorUnitsScreen({super.key});

  @override
  State<SupervisorUnitsScreen> createState() => _SupervisorUnitsScreenState();
}

class _SupervisorUnitsScreenState extends State<SupervisorUnitsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Scaffold(
      backgroundColor: cc.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'Active Units'),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rw(16),
                vertical: rh(8),
              ),
              child: _SearchBar(
                controller: _searchController,
                onChanged: (q) =>
                    context.read<UnitsListCubit>().search(q),
              ),
            ),
            Expanded(
              child: BlocBuilder<UnitsListCubit, UnitsListState>(
                builder: (context, state) {
                  if (state is UnitsListLoading || state is UnitsListInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary200,
                      ),
                    );
                  }

                  if (state is UnitsListFailure) {
                    return ErrorScreen(
                      error: state.error.messageKey,
                      onRetry: () =>
                          context.read<UnitsListCubit>().loadUnits(),
                    );
                  }

                  final loaded = state as UnitsListLoaded;

                  if (loaded.filteredUnits.isEmpty) {
                    return _EmptyState(
                      isSearch: loaded.searchQuery.isNotEmpty,
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary200,
                    onRefresh: () =>
                        context.read<UnitsListCubit>().loadUnits(),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(16),
                        vertical: rh(8),
                      ),
                      itemCount: loaded.filteredUnits.length,
                      separatorBuilder: (_, __) => verticalSpacing(10),
                      itemBuilder: (context, index) =>
                          _UnitCard(unit: loaded.filteredUnits[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.font14Light.copyWith(color: cc.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search units...',
        hintStyle: AppTextStyles.font14Light.copyWith(color: cc.textHint),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: cc.textHint,
          size: rf(20),
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: cc.textHint,
                    size: rf(18),
                  ),
                ),
        ),
        filled: true,
        fillColor: cc.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: rw(16),
          vertical: rh(12),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rr(12)),
          borderSide: BorderSide(color: cc.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rr(12)),
          borderSide: BorderSide(color: cc.border.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rr(12)),
          borderSide: const BorderSide(color: AppColors.primary200),
        ),
      ),
    );
  }
}

// ── Unit Card ─────────────────────────────────────────────────────────────────

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit});

  final UnitProfileModel unit;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(14)),
      decoration: BoxDecoration(
        color: cc.surface,
        borderRadius: BorderRadius.circular(rr(14)),
        border: Border.all(color: cc.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: rr(22),
            backgroundColor: AppColors.primary200.withValues(alpha: 0.12),
            child: Text(
              unit.name.isNotEmpty ? unit.name[0].toUpperCase() : '?',
              style: AppTextStyles.font16SemiBold.copyWith(
                color: AppColors.primary300,
              ),
            ),
          ),
          horizontalSpacing(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.name,
                  style: AppTextStyles.font16SemiBold.copyWith(
                    color: cc.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpacing(2),
                Text(
                  unit.serviceTypeName,
                  style: AppTextStyles.font12Light.copyWith(
                    color: cc.textSecondary,
                  ),
                ),
                if (unit.shiftStartTime != null && unit.shiftEndTime != null) ...[
                  verticalSpacing(4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: rf(12),
                        color: cc.textHint,
                      ),
                      horizontalSpacing(4),
                      Text(
                        '${unit.shiftStartTime} – ${unit.shiftEndTime}',
                        style: AppTextStyles.font12Light.copyWith(
                          color: cc.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          horizontalSpacing(8),
          _UnitStatusBadge(status: unit.status),
        ],
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _UnitStatusBadge extends StatelessWidget {
  const _UnitStatusBadge({required this.status});

  final UnitStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      UnitStatus.available => (AppColors.green200, 'Available'),
      UnitStatus.busy => (AppColors.amber200, 'Busy'),
      UnitStatus.offline => (AppColors.grey400, 'Offline'),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(20)),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: rw(6),
            height: rw(6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          horizontalSpacing(4),
          Text(
            label,
            style: AppTextStyles.font12SemiBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearch});

  final bool isSearch;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearch ? Icons.search_off_rounded : Icons.groups_outlined,
            size: rf(56),
            color: cc.textHint,
          ),
          verticalSpacing(12),
          Text(
            isSearch ? 'No units match your search.' : 'No units found.',
            style: AppTextStyles.font16SemiBold.copyWith(color: cc.textHint),
          ),
        ],
      ),
    );
  }
}
