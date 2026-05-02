import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/themes/app_text_styles.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import '../../logic/cubit/add_report_cubit.dart';
import 'replace_options_sheet.dart';

class AddReportImagePreview extends StatelessWidget {
  const AddReportImagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddReportCubit>().state;

    return Stack(
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(rr(16)),
          child: state.imageFile == null
              ? const SizedBox.shrink()
              : Image.file(
                  state.imageFile!,
                  width: double.infinity,
                  height: rh(200),
                  fit: BoxFit.cover,
                ),
        ),

        // Top gradient overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: rh(60),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ),
            ),
          ),
        ),

        // Remove Button
        Positioned(
          top: rh(10),
          right: rw(10),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<AddReportCubit>().removeImage();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .65),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),

        // Replace Button
        Positioned(
          bottom: rh(10),
          right: rw(10),
          child: GestureDetector(
            onTap: () => _showPickerOptions(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: rw(12),
                vertical: rh(6),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(rr(20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                  horizontalSpacing(4),
                  Text(
                    'Replace',
                    style: AppTextStyles.font12SemiBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPickerOptions(BuildContext context) {
    final cubit = context.read<AddReportCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ReplaceOptionsSheet(cubit: cubit),
    );
  }
}
