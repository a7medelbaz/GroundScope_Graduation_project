import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ground_scope/core/utils/navigation_transitions.dart';
import 'quick_report_screen.dart';
import 'widgets/task_details/task_details_header.dart';
import 'widgets/task_details/timer_display.dart';
import 'widgets/task_details/checklist_section.dart';
import 'widgets/task_details/attachments_section.dart';
import '../data/models/checklist_item.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskTitle;
  final String taskStatus;
  final String timeRange;
  final String aircraftInfo;
  final int? progress;

  const TaskDetailsScreen({
    super.key,
    required this.taskTitle,
    required this.taskStatus,
    required this.timeRange,
    required this.aircraftInfo,
    this.progress,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final List<ChecklistItem> _checklistItems = [
    ChecklistItem(label: 'Inspect pushback tug and tow bar', checked: true),
    ChecklistItem(label: 'Confirm chocks ren', checked: true),
    ChecklistItem(label: 'Visual check of aircraft doors & panels', checked: false),
  ];

  // Fixed timer values (no auto-timer)
  static const int _hours = 0;
  static const int _minutes = 2;
  static const int _seconds = 15;

  @override
  Widget build(BuildContext context) {
    // Fixed values to match screenshot exactly
    final flightInfo = 'Flight BA2490 - A380';
    final taskTitleText = widget.taskTitle; // "Push back"
    final stand = 'C34';
    final eta = '13:00 - 13:15';

    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Task Details',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flight Info Card
              TaskDetailsHeader(
                flightInfo: flightInfo,
                taskTitle: taskTitleText,
                stand: stand,
                eta: eta,
              ),
              SizedBox(height: 24.h),
              // Task Timer Section
              TimerDisplay(
                hours: _hours,
                minutes: _minutes,
                seconds: _seconds,
              ),
              SizedBox(height: 32.h),
              // Pre-Task Checklist Section
              ChecklistSection(
                checklistItems: _checklistItems,
                onItemChanged: (index) {
                  setState(() {
                    _checklistItems[index].checked = !_checklistItems[index].checked;
                  });
                },
              ),
              SizedBox(height: 32.h),
              // Attachments Section
              AttachmentsSection(
                onQuickReportPressed: () async {
                  final result = await Navigator.push(
                    context,
                    SlideUpRoute(
                      QuickReportScreen(
                        taskTitle: widget.taskTitle,
                        taskLocation: widget.aircraftInfo,
                      ),
                    ),
                  );
                  // Handle result if needed
                  if (result != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report submitted successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
