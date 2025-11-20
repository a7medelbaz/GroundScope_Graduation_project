import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ground_scope/core/auth/ui/widgets/custom_text_form_.dart';
import '../models/report_model.dart';

class QuickReportModal extends StatefulWidget {
  final Function(Report newReport) onReportSubmitted;

  const QuickReportModal({super.key, required this.onReportSubmitted});

  @override
  State<QuickReportModal> createState() => _QuickReportModalState();
}

class _QuickReportModalState extends State<QuickReportModal> {
  final TextEditingController _taskNameController = TextEditingController(
    text: 'Auto fill',
  );
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Get current location (simplified - replace with actual location service)
  String get _currentLocation => 'Stand: C34';

  // Get current timestamp (simplified - replace with actual timestamp)
  String get _currentTimestamp {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    return '${now.day}/${now.month}/${now.year} $hour:$minute $amPm';
  }

  void _submitReport() {
    if (_taskNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newReport = Report(
      taskName: _taskNameController.text.trim(),
      description: _descriptionController.text.trim(),
      imagePath: null, // No image since camera is disabled
      timestamp: _currentTimestamp,
      location: _currentLocation,
    );

    widget.onReportSubmitted(newReport);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF101922),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with title and close button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Report',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Section with dashed border
                  _buildPhotoSection(),
                  SizedBox(height: 24.h),

                  // Task Name Field
                  Text(
                    'Task name',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    controller: _taskNameController,
                    hintText: 'Auto fill',
                    innerBackgroundColor: const Color(0xFF1A2633),
                    borderRadius: 12,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF2E8AF0),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    inputTextStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF8B95A5),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Short Description Field
                  Text(
                    'Short description',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    controller: _descriptionController,
                    hintText: 'e.g., Minor dent on cargo loader',
                    innerBackgroundColor: const Color(0xFF1A2633),
                    borderRadius: 12,
                    maxLines: 3,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF2E8AF0),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    inputTextStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF8B95A5),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Metadata Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2633),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetadataRow(
                          label: 'Location',
                          value: _currentLocation,
                        ),
                        SizedBox(height: 12.h),
                        _MetadataRow(
                          label: 'Timestamp',
                          value: _currentTimestamp,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),

          // Submit Button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8AF0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                ),
                child: Text(
                  'Submit Report',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: () {
        // Camera launch disabled. Icon remains.
        print('Camera launch disabled. Icon remains.');
      },
      child: Container(
        height: 160.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF8B95A5),
                  size: 32,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap to add photo',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF8B95A5),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Up to 5MB',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF586474),
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

// Metadata Row Widget
class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF8B95A5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// Dashed Border Painter
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B95A5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)));

    const double dashWidth = 8;
    const double dashGap = 6;

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
