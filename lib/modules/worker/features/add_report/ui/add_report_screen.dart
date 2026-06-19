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
                          tasks: const [],
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
                        SectionLabel(label: 'worker_add_report.description'.tr()),
                        verticalSpacing(10),
                        CustomTextForm(
                          hintText: 'worker_add_report.description_hint'.tr(),
                          controller: _descController,
                          maxLines: 5,
                        ),
                        verticalSpacing(24),
                        SectionLabel(label: 'worker_add_report.attach_photo'.tr()),
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

// enum SnackBarType { error, success }

// void _showMessageSnackBar(
//   BuildContext context,
//   String message, {
//   required SnackBarType type,
// }) {
//   final overlay = Overlay.of(context);
//   late OverlayEntry entry;

//   entry = OverlayEntry(
//     builder: (_) => MessageSnackBar(
//       message: message,
//       type: type,
//       onDismiss: () => entry.remove(),
//     ),
//   );

//   overlay.insert(entry);
// }

// class MessageSnackBar extends StatefulWidget {
//   const MessageSnackBar({
//     super.key,
//     required this.message,
//     required this.type,
//     required this.onDismiss,
//   });

//   final String message;
//   final SnackBarType type;
//   final VoidCallback onDismiss;

//   @override
//   State<MessageSnackBar> createState() => _MessageSnackBarState();
// }

// class _MessageSnackBarState extends State<MessageSnackBar>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _fade;
//   late final Animation<Offset> _slide;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 350),
//     );
//     _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
//     _slide = Tween<Offset>(
//       begin: const Offset(0, 0.15),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

//     _controller.forward();

//     final seconds = widget.type == SnackBarType.error ? 4 : 3;
//     Future.delayed(Duration(seconds: seconds), _dismiss);
//   }

//   void _dismiss() async {
//     if (!mounted) return;
//     await _controller.reverse();
//     widget.onDismiss();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isError = widget.type == SnackBarType.error;

//     final Color bgColor = isError
//         ? context.colorScheme.error
//         : const Color(0xFF22C55E);

//     final IconData icon = isError
//         ? Icons.error_rounded
//         : Icons.check_circle_rounded;

//     return Positioned.fill(
//       child: IgnorePointer(
//         ignoring: false,
//         child: Material(
//           color: Colors.transparent,
//           child: Center(
//             child: FadeTransition(
//               opacity: _fade,
//               child: SlideTransition(
//                 position: _slide,
//                 child: GestureDetector(
//                   onTap: _dismiss,
//                   child: Container(
//                     margin: EdgeInsets.symmetric(horizontal: 32.w),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 20.w,
//                       vertical: 16.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: bgColor,
//                       borderRadius: BorderRadius.circular(20.r),
//                       boxShadow: [
//                         BoxShadow(
//                           color: bgColor.withValues(alpha: .4),
//                           blurRadius: 24,
//                           offset: const Offset(0, 8),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(icon, color: Colors.white, size: 24.r),
//                         SizedBox(width: 12.w),
//                         Flexible(
//                           child: Text(
//                             widget.message,
//                             style: AppTextStyles.font14SemiBold.copyWith(
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
