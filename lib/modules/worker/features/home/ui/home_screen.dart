import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/auth/logic/cubit/auth_cubit.dart';
import '../../../../../core/shared/data/models/unit_model.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/spacing.dart';
import '../logic/cubit/home_cubit.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/worker_tasks_list_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          // 1. Handle Auth State first
          if (authState is! AuthSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = authState.userModel;
          return BlocBuilder<HomeCubit, HomeState>(
            builder: (context, homeState) {
              final unit = homeState is HomeLoaded
                  ? homeState.unit
                  : const UnitModel(
                      id: "",
                      name: "",
                      serviceTypeId: "",
                      status: "",
                    );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeAppBar(userModel: user, unitModel: unit as UnitModel),
                  verticalSpacing(16),
                  Expanded(child: _buildHomeBody(context, homeState)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is HomeFailure) {
      print('Error loading tasks: ${state.error.messageKey}'); // Debug log
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Error loading tasks: ${state.error.messageKey}',
            textAlign: TextAlign.center,
            style: AppTextStyles.font14Light.copyWith(color: AppColors.red300),
          ),
        ),
      );
    }
    if (state is HomeLoaded) {
      return WorkerTasksListView(
        tasks: state.tasks,
        onRefresh: () async {
          await context.read<HomeCubit>().init();
        },
      );
    }
    return const Center(child: Text('No tasks available'));
  }
}
