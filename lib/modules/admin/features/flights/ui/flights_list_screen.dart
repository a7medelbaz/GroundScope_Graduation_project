import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/shared/data/models/flight_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/modules/admin/features/flights/logic/cubit/flight_import_cubit.dart';
import 'package:ground_scope/modules/admin/features/flights/logic/cubit/flights_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/flight_empty_state.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/flight_filter_chips.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/flight_import_sheet.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/flight_list_tile.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/flight_search_bar.dart';
import 'package:ground_scope/modules/admin/features/flights/ui/widgets/flight_skeleton_tile.dart';

class FlightsListScreen extends StatefulWidget {
  const FlightsListScreen({super.key});

  @override
  State<FlightsListScreen> createState() => _FlightsListScreenState();
}

class _FlightsListScreenState extends State<FlightsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openImportSheet() {
    final listCubit = context.read<FlightsListCubit>();
    final importCubit = getIt<FlightImportCubit>();
    showFlightImportSheet(
      context: context,
      cubit: importCubit,
      onImported: () => listCubit.load(),
    );
  }

  void _navigateToDetail(FlightModel flight) {
    context.pushNamed(
      Routes.adminFlightDetailScreen,
      arguments: {'flight': flight, 'cubit': context.read<FlightsListCubit>()},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<FlightsListCubit, FlightsListState>(
                builder: (context, state) {
                  if (state.status == FlightsListStatus.loading &&
                      state.all.isEmpty) {
                    return _buildSkeletonList();
                  }

                  if (state.status == FlightsListStatus.failure &&
                      state.all.isEmpty) {
                    debugPrint(
                      'FlightsListScreen: Error loading flights: ${state.error?.messageKey}',
                    );
                    return ErrorScreen(
                      error: state.error?.messageKey,
                      onRetry: context.read<FlightsListCubit>().load,
                    );
                  }

                  return Column(
                    children: [
                      if (state.warningFlights.isNotEmpty)
                        _WarningBanner(
                          count: state.warningFlights.length,
                        ).animate().fadeIn(duration: 300.ms),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: rw(20)),
                        child: Column(
                          children: [
                            verticalSpacing(12),
                            FlightSearchBar(
                              controller: _searchController,
                              onChanged: context
                                  .read<FlightsListCubit>()
                                  .onSearchChanged,
                            ),
                            verticalSpacing(12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: FlightFilterChips(
                                selected: state.filter,
                                onSelected: context
                                    .read<FlightsListCubit>()
                                    .onFilterChanged,
                              ),
                            ),
                            verticalSpacing(12),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                      Expanded(
                        child:
                            state.filtered.isEmpty &&
                                state.filter != FlightsFilter.all
                            ? FlightEmptyState(onFetch: _openImportSheet)
                            : state.filter == FlightsFilter.all &&
                                  state.searchQuery.isEmpty
                            ? _buildGroupedList(context, state)
                            : state.filtered.isEmpty
                            ? FlightEmptyState(onFetch: _openImportSheet)
                            : _buildFlatList(context, state),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatList(BuildContext context, FlightsListState state) {
    final cubit = context.read<FlightsListCubit>();
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(rw(20), rh(4), rw(20), rh(80)),
      itemCount: state.filtered.length,
      itemBuilder: (_, index) {
        final flight = state.filtered[index];
        return FlightListTile(
          flight: flight,
          isWarning: cubit.isWarning(flight),
          onTap: () => _navigateToDetail(flight),
          animationDelay: Duration(milliseconds: (index * 40).clamp(0, 300)),
        );
      },
    );
  }

  Widget _buildGroupedList(BuildContext context, FlightsListState state) {
    final cubit = context.read<FlightsListCubit>();
    final all = state.all;

    final active = all
        .where(
          (f) =>
              f.status == FlightStatus.landed ||
              f.status == FlightStatus.inService,
        )
        .toList();
    final scheduled = all
        .where((f) => f.status == FlightStatus.scheduled)
        .toList();
    final ready = all.where((f) => f.status == FlightStatus.ready).toList();
    final departed = all
        .where(
          (f) =>
              f.status == FlightStatus.departed ||
              f.status == FlightStatus.cancelled,
        )
        .toList();

    if (all.isEmpty) return FlightEmptyState(onFetch: _openImportSheet);

    final sections = <_Section>[
      if (active.isNotEmpty)
        _Section(
          title: 'section_active'.tr(namedArgs: {'count': '${active.length}'}),
          flights: active,
        ),
      if (scheduled.isNotEmpty)
        _Section(
          title: 'section_scheduled'.tr(
            namedArgs: {'count': '${scheduled.length}'},
          ),
          flights: scheduled,
        ),
      if (ready.isNotEmpty)
        _Section(
          title: 'section_ready'.tr(namedArgs: {'count': '${ready.length}'}),
          flights: ready,
        ),
      if (departed.isNotEmpty)
        _Section(
          title: 'section_departed'.tr(
            namedArgs: {'count': '${departed.length}'},
          ),
          flights: departed,
        ),
    ];

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(rw(20), rh(4), rw(20), rh(80)),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Build flat list: section header + tiles interleaved
                int offset = 0;
                for (final section in sections) {
                  if (index == offset) {
                    return _FlightSectionHeader(title: section.title);
                  }
                  offset++;
                  final localIdx = index - offset;
                  if (localIdx < section.flights.length) {
                    final flight = section.flights[localIdx];
                    return FlightListTile(
                      flight: flight,
                      isWarning: cubit.isWarning(flight),
                      onTap: () => _navigateToDetail(flight),
                      animationDelay: Duration(
                        milliseconds: (localIdx * 40).clamp(0, 300),
                      ),
                    );
                  }
                  offset += section.flights.length;
                }
                return null;
              },
              childCount: sections.fold(
                0,
                (sum, s) => sum ?? 0 + 1 + s.flights.length,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(rw(20), rh(16), rw(20), rh(80)),
      itemCount: 6,
      itemBuilder: (context, _) => const FlightSkeletonTile(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(8)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: context.pop,
          ),
          Expanded(
            child: Text(
              'flights'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.font18SemiBold.copyWith(
                color: context.customColors.textPrimary,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _openImportSheet,
            icon: const Icon(Icons.download_outlined, size: 18),
            label: Text(
              'fetch_today'.tr(),
              style: AppTextStyles.font12SemiBold,
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.blue200),
          ),
        ],
      ),
    );
  }
}

class _Section {
  const _Section({required this.title, required this.flights});
  final String title;
  final List<FlightModel> flights;
}

class _FlightSectionHeader extends StatelessWidget {
  const _FlightSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: rh(16), bottom: rh(8)),
      child: Row(
        children: [
          Expanded(
            child: Divider(thickness: 0.5, color: context.customColors.divider),
          ),
          horizontalSpacing(8),
          Text(
            title.toUpperCase(),
            style: AppTextStyles.font12SemiBold.copyWith(
              color: context.customColors.textHint,
              letterSpacing: 0.6,
            ),
          ),
          horizontalSpacing(8),
          Expanded(
            child: Divider(thickness: 0.5, color: context.customColors.divider),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(rw(20), rh(8), rw(20), 0),
      padding: EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(10)),
      decoration: BoxDecoration(
        color: AppColors.amber200.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rr(12)),
        border: Border.all(color: AppColors.amber200.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: rw(18),
            color: AppColors.amber200,
          ),
          horizontalSpacing(8),
          Expanded(
            child: Text(
              'warning_flights_banner'.tr(namedArgs: {'count': '$count'}),
              style: AppTextStyles.font12SemiBold.copyWith(
                color: AppColors.amber400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
