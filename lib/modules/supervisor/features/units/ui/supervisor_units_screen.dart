import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/auth/logic/cubit/auth_cubit.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/core/widgets/filter_pills.dart';
import 'package:ground_scope/core/widgets/search_with_counter.dart';
import '../logic/cubit/supervisor_units_cubit.dart';
import 'widgets/unit_status_card.dart';

class SupervisorUnitsScreen extends StatefulWidget {
  const SupervisorUnitsScreen({super.key});

  @override
  State<SupervisorUnitsScreen> createState() => _SupervisorUnitsScreenState();
}

class _SupervisorUnitsScreenState extends State<SupervisorUnitsScreen> {
  static const _filters = ['all', 'available', 'busy', 'offline'];

  String get _serviceTypeId {
    final auth = context.read<AuthCubit>().state;
    return auth is AuthSuccess ? (auth.userModel.serviceTypeId ?? '') : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<SupervisorUnitsCubit>().loadUnits(_serviceTypeId);
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Scaffold(
      backgroundColor: cc.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header
          BlocBuilder<SupervisorUnitsCubit, SupervisorUnitsState>(
            buildWhen: (p, c) => p.allUnits.length != c.allUnits.length,
            builder: (context, state) => _Header(
              totalUnits: state.allUnits.length,
              serviceTypeId: _serviceTypeId,
            ),
          ),
          // Search + counter
          BlocBuilder<SupervisorUnitsCubit, SupervisorUnitsState>(
            buildWhen: (p, c) =>
                p.resultCount != c.resultCount ||
                p.searchQuery != c.searchQuery,
            builder: (context, state) => SearchWithCounter(
              hintText: 'search_by_unit_name'.tr(),
              onChanged: context.read<SupervisorUnitsCubit>().setSearch,
              resultCount: state.resultCount,
            ),
          ),
          // Filter pills
          BlocBuilder<SupervisorUnitsCubit, SupervisorUnitsState>(
            buildWhen: (p, c) => p.activeFilter != c.activeFilter,
            builder: (context, state) => FilterPills(
              filters: _filters,
              filterLabels: [
                'filter_all'.tr(),
                'filter_available'.tr(),
                'filter_busy'.tr(),
                'filter_offline'.tr(),
              ],
              activeFilter: state.activeFilter,
              onFilterChanged: context.read<SupervisorUnitsCubit>().setFilter,
            ),
          ),
          // Body
          Expanded(
            child: BlocBuilder<SupervisorUnitsCubit, SupervisorUnitsState>(
              builder: (context, state) {
                if (state.status == SupervisorUnitsStatus.loading ||
                    state.status == SupervisorUnitsStatus.initial) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary200),
                  );
                }
                if (state.status == SupervisorUnitsStatus.failure) {
                  return ErrorScreen(
                    error: state.error?.messageKey,
                    onRetry: () => context
                        .read<SupervisorUnitsCubit>()
                        .loadUnits(_serviceTypeId),
                  );
                }
                if (state.filteredUnits.isEmpty) {
                  return _EmptyState();
                }
                // No RefreshIndicator — realtime handles updates
                return ListView.builder(
                  padding:
                      EdgeInsets.fromLTRB(rw(16), rh(8), rw(16), rh(24)),
                  itemCount: state.filteredUnits.length,
                  itemBuilder: (_, i) =>
                      UnitStatusCard(unit: state.filteredUnits[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.totalUnits, required this.serviceTypeId});

  final int totalUnits;
  final String serviceTypeId;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final serviceTypeName = authState is AuthSuccess
        ? authState.userModel.serviceTypeId
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        rw(16),
        rh(20) + MediaQuery.of(context).padding.top,
        rw(16),
        rh(16),
      ),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'supervisor_units_title'.tr(),
            style: AppTextStyles.font18ExtraBold
                .copyWith(color: AppColors.white),
          ),
          verticalSpacing(2),
          Text(
            '$totalUnits ${'units'.tr()}${serviceTypeName != null ? ' · $serviceTypeName' : ''}',
            style: AppTextStyles.font12Light.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rw(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: rf(64), color: cc.iconSecondary),
            verticalSpacing(16),
            Text(
              'no_results_found'.tr(),
              style: AppTextStyles.font16SemiBold
                  .copyWith(color: cc.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
