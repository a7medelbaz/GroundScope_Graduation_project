import 'dart:io';
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
import 'package:image_picker/image_picker.dart';
import '../logic/cubit/supervisor_reports_cubit.dart';
import 'package:ground_scope/modules/supervisor/features/units/data/remote/supervisor_units_remote_ds.dart';
import 'package:get_it/get_it.dart';
import 'package:ground_scope/core/shared/data/models/unit_model.dart';

class SupervisorSendReportScreen extends StatefulWidget {
  const SupervisorSendReportScreen({
    super.key,
    required this.serviceTypeId,
    required this.isBroadcast,
  });

  final String serviceTypeId;
  final bool isBroadcast;

  @override
  State<SupervisorSendReportScreen> createState() =>
      _SupervisorSendReportScreenState();
}

class _SupervisorSendReportScreenState
    extends State<SupervisorSendReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();

  ReportType _type = ReportType.issue;
  ReportSeverity _severity = ReportSeverity.medium;
  File? _imageFile;
  UnitModel? _selectedUnit;
  List<UnitModel> _units = [];
  bool _loadingUnits = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isBroadcast) _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() => _loadingUnits = true);
    try {
      final ds = GetIt.instance<SupervisorUnitsRemoteDs>();
      final units =
          await ds.fetchUnits(widget.serviceTypeId);
      if (mounted) setState(() => _units = units);
    } catch (_) {
      if (mounted) {
        context.showMessageSnackBar(
          'reports.actions.select_unit_load_failed'.tr(),
          type: SnackBarType.error,
        );
      }
    }
    if (mounted) setState(() => _loadingUnits = false);
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
    if (!widget.isBroadcast && _selectedUnit == null) {
      context.showMessageSnackBar('reports.actions.select_unit'.tr(),
          type: SnackBarType.error);
      return;
    }
    HapticFeedback.lightImpact();

    final cubit = context.read<SupervisorReportsCubit>();
    if (widget.isBroadcast) {
      cubit.broadcastToAll(
        serviceTypeId: widget.serviceTypeId,
        type: _type,
        severity: _severity,
        description: _descController.text.trim(),
        imageFile: _imageFile,
      );
    } else {
      cubit.sendToUnit(
        unitId: _selectedUnit!.id,
        type: _type,
        severity: _severity,
        description: _descController.text.trim(),
        imageFile: _imageFile,
      );
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final title = widget.isBroadcast
        ? 'reports.broadcast'.tr()
        : 'reports.send_report'.tr();

    return BlocListener<SupervisorReportsCubit, SupervisorReportsState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == SupervisorReportsStatus.submitSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: cc.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary300,
          title: Text(title,
              style:
                  AppTextStyles.font18SemiBold.copyWith(color: AppColors.white)),
          iconTheme: const IconThemeData(color: AppColors.white),
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(rw(20)),
            children: [
              if (!widget.isBroadcast) ...[
                _SectionLabel('reports.actions.select_unit'.tr()),
                verticalSpacing(8),
                _UnitSelector(
                  units: _units,
                  selected: _selectedUnit,
                  loading: _loadingUnits,
                  onSelected: (u) => setState(() => _selectedUnit = u),
                ),
                verticalSpacing(20),
              ],
              _SectionLabel('reports.send_form.type'.tr()),
              verticalSpacing(8),
              _TypeSelector(
                  selected: _type,
                  onSelected: (t) => setState(() => _type = t)),
              verticalSpacing(20),
              _SectionLabel('reports.send_form.severity'.tr()),
              verticalSpacing(8),
              _SeveritySelector(
                  selected: _severity,
                  onSelected: (s) => setState(() => _severity = s)),
              verticalSpacing(20),
              _SectionLabel('reports.send_form.description'.tr()),
              verticalSpacing(8),
              CustomTextForm(
                hintText: 'reports.send_form.description'.tr(),
                controller: _descController,
                maxLines: 5,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'required'.tr() : null,
              ),
              verticalSpacing(20),
              _SectionLabel('reports.send_form.attach_image'.tr()),
              verticalSpacing(8),
              _ImagePicker(
                  imageFile: _imageFile,
                  onPick: _pickImage,
                  onRemove: () => setState(() => _imageFile = null)),
              verticalSpacing(32),
              BlocBuilder<SupervisorReportsCubit, SupervisorReportsState>(
                buildWhen: (p, c) => p.status != c.status,
                builder: (context, state) {
                  final loading =
                      state.status == SupervisorReportsStatus.submitting;
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.font14SemiBold
          .copyWith(color: context.customColors.textPrimary),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({
    required this.units,
    required this.selected,
    required this.loading,
    required this.onSelected,
  });
  final List<UnitModel> units;
  final UnitModel? selected;
  final bool loading;
  final ValueChanged<UnitModel> onSelected;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    if (loading) {
      return Container(
          height: rh(48),
          decoration: BoxDecoration(
              color: cc.surface,
              borderRadius: BorderRadius.circular(rr(12))),
          child: const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary200)));
    }
    return DropdownButtonFormField<UnitModel>(
      initialValue: selected,
      decoration: InputDecoration(
        filled: true,
        fillColor: cc.surface,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(rr(12))),
        contentPadding:
            EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
      ),
      hint: Text('reports.actions.select_unit'.tr()),
      items: units
          .map((u) =>
              DropdownMenuItem(value: u, child: Text(u.name)))
          .toList(),
      onChanged: (u) {
        if (u != null) onSelected(u);
      },
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector(
      {required this.selected, required this.onSelected});
  final ReportType selected;
  final ValueChanged<ReportType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: rw(8),
      runSpacing: rh(8),
      children: ReportType.values.map((t) {
        final active = t == selected;
        return ChoiceChip(
          label: Text(t.label),
          selected: active,
          selectedColor: AppColors.primary200,
          labelStyle: AppTextStyles.font12SemiBold.copyWith(
              color: active
                  ? AppColors.white
                  : context.customColors.textSecondary),
          onSelected: (_) => onSelected(t),
        );
      }).toList(),
    );
  }
}

class _SeveritySelector extends StatelessWidget {
  const _SeveritySelector(
      {required this.selected, required this.onSelected});
  final ReportSeverity selected;
  final ValueChanged<ReportSeverity> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: rw(8),
      runSpacing: rh(8),
      children: ReportSeverity.values.map((s) {
        final active = s == selected;
        return ChoiceChip(
          label: Text(s.label),
          selected: active,
          selectedColor: AppColors.primary200,
          labelStyle: AppTextStyles.font12SemiBold.copyWith(
              color: active
                  ? AppColors.white
                  : context.customColors.textSecondary),
          onSelected: (_) => onSelected(s),
        );
      }).toList(),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker(
      {required this.imageFile,
      required this.onPick,
      required this.onRemove});
  final File? imageFile;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    if (imageFile != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(rr(12)),
            child: Image.file(imageFile!,
                height: rh(180), width: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            top: rh(8),
            right: rw(8),
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(
                    color: AppColors.red200, shape: BoxShape.circle),
                padding: EdgeInsets.all(rw(4)),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: rh(100),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(color: cc.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded,
                color: cc.iconSecondary, size: rf(32)),
            verticalSpacing(8),
            Text('reports.send_form.attach_image'.tr(),
                style: AppTextStyles.font12Light
                    .copyWith(color: cc.textHint)),
          ],
        ),
      ),
    );
  }
}
