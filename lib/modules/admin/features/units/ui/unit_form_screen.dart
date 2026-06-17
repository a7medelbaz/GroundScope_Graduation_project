import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/data/models/unit_profile_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/units/logic/cubit/unit_form_cubit.dart';

class UnitFormScreen extends StatefulWidget {
  const UnitFormScreen({super.key});

  @override
  State<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends State<UnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _aircraftController;
  String? _selectedServiceTypeId;
  UnitStatus _selectedStatus = UnitStatus.available;
  String? _shiftStartTime;
  String? _shiftEndTime;

  @override
  void initState() {
    super.initState();
    final editing = context.read<UnitFormCubit>().state.editing;
    _nameController = TextEditingController(text: editing?.name ?? '');
    _aircraftController = TextEditingController(
      text: editing != null ? editing.compatibleAircraft.join(', ') : '',
    );
    _selectedServiceTypeId = editing?.serviceTypeId;
    _selectedStatus =
        editing != null ? UnitStatus.fromString(editing.status) : UnitStatus.available;
    _shiftStartTime = editing?.shiftStartTime;
    _shiftEndTime = editing?.shiftEndTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aircraftController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _shiftStartTime : _shiftEndTime;
    TimeOfDay initial = TimeOfDay.now();
    if (current != null) {
      final parts = current.split(':');
      if (parts.length >= 2) {
        initial = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isStart) {
        _shiftStartTime = formatted;
      } else {
        _shiftEndTime = formatted;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final aircraft = _aircraftController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final cubit = context.read<UnitFormCubit>();
    final success = await cubit.submit(
      name: _nameController.text.trim(),
      serviceTypeId: _selectedServiceTypeId!,
      status: _selectedStatus,
      compatibleAircraft: aircraft,
      shiftStartTime: _shiftStartTime,
      shiftEndTime: _shiftEndTime,
    );

    if (!mounted) return;
    if (success) {
      context.showSuccessSnackBar('unit_saved_successfully'.tr());
      context.pop(true);
    } else {
      final error = cubit.state.error;
      if (error != null) context.showErrorSnackBar(error.messageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      body: SafeArea(
        child: BlocBuilder<UnitFormCubit, UnitFormState>(
          builder: (context, state) {
            final isEditMode = state.isEditMode;
            final title = isEditMode ? 'edit_unit'.tr() : 'add_unit'.tr();
            final submitting = state.status == UnitFormStatus.submitting;

            return Column(
              children: [
                _buildAppBar(context, title),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: rw(20), vertical: rh(16)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _FormHeader(title: title, isEditMode: isEditMode)
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.1, end: 0, duration: 300.ms),
                          verticalSpacing(24),
                          _buildFormCard(context, state)
                              .animate(delay: 80.ms)
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.1, end: 0, duration: 300.ms),
                          verticalSpacing(28),
                          Opacity(
                            opacity: submitting ? 0.6 : 1.0,
                            child: SizedBox(
                              width: double.infinity,
                              height: rh(56),
                              child: ElevatedButton(
                                onPressed: submitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green200,
                                  foregroundColor: AppColors.white,
                                  disabledBackgroundColor:
                                      AppColors.green200.withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(rr(16)),
                                  ),
                                ),
                                child: submitting
                                    ? SizedBox(
                                        width: rw(20),
                                        height: rw(20),
                                        child: const CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'save'.tr(),
                                        style: AppTextStyles.font16SemiBold
                                            .copyWith(color: AppColors.white),
                                      ),
                              ),
                            ),
                          )
                              .animate(delay: 160.ms)
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.1, end: 0, duration: 300.ms),
                          verticalSpacing(16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, UnitFormState state) {
    return Container(
      padding: EdgeInsets.all(rw(20)),
      decoration: BoxDecoration(
        color: context.customColors.surface,
        borderRadius: BorderRadius.circular(rr(16)),
        border: Border.all(color: context.customColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, 'unit_name'.tr()),
          verticalSpacing(8),
          TextFormField(
            controller: _nameController,
            style: AppTextStyles.font14Light
                .copyWith(color: context.customColors.textPrimary),
            decoration: _inputDeco(context, hint: 'Fueling Team A'),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'auth.validation.required'.tr()
                : null,
          ),
          verticalSpacing(16),
          _label(context, 'service_type'.tr()),
          verticalSpacing(8),
          DropdownButtonFormField<String>(
            value: _selectedServiceTypeId,
            hint: Text(
              'select_service_type'.tr(),
              style: AppTextStyles.font14Light
                  .copyWith(color: context.customColors.textHint),
            ),
            decoration: _inputDeco(context),
            items: state.serviceTypes
                .map((st) => DropdownMenuItem(
                      value: st.id,
                      child: Text(st.name,
                          style: AppTextStyles.font14Light.copyWith(
                              color: context.customColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedServiceTypeId = v),
            validator: (v) => v == null ? 'auth.validation.required'.tr() : null,
          ),
          verticalSpacing(16),
          _label(context, 'unit_status'.tr()),
          verticalSpacing(8),
          DropdownButtonFormField<UnitStatus>(
            value: _selectedStatus,
            decoration: _inputDeco(context),
            items: UnitStatus.values
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.label.tr(),
                          style: AppTextStyles.font14Light.copyWith(
                              color: context.customColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedStatus = v);
            },
          ),
          verticalSpacing(16),
          _label(context, 'unit_compatible_aircraft'.tr()),
          verticalSpacing(8),
          TextFormField(
            controller: _aircraftController,
            style: AppTextStyles.font14Light
                .copyWith(color: context.customColors.textPrimary),
            decoration: _inputDeco(context, hint: 'unit_aircraft_hint'.tr()),
          ),
          verticalSpacing(4),
          Text(
            'unit_aircraft_hint'.tr(),
            style: AppTextStyles.font12Light
                .copyWith(color: context.customColors.textSecondary),
          ),
          verticalSpacing(16),
          _label(context, 'shift_start'.tr()),
          verticalSpacing(8),
          _timePickerField(
            context,
            value: _shiftStartTime,
            hint: '06:00',
            onTap: () => _pickTime(isStart: true),
          ),
          verticalSpacing(16),
          _label(context, 'shift_end'.tr()),
          verticalSpacing(8),
          _timePickerField(
            context,
            value: _shiftEndTime,
            hint: '14:00',
            onTap: () => _pickTime(isStart: false),
          ),
        ],
      ),
    );
  }

  Widget _timePickerField(
    BuildContext context, {
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: rh(50),
        padding: EdgeInsets.symmetric(horizontal: rw(16)),
        decoration: BoxDecoration(
          color: context.customColors.background,
          borderRadius: BorderRadius.circular(rr(12)),
          border: Border.all(color: context.customColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: AppTextStyles.font14Light.copyWith(
                  color: value != null
                      ? context.customColors.textPrimary
                      : context.customColors.textHint,
                ),
              ),
            ),
            Icon(Icons.access_time_rounded,
                size: rw(18), color: context.customColors.iconSecondary),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: AppTextStyles.font12SemiBold
          .copyWith(color: context.customColors.textSecondary),
    );
  }

  InputDecoration _inputDeco(BuildContext context, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          AppTextStyles.font14Light.copyWith(color: context.customColors.textHint),
      filled: true,
      fillColor: context.customColors.background,
      contentPadding:
          EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rr(12)),
        borderSide: BorderSide(color: context.customColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rr(12)),
        borderSide: BorderSide(color: context.customColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rr(12)),
        borderSide: const BorderSide(color: AppColors.green200),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rr(12)),
        borderSide: const BorderSide(color: AppColors.red200),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rr(12)),
        borderSide: const BorderSide(color: AppColors.red200),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
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
            title,
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

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.title, required this.isEditMode});

  final String title;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: rw(64),
          height: rw(64),
          decoration: BoxDecoration(
            color: AppColors.green200.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(rr(20)),
          ),
          child: Icon(
            isEditMode ? Icons.edit_outlined : Icons.groups_outlined,
            size: rw(32),
            color: AppColors.green200,
          ),
        ),
        verticalSpacing(12),
        Text(
          title,
          style: AppTextStyles.font18SemiBold.copyWith(
            color: context.customColors.textPrimary,
          ),
        ),
        verticalSpacing(4),
        Text(
          isEditMode ? 'edit_unit'.tr() : 'add_first_unit'.tr(),
          style: AppTextStyles.font12Light.copyWith(
            color: context.customColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
