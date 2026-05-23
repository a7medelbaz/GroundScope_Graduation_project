import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    _descriptionController =
        TextEditingController(text: editing?.description ?? '');
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

    final cubit = context.read<ServiceTypeFormCubit>();
    final success = await cubit.submit(
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

    if (!mounted) return;

    if (success) {
      context.showSuccessSnackBar('service_type_saved_successfully'.tr());
      context.pop(true);
    } else {
      final error = context.read<ServiceTypeFormCubit>().state.error;
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
        child: BlocBuilder<ServiceTypeFormCubit, ServiceTypeFormState>(
          builder: (context, state) {
            final title = state.isEditMode
                ? 'edit_service_type'.tr()
                : 'add_service_type'.tr();

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
                          ServiceTypeFormFields(
                            nameController: _nameController,
                            descriptionController: _descriptionController,
                            durationController: _durationController,
                            iconController: _iconController,
                            isActive: _isActive,
                            onActiveChanged: (val) =>
                                setState(() => _isActive = val),
                          ),
                          verticalSpacing(32),
                          SizedBox(
                            width: double.infinity,
                            height: rh(52),
                            child: ElevatedButton(
                              onPressed: state.status ==
                                      ServiceTypeFormStatus.submitting
                                  ? null
                                  : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary200,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor:
                                    AppColors.primary100,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(rr(12)),
                                ),
                              ),
                              child: state.status ==
                                      ServiceTypeFormStatus.submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
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
