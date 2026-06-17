import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/shared/ui/widgets/credentials_share_sheet.dart';
import 'package:ground_scope/core/themes/app_colors.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/extensions/context_ext.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/admin/features/service_types/logic/cubit/service_type_form_cubit.dart';
import 'package:ground_scope/modules/admin/features/service_types/ui/widgets/service_type_form_fields.dart';

class ServiceTypeFormScreen extends StatefulWidget {
  const ServiceTypeFormScreen({super.key});

  @override
  State<ServiceTypeFormScreen> createState() => _ServiceTypeFormScreenState();
}

class _ServiceTypeFormScreenState extends State<ServiceTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _iconController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final editing = context.read<ServiceTypeFormCubit>().state.editing;
    _nameController = TextEditingController(text: editing?.name ?? '');
    _descriptionController = TextEditingController(
      text: editing?.description ?? '',
    );
    _durationController = TextEditingController(
      text: editing != null ? '${editing.defaultDurationMinutes}' : '',
    );
    _iconController = TextEditingController(text: editing?.icon ?? '');
    _isActive = editing?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<ServiceTypeFormCubit>().submit(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      durationMinutes: int.parse(_durationController.text.trim()),
      icon: _iconController.text.trim().isEmpty
          ? null
          : _iconController.text.trim(),
      isActive: _isActive,
    );
    // Navigation is handled by BlocListener
  }

  void _handleSuccess(BuildContext context, ServiceTypeFormState state) {
    if (state.credentialsError) {
      context.showErrorSnackBar('account_creation_failed_warning'.tr());
      debugPrint(
        'ServiceTypeFormScreen: Account creation failed for service type ${state.editing?.name}',
      );
      context.pop(true);
      return;
    }
    if (state.generatedCredentials != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => CredentialsShareSheet(
          credentials: state.generatedCredentials!,
          onDone: () {
            Navigator.of(context).pop();
            context.pop(true);
          },
        ),
      );
    } else {
      context.showSuccessSnackBar('service_type_saved_successfully'.tr());

      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.background,
      body: SafeArea(
        child: BlocConsumer<ServiceTypeFormCubit, ServiceTypeFormState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              (curr.status == ServiceTypeFormStatus.success ||
                  curr.status == ServiceTypeFormStatus.failure),
          listener: (context, state) {
            if (state.status == ServiceTypeFormStatus.success) {
              _handleSuccess(context, state);
            } else if (state.status == ServiceTypeFormStatus.failure &&
                state.error != null) {
              context.showErrorSnackBar(state.error!.messageKey);
              debugPrint(
                'ServiceTypeFormScreen: Error saving service type: ${state.error!.messageKey}',
              );
            }
          },
          builder: (context, state) {
            final isEditMode = state.isEditMode;
            final title = isEditMode
                ? 'edit_service_type'.tr()
                : 'add_service_type'.tr();
            final submitting = state.status == ServiceTypeFormStatus.submitting;

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
                                child: ServiceTypeFormFields(
                                  nameController: _nameController,
                                  descriptionController: _descriptionController,
                                  durationController: _durationController,
                                  iconController: _iconController,
                                  isActive: _isActive,
                                  onActiveChanged: (val) =>
                                      setState(() => _isActive = val),
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
                                      backgroundColor: AppColors.primary200,
                                      foregroundColor: AppColors.white,
                                      disabledBackgroundColor:
                                          AppColors.primary100,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          rr(16),
                                        ),
                                      ),
                                    ),
                                    child: submitting
                                        ? SizedBox(
                                            width: rw(20),
                                            height: rw(20),
                                            child:
                                                const CircularProgressIndicator(
                                                  color: AppColors.white,
                                                  strokeWidth: 2,
                                                ),
                                          )
                                        : Text(
                                            'save'.tr(),
                                            style: AppTextStyles.font16SemiBold
                                                .copyWith(
                                                  color: AppColors.white,
                                                ),
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
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(rr(20)),
          ),
          child: Icon(
            isEditMode ? Icons.edit_outlined : Icons.add_circle_outline_rounded,
            size: rw(32),
            color: AppColors.primary200,
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
          isEditMode ? 'edit_service_type'.tr() : 'add_first_service_type'.tr(),
          style: AppTextStyles.font12Light.copyWith(
            color: context.customColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
