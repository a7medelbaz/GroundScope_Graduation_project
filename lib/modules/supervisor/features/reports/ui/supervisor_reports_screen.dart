import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/extensions/datetime_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_app_bar.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/modules/worker/features/reports/ui/widgets/report_card.dart';
import 'package:ground_scope/modules/worker/features/reports/ui/widgets/reports_empty_state.dart';
import '../logic/cubit/supervisor_reports_cubit.dart';

class SupervisorReportsScreen extends StatefulWidget {
  const SupervisorReportsScreen({super.key});

  @override
  State<SupervisorReportsScreen> createState() =>
      _SupervisorReportsScreenState();
}

class _SupervisorReportsScreenState extends State<SupervisorReportsScreen> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(title: 'Reports Today'),
            _TodayBanner(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rw(16),
                vertical: rh(8),
              ),
              child: _SearchBar(
                controller: _searchController,
                onChanged: (q) =>
                    context.read<SupervisorReportsCubit>().search(q),
              ),
            ),
            Expanded(
              child: BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
                builder: (context, state) {
                  if (state is SupervisorReportsLoading ||
                      state is SupervisorReportsInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.blue200,
                      ),
                    );
                  }

                  if (state is SupervisorReportsFailure) {
                    return ErrorScreen(
                      error: state.error.messageKey,
                      onRetry: () => context
                          .read<SupervisorReportsCubit>()
                          .loadReportsToday(),
                    );
                  }

                  final loaded = state as SupervisorReportsLoaded;

                  if (loaded.filteredReports.isEmpty) {
                    return ReportsEmptyState(
                      isFiltered: loaded.searchQuery.isNotEmpty,
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.blue200,
                    onRefresh: () => context
                        .read<SupervisorReportsCubit>()
                        .loadReportsToday(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(16),
                        vertical: rh(8),
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: loaded.filteredReports.length,
                      itemBuilder: (_, i) =>
                          ReportCard(report: loaded.filteredReports[i]),
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

// ── Today Banner ──────────────────────────────────────────────────────────────

class _TodayBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final today = DateTime.now().formattedDate;

    return BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
      buildWhen: (prev, next) =>
          prev.runtimeType != next.runtimeType ||
          (next is SupervisorReportsLoaded &&
              prev is SupervisorReportsLoaded &&
              prev.allReports.length != next.allReports.length),
      builder: (context, state) {
        final count =
            state is SupervisorReportsLoaded ? state.allReports.length : null;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(4)),
          padding: EdgeInsets.symmetric(
            horizontal: rw(14),
            vertical: rh(10),
          ),
          decoration: BoxDecoration(
            color: AppColors.blue200.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(rr(12)),
            border: Border.all(
              color: AppColors.blue200.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: rf(15),
                color: AppColors.blue200,
              ),
              horizontalSpacing(8),
              Text(
                today,
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: AppColors.blue200,
                ),
              ),
              const Spacer(),
              if (count != null)
                Text(
                  '$count ${count == 1 ? 'report' : 'reports'}',
                  style: AppTextStyles.font12SemiBold.copyWith(
                    color: cc.textSecondary,
                  ),
                ),
            ],
          ),
        );
      },
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
        hintText: 'Search by type, description, or severity...',
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
          borderSide: const BorderSide(color: AppColors.blue200),
        ),
      ),
    );
  }
}
