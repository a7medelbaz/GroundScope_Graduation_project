import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../core/utils/spacing.dart';
import '../../../../../core/widgets/custom_text_button.dart';
import '../../../../../core/widgets/custom_text_form_.dart';
import '../../../../../core/shared/data/models/report_model.dart';
import '../logic/cubit/supervisor_add_report_cubit.dart';

// ─── Report target constants ──────────────────────────────────────────────────

const _kTargetAdmin = 'admin';
const _kTargetWorker = 'worker';

// ─── Screen ───────────────────────────────────────────────────────────────────

class SupervisorAddReportScreen extends StatefulWidget {
  const SupervisorAddReportScreen({super.key});

  @override
  State<SupervisorAddReportScreen> createState() =>
      _SupervisorAddReportScreenState();
}

class _SupervisorAddReportScreenState extends State<SupervisorAddReportScreen>
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
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _descController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    context.read<SupervisorAddReportCubit>().submit(
          description: _descController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return BlocListener<SupervisorAddReportCubit, SupervisorAddReportState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == SupervisorAddReportStatus.submitted) {
          HapticFeedback.mediumImpact();
          _descController.clear();
          context.showMessageSnackBar(
            'Report submitted successfully',
            type: SnackBarType.success,
          );
          context.read<SupervisorAddReportCubit>().resetForm();
          Navigator.of(context).pop();
        } else if (state.status == SupervisorAddReportStatus.failure) {
          HapticFeedback.mediumImpact();
          context.showMessageSnackBar(
            state.error?.serverMessage ?? state.error?.messageKey ?? 'Something went wrong',
            type: SnackBarType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: cc.background,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            slivers: [
              _SupervisorAddReportAppBar(),
              SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: rw(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpacing(4),
                        // ── Send To ─────────────────────────────────────────
                        const _SectionLabel(label: 'Send To'),
                        verticalSpacing(10),
                        const _ReportTargetSelector(),
                        verticalSpacing(24),
                        // ── Report Type ─────────────────────────────────────
                        const _SectionLabel(label: 'Report Type'),
                        verticalSpacing(10),
                        const _SupervisorTypeSelector(),
                        verticalSpacing(24),
                        // ── Severity ────────────────────────────────────────
                        const _SectionLabel(label: 'Severity'),
                        verticalSpacing(10),
                        const _SupervisorSeveritySelector(),
                        verticalSpacing(24),
                        // ── Description ─────────────────────────────────────
                        const _SectionLabel(label: 'Description'),
                        verticalSpacing(10),
                        CustomTextForm(
                          hintText: 'Describe the issue in detail...',
                          controller: _descController,
                          maxLines: 5,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Description is required'
                                  : null,
                        ),
                        verticalSpacing(24),
                        // ── Photo ────────────────────────────────────────────
                        const _SectionLabel(label: 'Attach Photo (optional)'),
                        verticalSpacing(10),
                        const _SupervisorImagePicker(),
                        verticalSpacing(36),
                        // ── Submit ───────────────────────────────────────────
                        BlocBuilder<SupervisorAddReportCubit,
                            SupervisorAddReportState>(
                          buildWhen: (p, c) =>
                              p.isSubmitting != c.isSubmitting,
                          builder: (context, state) => CustomTextButton(
                            text: state.isSubmitting ? 'Submitting...' : 'Submit Report',
                            onPressed: state.isSubmitting
                                ? () {}
                                : () => _handleSubmit(context),
                          ),
                        ),
                        verticalSpacing(48),
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
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _SupervisorAddReportAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary300,
              AppColors.primary200,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(rw(8), rh(8), rw(20), rh(20)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppColors.white,
                  iconSize: rf(20),
                ),
                horizontalSpacing(4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Report',
                      style: AppTextStyles.font20ExtraBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    verticalSpacing(2),
                    Text(
                      'File a report to admin or your team',
                      style: AppTextStyles.font12Light.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.all(rw(10)),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: AppColors.white,
                    size: rf(20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.font12SemiBold.copyWith(
        color: context.customColors.textHint,
        letterSpacing: 1.1,
      ),
    );
  }
}

// ─── Report target selector ───────────────────────────────────────────────────

class _ReportTargetSelector extends StatelessWidget {
  const _ReportTargetSelector();

  @override
  Widget build(BuildContext context) {
    final selected =
        context.watch<SupervisorAddReportCubit>().state.reportedTo;

    return Row(
      children: [
        Expanded(
          child: _TargetCard(
            target: _kTargetAdmin,
            selected: selected,
            icon: Icons.admin_panel_settings_rounded,
            label: 'Admin',
            subtitle: 'Escalate to\nmanagement',
            activeColor: AppColors.secondary200,
          ),
        ),
        horizontalSpacing(12),
        Expanded(
          child: _TargetCard(
            target: _kTargetWorker,
            selected: selected,
            icon: Icons.groups_rounded,
            label: 'Worker',
            subtitle: 'Notify your\nfield team',
            activeColor: AppColors.primary200,
          ),
        ),
      ],
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.target,
    required this.selected,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.activeColor,
  });

  final String target;
  final String selected;
  final IconData icon;
  final String label;
  final String subtitle;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final isActive = selected == target;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<SupervisorAddReportCubit>().selectTarget(target);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(16)),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.08)
              : cc.surface,
          borderRadius: BorderRadius.circular(rr(16)),
          border: Border.all(
            color: isActive ? activeColor : cc.border,
            width: isActive ? 1.8 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.all(rw(8)),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor.withValues(alpha: 0.15)
                        : cc.surfaceVariant,
                    borderRadius: BorderRadius.circular(rr(10)),
                  ),
                  child: Icon(
                    icon,
                    size: rf(20),
                    color: isActive ? activeColor : cc.iconSecondary,
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: isActive ? 1.0 : 0.0,
                  child: Container(
                    width: rw(18),
                    height: rw(18),
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: rf(11),
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            verticalSpacing(12),
            Text(
              label,
              style: AppTextStyles.font14SemiBold.copyWith(
                color: isActive ? activeColor : cc.textPrimary,
              ),
            ),
            verticalSpacing(3),
            Text(
              subtitle,
              style: AppTextStyles.font12Light.copyWith(
                color: cc.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Type selector ────────────────────────────────────────────────────────────

class _SupervisorTypeSelector extends StatelessWidget {
  const _SupervisorTypeSelector();

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;
    final selected =
        context.watch<SupervisorAddReportCubit>().state.type;

    return Wrap(
      spacing: rw(10),
      runSpacing: rh(10),
      children: ReportType.values.map((type) {
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<SupervisorAddReportCubit>().selectType(type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding:
                EdgeInsets.symmetric(horizontal: rw(14), vertical: rh(10)),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary200.withValues(alpha: 0.12)
                  : cc.surfaceVariant,
              borderRadius: BorderRadius.circular(rr(12)),
              border: Border.all(
                color: isSelected ? AppColors.primary200 : cc.border,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type.icon, style: TextStyle(fontSize: rf(15))),
                horizontalSpacing(7),
                Text(
                  type.label,
                  style: isSelected
                      ? AppTextStyles.font14SemiBold
                          .copyWith(color: AppColors.primary200)
                      : AppTextStyles.font12Light
                          .copyWith(color: cc.textSecondary),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Severity selector ────────────────────────────────────────────────────────

class _SupervisorSeveritySelector extends StatelessWidget {
  const _SupervisorSeveritySelector();

  static const _data = {
    ReportSeverity.low: (
      color: AppColors.green200,
      icon: Icons.arrow_downward_rounded,
    ),
    ReportSeverity.medium: (
      color: AppColors.amber200,
      icon: Icons.remove_rounded,
    ),
    ReportSeverity.high: (
      color: AppColors.red200,
      icon: Icons.arrow_upward_rounded,
    ),
    ReportSeverity.critical: (
      color: Color(0xFF7C3AED),
      icon: Icons.priority_high_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final selected =
        context.watch<SupervisorAddReportCubit>().state.severity;

    return Row(
      children: ReportSeverity.values.map((s) {
        final isSelected = s == selected;
        final d = _data[s]!;
        final isLast = s == ReportSeverity.values.last;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<SupervisorAddReportCubit>().selectSeverity(s);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isLast ? 0 : rw(8)),
              padding: EdgeInsets.symmetric(vertical: rh(12)),
              decoration: BoxDecoration(
                color: isSelected
                    ? d.color.withValues(alpha: 0.13)
                    : context.customColors.surfaceVariant,
                borderRadius: BorderRadius.circular(rr(12)),
                border: Border.all(
                  color: isSelected
                      ? d.color
                      : context.customColors.border,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    d.icon,
                    size: rf(18),
                    color: isSelected
                        ? d.color
                        : context.customColors.iconSecondary,
                  ),
                  verticalSpacing(4),
                  Text(
                    s.label,
                    style: AppTextStyles.font12SemiBold.copyWith(
                      color: isSelected
                          ? d.color
                          : context.customColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Image picker ─────────────────────────────────────────────────────────────

class _SupervisorImagePicker extends StatelessWidget {
  const _SupervisorImagePicker();

  @override
  Widget build(BuildContext context) {
    final hasImage =
        context.watch<SupervisorAddReportCubit>().state.hasImage;
    final imageFile =
        context.watch<SupervisorAddReportCubit>().state.imageFile;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: hasImage
          ? _ImagePreview(key: const ValueKey('preview'), file: imageFile!)
          : const _PickerButtons(key: ValueKey('buttons')),
    );
  }
}

class _PickerButtons extends StatelessWidget {
  const _PickerButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PickerButton(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            onTap: () {
              HapticFeedback.lightImpact();
              context
                  .read<SupervisorAddReportCubit>()
                  .pickImage(ImageSource.camera);
            },
          ),
        ),
        horizontalSpacing(12),
        Expanded(
          child: _PickerButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            onTap: () {
              HapticFeedback.lightImpact();
              context
                  .read<SupervisorAddReportCubit>()
                  .pickImage(ImageSource.gallery);
            },
          ),
        ),
      ],
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rh(18)),
        decoration: BoxDecoration(
          color: cc.surface,
          borderRadius: BorderRadius.circular(rr(14)),
          border: Border.all(
            color: cc.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: rf(26), color: AppColors.primary200),
            verticalSpacing(6),
            Text(
              label,
              style: AppTextStyles.font12SemiBold.copyWith(
                color: cc.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({super.key, required this.file});
  final File file;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(rr(14)),
      child: Stack(
        children: [
          Image.file(
            file,
            width: double.infinity,
            height: rh(200),
            fit: BoxFit.cover,
          ),
          Positioned(
            top: rh(8),
            right: rw(8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<SupervisorAddReportCubit>().removeImage();
              },
              child: Container(
                padding: EdgeInsets.all(rw(6)),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: rf(16),
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
