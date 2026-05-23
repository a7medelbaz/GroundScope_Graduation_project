import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/router/routes.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/core/widgets/ui/dialogs/app_dialogs.dart';
import 'package:ground_scope/core/widgets/ui/loaders/overlay_loader.dart';
import 'package:ground_scope/core/shared/data/models/service_type_model.dart';
import 'package:ground_scope/modules/admin/features/service_types/logic/cubit/service_types_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_empty_state.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_filter_chips.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_list_tile.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_search_bar.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_usage_section.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.customColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(rr(20))),
      ),
      builder: (_) => FutureBuilder(
        future: cubit.getUsage(model.id),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.all(rw(48)),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          return ServiceTypeUsageSection(
            model: model,
            usage: snapshot.data!,
          );
        },
      ),
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
              child: BlocBuilder<ServiceTypesListCubit, ServiceTypesListState>(
                builder: (context, state) {
                  if (state.status == ServiceTypesListStatus.loading &&
                      state.all.isEmpty) {
                    return const OverlayLoader(
                      isLoading: true,
                      child: SizedBox.expand(),
                    );
                  }

                  if (state.status == ServiceTypesListStatus.failure &&
                      state.all.isEmpty) {
                    return ErrorScreen(
                      onRetry: context.read<ServiceTypesListCubit>().load,
                    );
                  }

                  return OverlayLoader(
                    isLoading: state.status == ServiceTypesListStatus.loading,
                    child: Column(
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
                        ),
                        Expanded(
                          child: state.filtered.isEmpty
                              ? ServiceTypeEmptyState(
                                  onAdd: () => _navigateToForm(),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: rw(20),
                                    vertical: rh(4),
                                  ),
                                  itemCount: state.filtered.length,
                                  itemBuilder: (_, index) {
                                    final model = state.filtered[index];
                                    return ServiceTypeListTile(
                                      model: model,
                                      onEdit: () =>
                                          _navigateToForm(model: model),
                                      onViewUsage: () =>
                                          _showUsageBottomSheet(model),
                                      onToggleActive: (_) =>
                                          _handleToggleActive(model),
                                    );
                                  },
                                ),
                        ),
                      ],
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
            style: TextStyle(
              fontSize: rf(18),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary200),
            onPressed: () => _navigateToForm(),
          ),
        ],
      ),
    );
  }
}
