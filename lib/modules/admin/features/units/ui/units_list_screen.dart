import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/modules/admin/features/units/logic/cubit/units_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_empty_state.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_filter_chips.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_list_tile.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_search_bar.dart';
import 'package:ground_scope/modules/admin/features/units/ui/widgets/unit_skeleton_tile.dart';

class UnitsListScreen extends StatefulWidget {
  const UnitsListScreen({super.key});

  @override
  State<UnitsListScreen> createState() => _UnitsListScreenState();
}

class _UnitsListScreenState extends State<UnitsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToForm({UnitModel? model}) async {
    final result = await context.pushNamed(
      Routes.adminUnitFormScreen,
      arguments: model != null ? {'model': model} : null,
    );
    if (result == true && mounted) {
      context.read<UnitsListCubit>().load();
    }
  }

  Future<void> _navigateToDetail(UnitModel model) async {
    final result = await context.pushNamed(
      Routes.adminUnitDetailScreen,
      arguments: {'unit': model},
    );
    if (result == true && mounted) {
      context.read<UnitsListCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppColors.green200,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: Text('add_unit'.tr(), style: AppTextStyles.font14SemiBold),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<UnitsListCubit, UnitsListState>(
                builder: (context, state) {
                  if (state.status == UnitsListStatus.loading &&
                      state.all.isEmpty) {
                    return _buildSkeleton();
                  }

                  if (state.status == UnitsListStatus.failure &&
                      state.all.isEmpty) {
                    return ErrorScreen(
                      onRetry: context.read<UnitsListCubit>().load,
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: rw(20)),
                        child: Column(
                          children: [
                            verticalSpacing(12),
                            UnitSearchBar(
                              controller: _searchController,
                              onChanged:
                                  context.read<UnitsListCubit>().onSearchChanged,
                            ),
                            verticalSpacing(12),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: UnitFilterChips(
                                selected: state.filter,
                                onSelected:
                                    context.read<UnitsListCubit>().onFilterChanged,
                              ),
                            ),
                            verticalSpacing(8),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                      Expanded(
                        child: state.filtered.isEmpty
                            ? UnitEmptyState(onAdd: () => _navigateToForm())
                            : ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  rw(20),
                                  rh(4),
                                  rw(20),
                                  rh(80),
                                ),
                                itemCount: state.filtered.length,
                                itemBuilder: (_, index) {
                                  final unit = state.filtered[index];
                                  final delay = Duration(
                                    milliseconds: (index * 40).clamp(0, 300),
                                  );
                                  return UnitListTile(
                                    model: unit,
                                    onTap: () => _navigateToDetail(unit),
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

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(rw(20), rh(16), rw(20), rh(80)),
      itemCount: 5,
      itemBuilder: (_, __) => const UnitSkeletonTile(),
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
            'units'.tr(),
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
