// import 'package:flutter/material.dart';
// import 'package:ground_scope/core/utils/extensions/context_ext.dart';
// import '../../../../../../core/themes/app_colors.dart';
// import '../../../../../../core/themes/app_text_styles.dart';
// import '../../../../../../core/utils/spacing.dart';
// import '../../../../../../core/widgets/custom_text_button.dart';
// import '../../../../../../core/widgets/custom_text_form_.dart';
// import '../../../home/data/models/task_model.dart';

// class QuickReportBottomSheet extends StatefulWidget {
//   const QuickReportBottomSheet({super.key, required this.task});

//   final TaskModel task;

//   @override
//   State<QuickReportBottomSheet> createState() => _QuickReportBottomSheetState();
// }

// class _QuickReportBottomSheetState extends State<QuickReportBottomSheet> {
//   final TextEditingController _descriptionController = TextEditingController();

//   dynamic _selectedImage;

//   @override
//   void dispose() {
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: AnimatedPadding(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             color: context.customColors.background,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(rr(28))),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHandle(context),
//               _buildHeader(context),

//               Divider(height: 1, color: context.customColors.border),

//               /// Scrollable Body
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(rw(20)),
//                   child: _buildBody(context),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHandle(BuildContext context) {
//     return Center(
//       child: Container(
//         margin: EdgeInsets.only(top: rh(12)),
//         width: rw(40),
//         height: rh(4),
//         decoration: BoxDecoration(
//           color: context.customColors.divider,
//           borderRadius: BorderRadius.circular(rr(8)),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: rw(20), vertical: rh(16)),
//       child: Row(
//         children: [
//           _buildIconBadge(),

//           horizontalSpacing(12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Quick Report', style: AppTextStyles.font18ExtraBold),
//                 Text(
//                   widget.task.title,
//                   style: AppTextStyles.font12Light.copyWith(
//                     color: context.customColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           _buildCloseButton(context),
//         ],
//       ),
//     );
//   }

//   Widget _buildIconBadge() {
//     return Container(
//       padding: EdgeInsets.all(rw(8)),
//       decoration: BoxDecoration(
//         color: AppColors.primary300.withValues(alpha: 0.15),
//         borderRadius: BorderRadius.circular(rr(10)),
//       ),
//       child: Icon(
//         Icons.flag_outlined,
//         color: AppColors.primary300,
//         size: rw(18),
//       ),
//     );
//   }

//   Widget _buildCloseButton(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Navigator.pop(context),
//       child: Container(
//         padding: EdgeInsets.all(rw(8)),
//         decoration: BoxDecoration(
//           color: context.customColors.divider.withValues(alpha: 0.15),
//           borderRadius: BorderRadius.circular(rr(10)),
//         ),
//         child: Icon(
//           Icons.close,
//           size: rw(16),
//           color: context.customColors.textSecondary,
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildPhotoSection(context),

//         verticalSpacing(20),

//         _buildTaskNameSection(context),

//         verticalSpacing(16),

//         _buildDescriptionSection(context),

//         verticalSpacing(20),

//         _buildMetadataSection(context),

//         verticalSpacing(24),

//         _buildSubmitButton(context),

//         verticalSpacing(8),
//       ],
//     );
//   }

//   Widget _buildPhotoSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _SectionLabel(
//           label: 'Add Photo',
//           optional: true,
//           labelColor: context.customColors.textSecondary,
//         ),
//         verticalSpacing(10),
//         GestureDetector(
//           onTap: () {
//             // TODO: image picker
//           },
//           child: Container(
//             width: double.infinity,
//             height: rh(130),
//             decoration: BoxDecoration(
//               color: context.customColors.divider.withValues(alpha: 0.15),
//               borderRadius: BorderRadius.circular(rr(16)),
//               border: Border.all(
//                 color: _selectedImage != null
//                     ? AppColors.primary300
//                     : context.customColors.divider,
//                 width: 1.5,
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 'Tap to add photo',
//                 style: AppTextStyles.font14SemiBold,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTaskNameSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _SectionLabel(
//           label: 'Task Name',
//           optional: false,
//           labelColor: context.customColors.textSecondary,
//         ),
//         verticalSpacing(8),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: rw(16), vertical: rh(14)),
//           decoration: BoxDecoration(
//             color: context.customColors.divider.withValues(alpha: 0.15),
//             borderRadius: BorderRadius.circular(rr(12)),
//             border: Border.all(color: context.customColors.divider),
//           ),
//           child: Text(
//             widget.task.title,
//             style: AppTextStyles.font14Light.copyWith(
//               color: context.customColors.textSecondary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDescriptionSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _SectionLabel(
//           label: 'Short Description',
//           optional: false,
//           labelColor: context.customColors.textSecondary,
//         ),
//         verticalSpacing(8),
//         CustomTextForm(
//           hintText: 'e.g., Minor dent on cargo loader',
//           controller: _descriptionController,
//           maxLines: 3,
//         ),
//       ],
//     );
//   }

//   Widget _buildMetadataSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _SectionLabel(
//           label: 'Metadata',
//           optional: false,
//           labelColor: context.customColors.textSecondary,
//         ),
//         verticalSpacing(8),
//         Container(
//           decoration: BoxDecoration(
//             color: context.customColors.divider.withValues(alpha: 0.15),
//             borderRadius: BorderRadius.circular(rr(12)),
//             border: Border.all(color: context.customColors.divider),
//           ),
//           child: Column(
//             children: [
//               _MetadataRow(
//                 icon: Icons.location_on_outlined,
//                 label: 'Location',
//                 value: widget.task.location,
//                 labelColor: context.customColors.textSecondary,
//               ),
//               Divider(height: 1, color: context.customColors.divider),
//               _MetadataRow(
//                 icon: Icons.access_time,
//                 label: 'Timestamp',
//                 value: _formatTimestamp(DateTime.now()),
//                 labelColor: context.customColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSubmitButton(BuildContext context) {
//     return CustomTextButton(
//       text: 'Submit Report',
//       onPressed: () => Navigator.pop(context),
//       prefixIcon: const Icon(Icons.send_outlined, size: 18),
//     );
//   }

//   // =========================
//   // Helpers
//   // =========================

//   String _formatTimestamp(DateTime dt) =>
//       '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}';

//   String _pad(int n) => n.toString().padLeft(2, '0');
// }

// class _MetadataRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color labelColor;

//   const _MetadataRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.labelColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         mainAxisSize: MainAxisSize.max,
//         children: [
//           Icon(icon, size: rw(18)),
//           horizontalSpacing(12),

//           Text(
//             label,
//             style: AppTextStyles.font12Light.copyWith(color: labelColor),
//           ),
//           const Spacer(),
//           Text(value, style: AppTextStyles.font12Light),
//         ],
//       ),
//     );
//   }
// }

// class _SectionLabel extends StatelessWidget {
//   final String label;
//   final bool optional;
//   final Color labelColor;

//   const _SectionLabel({
//     required this.label,
//     required this.optional,
//     required this.labelColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(label, style: AppTextStyles.font14SemiBold),
//         if (optional)
//           Text(
//             ' (Optional)',
//             style: AppTextStyles.font12Light.copyWith(color: labelColor),
//           ),
//       ],
//     );
//   }
// }
