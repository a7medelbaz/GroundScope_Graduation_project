import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/quick_report/quick_report_header.dart';
import 'widgets/quick_report/photo_section.dart';
import 'widgets/quick_report/task_name_section.dart';
import 'widgets/quick_report/description_section.dart';
import 'widgets/quick_report/metadata_section.dart';
import 'widgets/quick_report/submit_button.dart';

/// Quick Report screen for submitting task reports
/// Allows users to add photos, task name, description, and metadata
class QuickReportScreen extends StatefulWidget {
  final String? taskTitle;
  final String? taskLocation;

  const QuickReportScreen({
    super.key,
    this.taskTitle,
    this.taskLocation,
  });

  @override
  State<QuickReportScreen> createState() => _QuickReportScreenState();
}

class _QuickReportScreenState extends State<QuickReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // TODO: Implement image picker when package is added
  // File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Auto-fill task name if provided
    if (widget.taskTitle != null) {
      _taskNameController.text = widget.taskTitle!;
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Generate current timestamp in format: YYYY-MM-DD HH:MM
  String _getCurrentTimestamp() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// Extract location from task location string (e.g., "A321, Stand12" -> "Gate A12")
  String _extractLocation() {
    if (widget.taskLocation == null || widget.taskLocation!.isEmpty) {
      return 'Gate A12';
    }
    
    // Extract gate/stand information from task location
    // For now, return a default value or parse the location string
    // Example: "A321, Stand12" -> "Gate A12"
    return 'Gate A12'; // Default value, can be enhanced to parse actual location
  }

  /// Handle photo picker functionality
  Future<void> _pickImage() async {
    // TODO: Implement image picker when package is added
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(
    //   source: ImageSource.camera,
    //   maxWidth: 1920,
    //   imageQuality: 85,
    // );
    // if (image != null) {
    //   setState(() {
    //     _selectedImage = File(image.path);
    //   });
    // }

    // Temporary: Show a snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera functionality requires image_picker package'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle form submission
  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement report submission logic
      // For now, just navigate back with report data
      Navigator.of(context).pop({
        'taskName': _taskNameController.text,
        'description': _descriptionController.text,
        'location': _extractLocation(),
        'timestamp': _getCurrentTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922).withOpacity(0.8),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            const QuickReportHeader(),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      // Add Photo Section
                      PhotoSection(onTap: _pickImage),
                      SizedBox(height: 24.h),
                      // Task Name Section
                      TaskNameSection(controller: _taskNameController),
                      SizedBox(height: 24.h),
                      // Short Description Section
                      DescriptionSection(controller: _descriptionController),
                      SizedBox(height: 24.h),
                      // Metadata Section
                      MetadataSection(
                        location: _extractLocation(),
                        timestamp: _getCurrentTimestamp(),
                        workerId: 'W123456',
                      ),
                      SizedBox(height: 24.h),
                      // Submit Button
                      SubmitButton(onPressed: _submitReport),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
