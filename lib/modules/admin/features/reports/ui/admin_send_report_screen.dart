import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ground_scope/core/shared/data/models/report_model.dart';
import 'package:ground_scope/core/shared/data/remote/user_remote_ds.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/core/widgets/custom_text_button.dart';
import 'package:ground_scope/core/widgets/custom_text_form_.dart';
import 'package:image_picker/image_picker.dart';
import '../logic/cubit/admin_reports_cubit.dart';

class AdminSendReportScreen extends StatefulWidget {
  const AdminSendReportScreen({super.key, required this.isBroadcast});

  final bool isBroadcast;

  @override
  State<AdminSendReportScreen> createState() =>
      _AdminSendReportScreenState();
}

class _AdminSendReportScreenState extends State<AdminSendReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();

  ReportType _type = ReportType.issue;
  ReportSeverity _severity = ReportSeverity.medium;
  File? _imageFile;

  List<Map<String, String>> _supervisors = [];
  final Set<String> _selectedSupervisorIds = {};
  bool _loadingSupervisors = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isBroadcast) _loadSupervisors();
  }

  Future<void> _loadSupervisors() async {
    setState(() => _loadingSupervisors = true);
    try {
      final ds = GetIt.instance<UserRemoteDs>();
      final ids = await ds.fetchSupervisorIds();
      final allUsers = await ds.fetchAll();
      final supers = allUsers
          .where((u) => ids.contains(u.id))
          .map((u) => {'id': u.id, 'name': u.fullName})
          .toList();
      if (mounted) setState(() => _supervisors = supers);
    } catch (e, st) {
      debugPrint('[AdminSendReportScreen._loadSupervisors] failed: $e\n$st');
    }
    if (mounted) setState(() => _loadingSupervisors = false);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!widget.isBroadcast && _selectedSupervisorIds.isEmpty) {
      context.showMessageSnackBar(
          'reports.actions.select_supervisor'.tr(),
          type: SnackBarType.error);
      return;
    }
    HapticFeedback.lightImpact();

    final cubit = context.read<AdminReportsCubit>();
    if (widget.isBroadcast) {
      cubit.broadcast(
          type: _type,
          severity: _severity,
          description: _descController.text.trim(),
          imageFile: _imageFile);
    } else {
      cubit.sendToSupervisors(
          supervisorIds: _selectedSupervisorIds.toList(),
          type: _type,
          severity: _severity,
          description: _descController.text.trim(),
          imageFile: _imageFile);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isBroadcast
        ? 'reports.broadcast'.tr()
        : 'reports.send_report'.tr();

    return BlocListener<AdminReportsCubit, AdminReportsState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == AdminReportsStatus.submitSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.customColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary300,
          title: Text(title,
              style: AppTextStyles.font18SemiBold
                  .copyWith(color: AppColors.white)),
          iconTheme: const IconThemeData(color: AppColors.white),
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(rw(20)),
            children: [
              if (!widget.isBroadcast) ...[
                Text('reports.actions.select_supervisor'.tr(),
                    style: AppTextStyles.font14SemiBold),
                verticalSpacing(8),
                if (_loadingSupervisors)
                  const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary200))
                else
                  ..._supervisors.map((s) => CheckboxListTile(
                        value: _selectedSupervisorIds.contains(s['id']),
                        title: Text(s['name']!),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selectedSupervisorIds.add(s['id']!);
                            } else {
                              _selectedSupervisorIds.remove(s['id']);
                            }
                          });
                        },
                        activeColor: AppColors.primary200,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      )),
                verticalSpacing(16),
              ],
              if (widget.isBroadcast) ...[
                Container(
                  padding: EdgeInsets.all(rw(16)),
                  decoration: BoxDecoration(
                    color: AppColors.red200.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(rr(12)),
                    border: Border.all(
                        color: AppColors.red200.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.red200),
                      horizontalSpacing(10),
                      Expanded(
                        child: Text(
                          'reports.actions.admin_broadcast_warning'.tr(),
                          style: AppTextStyles.font12Light
                              .copyWith(color: AppColors.red200),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpacing(16),
              ],
              Text('reports.send_form.type'.tr(),
                  style: AppTextStyles.font14SemiBold),
              verticalSpacing(8),
              Wrap(
                spacing: rw(8),
                runSpacing: rh(8),
                children: ReportType.values.map((t) {
                  final active = t == _type;
                  return ChoiceChip(
                    label: Text(t.label),
                    selected: active,
                    selectedColor: AppColors.primary200,
                    labelStyle: AppTextStyles.font12SemiBold.copyWith(
                        color: active
                            ? AppColors.white
                            : context.customColors.textSecondary),
                    onSelected: (_) => setState(() => _type = t),
                  );
                }).toList(),
              ),
              verticalSpacing(20),
              Text('reports.send_form.severity'.tr(),
                  style: AppTextStyles.font14SemiBold),
              verticalSpacing(8),
              Wrap(
                spacing: rw(8),
                runSpacing: rh(8),
                children: ReportSeverity.values.map((s) {
                  final active = s == _severity;
                  return ChoiceChip(
                    label: Text(s.label),
                    selected: active,
                    selectedColor: AppColors.primary200,
                    labelStyle: AppTextStyles.font12SemiBold.copyWith(
                        color: active
                            ? AppColors.white
                            : context.customColors.textSecondary),
                    onSelected: (_) => setState(() => _severity = s),
                  );
                }).toList(),
              ),
              verticalSpacing(20),
              Text('reports.send_form.description'.tr(),
                  style: AppTextStyles.font14SemiBold),
              verticalSpacing(8),
              CustomTextForm(
                hintText: 'reports.send_form.description'.tr(),
                controller: _descController,
                maxLines: 5,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'required'.tr() : null,
              ),
              verticalSpacing(20),
              Text('reports.send_form.attach_image'.tr(),
                  style: AppTextStyles.font14SemiBold),
              verticalSpacing(8),
              _imageFile != null
                  ? Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(rr(12)),
                        child: Image.file(_imageFile!,
                            height: rh(180),
                            width: double.infinity,
                            fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: rh(8),
                        right: rw(8),
                        child: GestureDetector(
                          onTap: () => setState(() => _imageFile = null),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: AppColors.red200,
                                shape: BoxShape.circle),
                            padding: EdgeInsets.all(rw(4)),
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.white, size: 18),
                          ),
                        ),
                      ),
                    ])
                  : GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: rh(80),
                        decoration: BoxDecoration(
                          color: context.customColors.surface,
                          borderRadius: BorderRadius.circular(rr(12)),
                          border: Border.all(
                              color: context.customColors.border),
                        ),
                        child: Center(
                          child: Icon(Icons.add_photo_alternate_rounded,
                              color: context.customColors.iconSecondary,
                              size: rf(28)),
                        ),
                      ),
                    ),
              verticalSpacing(32),
              BlocBuilder<AdminReportsCubit, AdminReportsState>(
                buildWhen: (p, c) => p.status != c.status,
                builder: (context, state) {
                  final loading =
                      state.status == AdminReportsStatus.submitting;
                  return CustomTextButton(
                    text: 'reports.send_form.send'.tr(),
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
