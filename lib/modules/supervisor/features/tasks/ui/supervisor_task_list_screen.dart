import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/task_model.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_app_bar.dart';
import 'package:ground_scope/core/widgets/error_screen.dart';
import 'package:ground_scope/modules/worker/features/home/ui/widgets/list_view_task_card.dart';
import 'package:ground_scope/modules/worker/features/home/ui/widgets/task_list_empty_state.dart';
import '../logic/cubit/supervisor_task_list_cubit.dart';

class SupervisorTaskListScreen extends StatefulWidget {
  const SupervisorTaskListScreen({
    super.key,
    required this.title,
    required this.accentColor,
    required this.filterStatus,
  });

  final String title;
  final Color accentColor;
  final TaskStatus filterStatus;

  @override
  State<SupervisorTaskListScreen> createState() =>
      _SupervisorTaskListScreenState();
}

class _SupervisorTaskListScreenState extends State<SupervisorTaskListScreen> {
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
          children: [
            CustomAppBar(title: widget.title),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rw(16),
                vertical: rh(8),
              ),
              child: _SearchBar(
                controller: _searchController,
                accentColor: widget.accentColor,
                onChanged: (q) =>
                    context.read<SupervisorTaskListCubit>().search(q),
              ),
            ),
            Expanded(
              child: BlocBuilder<SupervisorTaskListCubit,
                  SupervisorTaskListState>(
                builder: (context, state) {
                  if (state is SupervisorTaskListLoading ||
                      state is SupervisorTaskListInitial) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: widget.accentColor,
                      ),
                    );
                  }

                  if (state is SupervisorTaskListFailure) {
                    return ErrorScreen(
                      error: state.error.messageKey,
                      onRetry: () => context
                          .read<SupervisorTaskListCubit>()
                          .loadTasks(widget.filterStatus),
                    );
                  }

                  final loaded = state as SupervisorTaskListLoaded;

                  if (loaded.filteredTasks.isEmpty) {
                    return TaskListEmptyState(
                      status: loaded.searchQuery.isNotEmpty
                          ? null
                          : widget.filterStatus,
                    );
                  }

                  return RefreshIndicator(
                    color: widget.accentColor,
                    onRefresh: () => context
                        .read<SupervisorTaskListCubit>()
                        .loadTasks(widget.filterStatus),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(16),
                        vertical: rh(8),
                      ),
                      itemCount: loaded.filteredTasks.length,
                      itemBuilder: (context, index) => TaskCard(
                        task: loaded.filteredTasks[index],
                        index: index,
                        isLast: index == loaded.filteredTasks.length - 1,
                      ),
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

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.accentColor,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Color accentColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.font14Light.copyWith(color: cc.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search by flight, service, or stand...',
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
          borderSide: BorderSide(color: accentColor),
        ),
      ),
    );
  }
}
