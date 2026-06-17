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
import '../logic/cubit/supervisor_tasks_cubit.dart';
import 'widgets/supervisor_task_card.dart';

class SupervisorTasksScreen extends StatefulWidget {
  const SupervisorTasksScreen({super.key});

  @override
  State<SupervisorTasksScreen> createState() => _SupervisorTasksScreenState();
}

class _SupervisorTasksScreenState extends State<SupervisorTasksScreen> {
  static const _filters = [
    'all',
    'pending',
    'in_progress',
    'completed',
    'cancelled',
  ];

  String get _serviceTypeId {
    final auth = context.read<AuthCubit>().state;
    return auth is AuthSuccess ? (auth.userModel.serviceTypeId ?? '') : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<SupervisorTasksCubit>().loadTasks(_serviceTypeId);
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Scaffold(
      backgroundColor: cc.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(serviceTypeId: _serviceTypeId),
          BlocBuilder<SupervisorTasksCubit, SupervisorTasksState>(
            buildWhen: (prev, curr) =>
                prev.resultCount != curr.resultCount ||
                prev.searchQuery != curr.searchQuery,
            builder: (context, state) => SearchWithCounter(
              hintText: 'search_by_flight_or_unit'.tr(),
              onChanged: context.read<SupervisorTasksCubit>().setSearch,
              resultCount: state.resultCount,
            ),
          ),
          BlocBuilder<SupervisorTasksCubit, SupervisorTasksState>(
            buildWhen: (prev, curr) =>
                prev.activeFilter != curr.activeFilter,
            builder: (context, state) => FilterPills(
              filters: _filters,
              filterLabels: [
                'filter_all'.tr(),
                'filter_pending'.tr(),
                'filter_in_progress'.tr(),
                'filter_completed'.tr(),
                'filter_cancelled'.tr(),
              ],
              activeFilter: state.activeFilter,
              onFilterChanged: context.read<SupervisorTasksCubit>().setFilter,
            ),
          ),
          Expanded(
            child: BlocBuilder<SupervisorTasksCubit, SupervisorTasksState>(
              builder: (context, state) {
                if (state.status == SupervisorTasksStatus.loading ||
                    state.status == SupervisorTasksStatus.initial) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary200),
                  );
                }
                if (state.status == SupervisorTasksStatus.failure) {
                  return ErrorScreen(
                    error: state.error?.messageKey,
                    onRetry: () => context
                        .read<SupervisorTasksCubit>()
                        .loadTasks(_serviceTypeId),
                  );
                }
                if (state.filteredTasks.isEmpty) {
                  return _EmptyState();
                }
                return RefreshIndicator(
                  color: AppColors.primary200,
                  onRefresh: () => context
                      .read<SupervisorTasksCubit>()
                      .refresh(_serviceTypeId),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                        rw(16), rh(8), rw(16), rh(24)),
                    itemCount: state.filteredTasks.length,
                    itemBuilder: (_, i) =>
                        SupervisorTaskCard(task: state.filteredTasks[i]),
                  ),
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
  const _Header({required this.serviceTypeId});

  final String serviceTypeId;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final serviceTypeName = authState is AuthSuccess
        ? authState.userModel.role
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(rw(16), rh(20) + MediaQuery.of(context).padding.top, rw(16), rh(16)),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'supervisor_tasks_title'.tr(),
            style: AppTextStyles.font18ExtraBold
                .copyWith(color: AppColors.white),
          ),
          if (serviceTypeName != null) ...[
            verticalSpacing(2),
            Text(
              serviceTypeName,
              style: AppTextStyles.font12Light.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
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
            Icon(
              Icons.assignment_outlined,
              size: rf(64),
              color: cc.iconSecondary,
            ),
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
