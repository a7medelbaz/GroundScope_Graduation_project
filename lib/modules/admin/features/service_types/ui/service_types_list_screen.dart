import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/core/widgets/ui/dialogs/app_dialogs.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/modules/admin/features/service_types/logic/cubit/service_types_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_empty_state.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_filter_chips.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_list_tile.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_search_bar.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_skeleton_tile.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_usage_sheet.dart';

class ServiceTypesListScreen extends StatefulWidget {
  const ServiceTypesListScreen({super.key});

  @override
  State<ServiceTypesListScreen> createState() => _ServiceTypesListScreenState();
}

class _ServiceTypesListScreenState extends State<ServiceTypesListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ServiceTypesListCubit>().load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToForm({ServiceTypeModel? model}) async {
    final result = await context.pushNamed<bool>(
      Routes.adminServiceTypeFormScreen,
      arguments: model != null ? {'model': model} : null,
    );
    if (result == true && mounted) {
      context.read<ServiceTypesListCubit>().load();
    }
  }

  Future<void> _handleToggleActive(ServiceTypeModel model) async {
    final cubit = context.read<ServiceTypesListCubit>();
    if (model.isActive) {
      final usage = await cubit.getUsage(model.id);
      if (!mounted) return;
      if (usage.isInUse) {
        AppDialogs.showConfirm(
          context,
          message: 'service_type_in_use_message'.tr(),
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

  void _showUsageBottomSheet(ServiceTypeModel model) {
    final cubit = context.read<ServiceTypesListCubit>();
    showServiceTypeUsageSheet(
      context: context,
      model: model,
      usageFuture: cubit.getUsage(model.id),
      onEdit: () => _navigateToForm(model: model),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppColors.primary200,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: Text('add_service_type'.tr(), style: AppTextStyles.font14SemiBold),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<ServiceTypesListCubit, ServiceTypesListState>(
                builder: (context, state) {
                  if (state.status == ServiceTypesListStatus.loading &&
                      state.all.isEmpty) {
                    return _buildSkeletonList();
                  }

                  if (state.status == ServiceTypesListStatus.failure &&
                      state.all.isEmpty) {
                    return ErrorScreen(
                      onRetry: context.read<ServiceTypesListCubit>().load,
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: rw(20)),
                        child: Column(
                          children: [
                            verticalSpacing(12),
                            ServiceTypeSearchBar(
                              controller: _searchController,
                              onChanged: context
                                  .read<ServiceTypesListCubit>()
                                  .onSearchChanged,
                            ),
                            verticalSpacing(12),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ServiceTypeFilterChips(
                                selected: state.filter,
                                onSelected: context
                                    .read<ServiceTypesListCubit>()
                                    .onFilterChanged,
                              ),
                            ),
                            verticalSpacing(12),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                      Expanded(
                        child: state.filtered.isEmpty
                            ? ServiceTypeEmptyState(
                                onAdd: () => _navigateToForm(),
                              )
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
                                  return ServiceTypeListTile(
                                    model: model,
                                    onEdit: () => _navigateToForm(model: model),
                                    onViewUsage: () =>
                                        _showUsageBottomSheet(model),
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
      itemBuilder: (context, _) => const ServiceTypeSkeletonTile(),
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
            'service_types'.tr(),
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
