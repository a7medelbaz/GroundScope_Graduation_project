import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/di/dependency_injection.dart';
import 'package:ground_scope/core/shared/data/models/unit_member_model.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/units/logic/cubit/unit_member_cubit.dart';

Future<bool> showUnitMemberFormSheet({
  required BuildContext context,
  required String unitId,
  UnitMemberModel? editing,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) {
        final cubit = getIt<UnitMemberCubit>();
        if (editing != null) cubit.initForEdit(editing);
        return cubit;
      },
      child: _UnitMemberFormSheet(unitId: unitId),
    ),
  );
  return result ?? false;
}

class _UnitMemberFormSheet extends StatefulWidget {
  const _UnitMemberFormSheet({required this.unitId});

  final String unitId;

  @override
  State<_UnitMemberFormSheet> createState() => _UnitMemberFormSheetState();
}

class _UnitMemberFormSheetState extends State<_UnitMemberFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _positionController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;

  @override
  void initState() {
    super.initState();
    final editing = context.read<UnitMemberCubit>().state.editing;
    _nameController = TextEditingController(text: editing?.fullName ?? '');
    _positionController = TextEditingController(text: editing?.position ?? '');
    _phoneController = TextEditingController(text: editing?.phone ?? '');
    _nationalIdController =
        TextEditingController(text: editing?.nationalId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<UnitMemberCubit>();
    final success = await cubit.submit(
      unitId: widget.unitId,
      fullName: _nameController.text.trim(),
      position: _positionController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      nationalId: _nationalIdController.text.trim().isEmpty
          ? null
          : _nationalIdController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      context.showSuccessSnackBar('member_saved_success'.tr());
      Navigator.of(context).pop(true);
    } else {
      final error = cubit.state.error;
      if (error != null) context.showErrorSnackBar(error.messageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnitMemberCubit, UnitMemberState>(
      builder: (context, state) {
        final isEdit = state.isEditMode;
        final submitting = state.status == UnitMemberFormStatus.submitting;

        return Container(
          decoration: BoxDecoration(
            color: context.customColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(rr(24))),
          ),
          padding: EdgeInsets.only(
            left: rw(20),
            right: rw(20),
            top: rh(12),
            bottom: MediaQuery.of(context).viewInsets.bottom + rh(24),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: rw(40),
                    height: rh(4),
                    decoration: BoxDecoration(
                      color: context.customColors.border,
                      borderRadius: BorderRadius.circular(rr(4)),
                    ),
                  ),
                ),
                verticalSpacing(16),
                Text(
                  isEdit ? 'edit_member'.tr() : 'add_member'.tr(),
                  style: AppTextStyles.font18SemiBold.copyWith(
                    color: context.customColors.textPrimary,
                  ),
                ),
                verticalSpacing(20),
                _buildField(
                  context,
                  label: 'member_full_name'.tr(),
                  controller: _nameController,
                  required: true,
                ),
                verticalSpacing(14),
                _buildField(
                  context,
                  label: 'member_position'.tr(),
                  controller: _positionController,
                  required: true,
                ),
                verticalSpacing(14),
                _buildField(
                  context,
                  label: 'member_phone'.tr(),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                verticalSpacing(14),
                _buildField(
                  context,
                  label: 'member_national_id'.tr(),
                  controller: _nationalIdController,
                  keyboardType: TextInputType.number,
                ),
                verticalSpacing(24),
                SizedBox(
                  width: double.infinity,
                  height: rh(52),
                  child: ElevatedButton(
                    onPressed: submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green200,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor:
                          AppColors.green200.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rr(14)),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.font12SemiBold.copyWith(
            color: context.customColors.textSecondary,
          ),
        ),
        verticalSpacing(6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.font14Light.copyWith(
            color: context.customColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.customColors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: rw(16),
              vertical: rh(12),
            ),
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
          ),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty)
                  ? 'auth.validation.required'.tr()
                  : null
              : null,
        ),
      ],
    );
  }
}
