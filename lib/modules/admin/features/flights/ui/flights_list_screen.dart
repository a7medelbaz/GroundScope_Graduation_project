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
                    return ErrorScreen(
                      onRetry: context.read<FlightsListCubit>().load,
                    );
                  }

                  return Column(
                    children: [
                      if (state.warningFlights.isNotEmpty)
                        _WarningBanner(count: state.warningFlights.length)
                            .animate()
                            .fadeIn(duration: 300.ms),
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
                        child: state.filtered.isEmpty
                            ? FlightEmptyState(onFetch: _openImportSheet)
                            : ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  rw(20),
                                  rh(4),
                                  rw(20),
                                  rh(80),
                                ),
                                itemCount: state.filtered.length,
                                itemBuilder: (_, index) {
                                  final flight = state.filtered[index];
                                  final cubit = context.read<FlightsListCubit>();
                                  final delay = Duration(
                                    milliseconds: (index * 40).clamp(0, 300),
                                  );
                                  return FlightListTile(
                                    flight: flight,
                                    isWarning: cubit.isWarning(flight),
                                    onTap: () => _navigateToDetail(flight),
                                    animationDelay: delay,
                                  );
                                },
                              ),
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
            label: Text('fetch_today'.tr(), style: AppTextStyles.font12SemiBold),
            style: TextButton.styleFrom(foregroundColor: AppColors.blue200),
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
          Icon(Icons.warning_amber_rounded, size: rw(18), color: AppColors.amber200),
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
