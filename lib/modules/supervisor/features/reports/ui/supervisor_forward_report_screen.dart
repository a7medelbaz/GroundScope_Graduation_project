import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';
import 'package:ground_scope/core/widgets/custom_text_form_.dart';
import '../logic/cubit/supervisor_reports_cubit.dart';

class SupervisorForwardReportScreen extends StatefulWidget {
  const SupervisorForwardReportScreen({super.key, required this.report});

  final ReportModel report;

  @override
  State<SupervisorForwardReportScreen> createState() =>
      _SupervisorForwardReportScreenState();
}

class _SupervisorForwardReportScreenState
    extends State<SupervisorForwardReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    context.read<SupervisorReportsCubit>().forwardToAdmin(
          original: widget.report,
          notes: _notesController.text.trim(),
        );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocListener<SupervisorReportsCubit, SupervisorReportsState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == SupervisorReportsStatus.submitSuccess) {
          context.showMessageSnackBar(
            'reports.actions.forward'.tr(),
            type: SnackBarType.success,
          );
          Navigator.of(context)
            ..pop()
            ..pop();
        }
      },
      child: Scaffold(
        backgroundColor: cc.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary300,
          title: Text(
            'reports.actions.forward'.tr(),
            style: AppTextStyles.font18SemiBold
                .copyWith(color: AppColors.white),
          ),
          iconTheme: const IconThemeData(color: AppColors.white),
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(rw(20)),
            children: [
              // Summary card
              Container(
                padding: EdgeInsets.all(rw(16)),
                decoration: BoxDecoration(
                  color: cc.surface,
                  borderRadius: BorderRadius.circular(rr(14)),
                  border: Border.all(color: cc.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.report.type.label,
                      style: AppTextStyles.font14SemiBold,
                    ),
                    verticalSpacing(4),
                    Text(
                      widget.report.description,
                      style: AppTextStyles.font12Light
                          .copyWith(color: cc.textSecondary),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              verticalSpacing(20),
              Text(
                'reports.actions.add_notes'.tr(),
                style: AppTextStyles.font14SemiBold,
              ),
              verticalSpacing(8),
              CustomTextForm(
                hintText: 'reports.actions.notes_hint'.tr(),
                controller: _notesController,
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'required'.tr()
                    : null,
              ),
              verticalSpacing(32),
              BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
                buildWhen: (p, c) => p.status != c.status,
                builder: (context, state) {
                  final loading =
                      state.status == SupervisorReportsStatus.submitting;
                  return CustomTextButton(
                    text: 'reports.forward_to_admin'.tr(),
                    isLoading: loading,
                    onPressed: loading ? null : _submit,
                  );
                },
              ),
              verticalSpacing(40),
            ],
          ),
        ),
      ),
    );
  }
}
