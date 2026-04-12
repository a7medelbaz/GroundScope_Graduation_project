import 'package:flutter/material.dart';
import '../../../../../../core/widgets/custom_text_form_.dart';

import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/extensions/context_ext.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../../../../../core/widgets/custom_text_button.dart';

class PauseReasonBottomSheet extends StatefulWidget {
  const PauseReasonBottomSheet({super.key});
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) =>
          const PopScope(canPop: false, child: PauseReasonBottomSheet()),
    );
  }

  @override
  State<PauseReasonBottomSheet> createState() => _PauseReasonBottomSheetState();
}

class _PauseReasonBottomSheetState extends State<PauseReasonBottomSheet> {
  final _controller = TextEditingController();
  String? _selectedQuick;

  static const _quickReasons = [
    'Waiting for equipment',
    'Safety check required',
    'Awaiting clearance',
    'Break / rest',
    'Weather condition',
    'Other',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _controller.text.trim().isNotEmpty
        ? _controller.text.trim()
        : _selectedQuick;

    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final cc = context.customColors;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cc.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(rr(24)),
            topRight: Radius.circular(rr(24)),
          ),
        ),
        padding: EdgeInsets.fromLTRB(rw(20), rh(12), rw(20), rh(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Drag handle
            Center(
              child: Container(
                width: rw(40),
                height: rh(4),
                decoration: BoxDecoration(
                  color: cc.divider,
                  borderRadius: BorderRadius.circular(rr(2)),
                ),
              ),
            ),
            verticalSpacing(20),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(rw(8)),
                  decoration: BoxDecoration(
                    color: AppColors.amber200.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(rr(10)),
                  ),
                  child: const Icon(
                    Icons.pause_circle_outline_rounded,
                    color: AppColors.amber200,
                    size: 20,
                  ),
                ),
                horizontalSpacing(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pause Task',
                      style: AppTextStyles.font18ExtraBold.copyWith(
                        color: cc.textPrimary,
                      ),
                    ),
                    Text(
                      'Select or enter a reason',
                      style: AppTextStyles.font12Light.copyWith(
                        color: cc.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            verticalSpacing(20),
            Wrap(
              spacing: rw(8),
              runSpacing: rh(8),
              children: _quickReasons.map((reason) {
                final selected = _selectedQuick == reason;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedQuick = selected ? null : reason;
                      if (!selected) _controller.clear();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(12),
                      vertical: rh(7),
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.amber200.withValues(alpha: 0.12)
                          : cc.surface,
                      borderRadius: BorderRadius.circular(rr(20)),
                      border: Border.all(
                        color: selected ? AppColors.amber200 : cc.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      reason,
                      style: AppTextStyles.font12SemiBold.copyWith(
                        color: selected ? AppColors.amber200 : cc.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            verticalSpacing(16),
            CustomTextForm(
              contentPadding: EdgeInsets.symmetric(
                horizontal: rw(14),
                vertical: rh(12),
              ),
              hintStyle: AppTextStyles.font12Light.copyWith(color: cc.textHint),
              controller: _controller,
              hintText: 'Or type a custom reason…',
              onChanged: (_) {
                if (_selectedQuick != null) {
                  setState(() => _selectedQuick = null);
                }
              },
            ),
            verticalSpacing(24),
            Row(
              children: [
                Expanded(
                  child: CustomTextButton.outlined(
                    size: CustomButtonSize.small,
                    textStyle: AppTextStyles.font16SemiBold,
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ),

                horizontalSpacing(12),

                Expanded(
                  child: CustomTextButton(
                    size: CustomButtonSize.small,
                    textStyle: AppTextStyles.font16SemiBold,
                    text: 'Pause Task',
                    onPressed: _submit,
                    backgroundColor: AppColors.amber200,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
