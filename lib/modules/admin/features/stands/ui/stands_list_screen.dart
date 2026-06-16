import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/shared/data/models/stand_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/core/widgets/ui/dialogs/app_dialogs.dart';
import 'package:ground_scope/modules/admin/features/stands/logic/cubit/stands_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/stands/ui/widgets/stand_empty_state.dart';
import 'package:ground_scope/modules/admin/features/stands/ui/widgets/stand_filter_chips.dart';
import 'package:ground_scope/modules/admin/features/stands/ui/widgets/stand_list_tile.dart';
import 'package:ground_scope/modules/admin/features/stands/ui/widgets/stand_search_bar.dart';
import 'package:ground_scope/modules/admin/features/stands/ui/widgets/stand_skeleton_tile.dart';
import 'package:ground_scope/modules/admin/features/stands/ui/widgets/stand_usage_sheet.dart';

class StandsListScreen extends StatefulWidget {
  const StandsListScreen({super.key});

  @override
  State<StandsListScreen> createState() => _StandsListScreenState();
}

class _StandsListScreenState extends State<StandsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToForm({StandModel? model}) async {
    final result = await context.pushNamed(
      Routes.adminStandFormScreen,
      arguments: model != null ? {'model': model} : null,
    );
    if (result == true && mounted) {
      context.read<StandsListCubit>().load();
    }
  }

  Future<void> _handleToggleActive(StandModel model) async {
    final cubit = context.read<StandsListCubit>();
    if (model.isActive) {
      final count = await cubit.getFlightsCount(model.id);
      if (!mounted) return;
      if (count > 0) {
        AppDialogs.showConfirm(
          context,
          message: 'stand_in_use_message'.tr(),
          onConfirm: () {
            context.pop();
            cubit.toggleActive(model);
          },
        );
        return;
      }
    }
    cubit.toggleActive(model);
  }

  void _showUsageSheet(StandModel model) {
    final cubit = context.read<StandsListCubit>();
    showStandUsageSheet(
      context: context,
      model: model,
      flightsFuture: cubit.getFlightsForStand(model.id),
      onEdit: () => _navigateToForm(model: model),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppColors.blue200,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: Text('add_stand'.tr(), style: AppTextStyles.font14SemiBold),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<StandsListCubit, StandsListState>(
                builder: (context, state) {
                  if (state.status == StandsListStatus.loading &&
                      state.all.isEmpty) {
                    return _buildSkeletonList();
                  }

                  if (state.status == StandsListStatus.failure &&
                      state.all.isEmpty) {
                    return ErrorScreen(
                      onRetry: context.read<StandsListCubit>().load,
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: rw(20)),
                        child: Column(
                          children: [
                            verticalSpacing(12),
                            StandSearchBar(
                              controller: _searchController,
                              onChanged: context
                                  .read<StandsListCubit>()
                                  .onSearchChanged,
                            ),
                            verticalSpacing(12),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: StandFilterChips(
                                selected: state.filter,
                                onSelected: context
                                    .read<StandsListCubit>()
                                    .onFilterChanged,
                              ),
                            ),
                            verticalSpacing(12),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                      Expanded(
                        child: state.filtered.isEmpty
                            ? StandEmptyState(onAdd: () => _navigateToForm())
                            : ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  rw(20),
                                  rh(4),
                                  rw(20),
                                  rh(80),
                                ),
                                itemCount: state.filtered.length,
                                itemBuilder: (_, index) {
                                  final model = state.filtered[index];
                                  final delay = Duration(
                                    milliseconds: (index * 40).clamp(0, 300),
                                  );
                                  return StandListTile(
                                    model: model,
                                    onEdit: () => _navigateToForm(model: model),
                                    onViewUsage: () => _showUsageSheet(model),
                                    onToggleActive: (_) =>
                                        _handleToggleActive(model),
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
      itemBuilder: (context, _) => const StandSkeletonTile(),
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
          const Spacer(),
          Text(
            'stands'.tr(),
            style: AppTextStyles.font18SemiBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
