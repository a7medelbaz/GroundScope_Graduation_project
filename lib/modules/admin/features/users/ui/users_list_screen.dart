import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/ui/widgets/credentials_share_sheet.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/modules/admin/features/users/logic/cubit/user_reset_cubit.dart';
import 'package:ground_scope/modules/admin/features/users/logic/cubit/users_list_cubit.dart';
import 'package:ground_scope/modules/admin/features/users/ui/widgets/user_empty_state.dart';
import 'package:ground_scope/modules/admin/features/users/ui/widgets/user_filter_chips.dart';
import 'package:ground_scope/modules/admin/features/users/ui/widgets/user_list_tile.dart';
import 'package:ground_scope/modules/admin/features/users/ui/widgets/user_skeleton_tile.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserResetCubit, UserResetState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == UserResetStatus.success &&
            state.newCredentials != null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: Colors.transparent,
            builder: (_) => CredentialsShareSheet(
              credentials: state.newCredentials!,
              onDone: () {
                Navigator.of(context).pop();
                context.read<UserResetCubit>().reset();
              },
            ),
          );
        } else if (state.status == UserResetStatus.failure &&
            state.error != null) {
          context.showErrorSnackBar(state.error!.messageKey);
        } else if (state.status == UserResetStatus.resetting) {
          context.showSuccessSnackBar('resetting_password'.tr());
        }
      },
      child: Scaffold(
        backgroundColor: context.customColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _AppBar(),
              BlocBuilder<UsersListCubit, UsersListState>(
                buildWhen: (prev, curr) => prev.filter != curr.filter,
                builder: (context, state) => UserFilterChips(
                  selected: state.filter,
                  onChanged: context.read<UsersListCubit>().onFilterChanged,
                ),
              ),
              Expanded(
                child: BlocBuilder<UsersListCubit, UsersListState>(
                  builder: (context, state) {
                    if (state.status == UsersListStatus.loading ||
                        state.status == UsersListStatus.initial) {
                      return _Skeleton();
                    }
                    if (state.status == UsersListStatus.failure) {
                      return ErrorScreen(
                        error: state.error?.messageKey ?? '',
                        onRetry: () =>
                            context.read<UsersListCubit>().load(),
                      );
                    }
                    if (state.filtered.isEmpty) {
                      return const UserEmptyState();
                    }
                    return RefreshIndicator(
                      color: AppColors.primary200,
                      onRefresh: () =>
                          context.read<UsersListCubit>().load(),
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(16),
                          vertical: rh(12),
                        ),
                        itemCount: state.filtered.length,
                        itemBuilder: (context, index) {
                          final user = state.filtered[index];
                          return UserListTile(
                            user: user,
                            animationDelay:
                                Duration(milliseconds: index * 40),
                            onResetSuccess: () {},
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: rw(8), vertical: rh(8)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: context.pop,
          ),
          const Spacer(),
          Text(
            'users'.tr(),
            style: AppTextStyles.font18SemiBold.copyWith(
              color: context.customColors.textPrimary,
            ),
          ),
          const Spacer(),
          BlocBuilder<UsersListCubit, UsersListState>(
            buildWhen: (prev, curr) => prev.status != curr.status,
            builder: (context, state) {
              if (state.status == UsersListStatus.loading) {
                return SizedBox(
                  width: rw(20),
                  height: rw(20),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary200,
                  ),
                );
              }
              return SizedBox(width: rw(48));
            },
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(12)),
      itemCount: 5,
      itemBuilder: (_, __) => const UserSkeletonTile(),
    );
  }
}
