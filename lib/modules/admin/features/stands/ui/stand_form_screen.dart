import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/stands/logic/cubit/stand_form_cubit.dart';

class StandFormScreen extends StatefulWidget {
  const StandFormScreen({super.key});

  @override
  State<StandFormScreen> createState() => _StandFormScreenState();
}

class _StandFormScreenState extends State<StandFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _terminalController;
  late final TextEditingController _aircraftController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final editing = context.read<StandFormCubit>().state.editing;
    _codeController = TextEditingController(text: editing?.code ?? '');
    _terminalController = TextEditingController(text: editing?.terminal ?? '');
    _aircraftController = TextEditingController(
      text: editing != null ? editing.compatibleAircraft.join(', ') : '',
    );
    _isActive = editing?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _terminalController.dispose();
    _aircraftController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final aircraft = _aircraftController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final cubit = context.read<StandFormCubit>();
    final success = await cubit.submit(
      code: _codeController.text.trim().toUpperCase(),
      terminal: _terminalController.text.trim(),
      compatibleAircraft: aircraft,
      isActive: _isActive,
    );

    if (!mounted) return;

    if (success) {
      context.showSuccessSnackBar('stand_saved_successfully'.tr());
      context.pop(true);
    } else {
      final error = context.read<StandFormCubit>().state.error;
      if (error != null) {
        context.showErrorSnackBar(error.messageKey);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      body: SafeArea(
        child: BlocBuilder<StandFormCubit, StandFormState>(
          builder: (context, state) {
            final isEditMode = state.isEditMode;
            final title =
                isEditMode ? 'edit_stand'.tr() : 'add_stand'.tr();
            final submitting = state.status == StandFormStatus.submitting;

            return Column(
              children: [
                _buildAppBar(context, title),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(20),
                      vertical: rh(16),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _FormHeader(title: title, isEditMode: isEditMode)
                              .animate(delay: 0.ms)
                              .fadeIn(duration: 300.ms)
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 300.ms,
                                curve: Curves.easeOut,
                              ),
                          verticalSpacing(24),
                          Container(
                            padding: EdgeInsets.all(rw(20)),
                            decoration: BoxDecoration(
                              color: context.customColors.surface,
                              borderRadius: BorderRadius.circular(rr(16)),
                              border: Border.all(
                                color: context.customColors.border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'stand_code'.tr()),
                                verticalSpacing(8),
                                TextFormField(
                                  controller: _codeController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: _inputDecoration(
                                    context,
                                    hint: 'A1',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'stand_code'.tr();
                                    }
                                    if (v.trim().length > 10) {
                                      return 'stand_code'.tr();
                                    }
                                    return null;
                                  },
                                ),
                                verticalSpacing(16),
                                _buildLabel(context, 'stand_terminal'.tr()),
                                verticalSpacing(8),
                                TextFormField(
                                  controller: _terminalController,
                                  decoration: _inputDecoration(
                                    context,
                                    hint: 'Terminal 1',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'stand_terminal'.tr();
                                    }
                                    return null;
                                  },
                                ),
                                verticalSpacing(16),
                                _buildLabel(
                                    context, 'stand_compatible_aircraft'.tr()),
                                verticalSpacing(8),
                                TextFormField(
                                  controller: _aircraftController,
                                  decoration: _inputDecoration(
                                    context,
                                    hint: 'stand_aircraft_hint'.tr(),
                                  ),
                                ),
                                verticalSpacing(4),
                                Text(
                                  'stand_aircraft_hint'.tr(),
                                  style: AppTextStyles.font12Light.copyWith(
                                    color: context.customColors.textSecondary,
                                  ),
                                ),
                                verticalSpacing(16),
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  value: _isActive,
                                  onChanged: (val) =>
                                      setState(() => _isActive = val),
                                  activeThumbColor: AppColors.blue200,
                                  title: Text(
                                    'stand_active'.tr(),
                                    style: AppTextStyles.font14SemiBold
                                        .copyWith(
                                      color: context.customColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate(delay: 80.ms)
                              .fadeIn(duration: 300.ms)
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 300.ms,
                                curve: Curves.easeOut,
                              ),
                          verticalSpacing(28),
                          Opacity(
                            opacity: submitting ? 0.6 : 1.0,
                            child: SizedBox(
                              width: double.infinity,
                              height: rh(56),
                              child: ElevatedButton(
                                onPressed: submitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue200,
                                  foregroundColor: AppColors.white,
                                  disabledBackgroundColor:
                                      AppColors.blue200.withValues(alpha: 0.5),
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
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 300.ms,
                                curve: Curves.easeOut,
                              ),
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

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: AppTextStyles.font12SemiBold.copyWith(
        color: context.customColors.textSecondary,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.customColors.textHint),
      filled: true,
      fillColor: context.customColors.background,
      contentPadding: EdgeInsets.symmetric(
        horizontal: rw(16),
        vertical: rh(14),
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
        borderSide: const BorderSide(color: AppColors.blue200),
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
            color: AppColors.blue200.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(rr(20)),
          ),
          child: Icon(
            isEditMode
                ? Icons.edit_outlined
                : Icons.local_parking_outlined,
            size: rw(32),
            color: AppColors.blue200,
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
          isEditMode ? 'edit_stand'.tr() : 'add_first_stand'.tr(),
          style: AppTextStyles.font12Light.copyWith(
            color: context.customColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
