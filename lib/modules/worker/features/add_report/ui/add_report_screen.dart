import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';
import 'package:ground_scope/core/widgets/custom_text_form_.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/widgets/add_report_app_bar.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/widgets/section_label.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/widgets/task_selector_tile.dart';
import '../../../../../../core/shared/data/models/task_model.dart';
import '../logic/cubit/add_report_cubit.dart';
import 'widgets/image_picker_section.dart';
import 'widgets/report_severity_selector.dart';
import 'widgets/report_type_selector.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key, this.preSelectedTask});

  // final List<TaskModel> tasks;
  final TaskModel? preSelectedTask;

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _animController.forward();

    // Pre-select task if opened from task details
    if (widget.preSelectedTask != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddReportCubit>().preSelectTask(widget.preSelectedTask!);
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return BlocListener<AddReportCubit, AddReportState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddReportStatus.submitted) {
          HapticFeedback.mediumImpact();
          _descController.clear();
          context.showMessageSnackBar(
            'worker_add_report.success_message'.tr(),
            type: SnackBarType.success,
          );
          context.read<AddReportCubit>().resetForm();
        } else if (state.status == AddReportStatus.failure) {
          HapticFeedback.mediumImpact();
          context.showMessageSnackBar(
            state.error!.messageKey,
            type: SnackBarType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: customColors.background,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const AddReportAppBar(),
              SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: rw(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpacing(8),
                        TaskSelectorTile(
                          preSelectedTask: widget.preSelectedTask,
                        ),
                        verticalSpacing(24),
                        SectionLabel(label: 'report_type'.tr()),
                        verticalSpacing(10),
                        const ReportTypeSelector(),
                        verticalSpacing(24),
                        SectionLabel(label: 'report_severity'.tr()),
                        verticalSpacing(10),
                        const ReportSeveritySelector(),
                        verticalSpacing(24),
                        SectionLabel(
                          label: 'worker_add_report.description'.tr(),
                        ),
                        verticalSpacing(10),
                        CustomTextForm(
                          hintText: 'worker_add_report.description_hint'.tr(),
                          controller: _descController,
                          maxLines: 5,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'worker_add_report.description_required'.tr()
                                  : null,
                        ),
                        verticalSpacing(24),
                        SectionLabel(
                          label: 'worker_add_report.attach_photo'.tr(),
                        ),
                        verticalSpacing(10),
                        const ImagePickerSection(),
                        verticalSpacing(36),
                        CustomTextButton(
                          text: 'worker_add_report.submit'.tr(),
                          onPressed: () => _handleSubmit(context),
                        ),
                        verticalSpacing(40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();
    context.read<AddReportCubit>().submit(
      description: _descController.text.trim(),
    );
  }
}
