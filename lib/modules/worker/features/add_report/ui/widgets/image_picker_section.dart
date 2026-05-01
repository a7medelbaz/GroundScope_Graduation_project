import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/widgets/add_report_image_preview.dart';
import 'package:ground_scope/modules/worker/features/add_report/ui/widgets/picker_buttons.dart';

import '../../logic/cubit/add_report_cubit.dart';

class ImagePickerSection extends StatelessWidget {
  const ImagePickerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddReportCubit>().state;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: state.imageFile != null
          ? const AddReportImagePreview(key: ValueKey('preview'))
          : const PickerButtons(key: ValueKey('buttons')),
      // child: state.hasImage
      //     // ? const AddReportImagePreview(key: ValueKey('preview'))
      //     ? const AddReportImagePreview(key: ValueKey('preview'))
      //     : const PickerButtons(key: ValueKey('buttons')),
    );
  }
}
