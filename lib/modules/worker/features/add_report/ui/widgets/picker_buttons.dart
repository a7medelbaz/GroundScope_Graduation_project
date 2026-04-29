import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/core/utils/spacing.dart';
import 'package:ground_scope/modules/worker/features/add_report/logic/cubit/add_report_cubit.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/widgets/picker_button.dart';
import 'package:image_picker/image_picker.dart';

class PickerButtons extends StatelessWidget {
  const PickerButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PickerButton(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<AddReportCubit>().pickImage(ImageSource.camera);
            },
          ),
        ),
        horizontalSpacing(12),
        Expanded(
          child: PickerButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<AddReportCubit>().pickImage(ImageSource.gallery);
            },
          ),
        ),
      ],
    );
  }
}
