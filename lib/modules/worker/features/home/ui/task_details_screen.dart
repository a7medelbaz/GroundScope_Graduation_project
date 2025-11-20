import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quick_report_modal.dart';
import '../models/report_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final List<ChecklistItem> _checklistItems = [
    ChecklistItem(label: 'Check aircraft position', checked: false),
    ChecklistItem(label: 'Inspect ground equipment', checked: false),
    ChecklistItem(label: 'Verify safety protocols', checked: false),
    ChecklistItem(label: 'Confirm stand assignment', checked: true),
  ];

  // Timer state
  int _secondsElapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer when the screen loads
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    // CRITICAL: Cancel the timer to prevent memory leaks
    _timer?.cancel();
    super.dispose();
  }

  // Calculate hours, minutes, and seconds from total seconds elapsed
  int get _hours => _secondsElapsed ~/ 3600;
  int get _minutes => (_secondsElapsed % 3600) ~/ 60;
  int get _seconds => _secondsElapsed % 60;

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flight Info Card
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
                    Text(
                      'Flight BA2490 - A380 Push back',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const _DetailRow(icon: Icons.tag, label: 'Stand: C34'),
                    SizedBox(height: 10.h),
                    const _DetailRow(
                      icon: Icons.schedule,
                      label: 'ETA: 13:00 - 13:15',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Task Timer Section
              Text(
                'Task Timer',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TimerBox(
                    value: _hours.toString().padLeft(2, '0'),
                    label: 'Hours',
                  ),
                  _TimerBox(
                    value: _minutes.toString().padLeft(2, '0'),
                    label: 'Minutes',
                  ),
                  _TimerBox(
                    value: _seconds.toString().padLeft(2, '0'),
                    label: 'Seconds',
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Timer auto-started...',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF8B95A5),
                  fontStyle: FontStyle.italic,
                ),
              ),

              SizedBox(height: 32.h),

              // Pre-Task Checklist Section
              Text(
                'Pre-Task Checklist',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              ..._checklistItems.map(
                (item) => _ChecklistItemWidget(
                  item: item,
                  onChanged: (value) {
                    setState(() {
                      item.checked = value ?? false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => QuickReportModal(
              onReportSubmitted: (Report newReport) {
                // Handle the submitted report
                // For now, navigate back and pass the report
                Navigator.of(context).pop(); // Close the modal
                Navigator.of(context).pop(newReport); // Return to previous screen with report
              },
            ),
          );
        },
        backgroundColor: const Color(0xFF2E8AF0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Quick Report',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ChecklistItem {
  String label;
  bool checked;

  ChecklistItem({required this.label, required this.checked});
}

// Timer Box Widget
class _TimerBox extends StatelessWidget {
  final String value;
  final String label;

  const _TimerBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2633),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E8AF0),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF8B95A5),
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Row Widget
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8B95A5), size: 18),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF8B95A5),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// Checklist Item Widget
class _ChecklistItemWidget extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool?> onChanged;

  const _ChecklistItemWidget({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(!item.checked),
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.checked
                    ? const Color(0xFF1A2633)
                    : Colors.transparent,
                border: Border.all(
                  color: item.checked
                      ? const Color(0xFF1A2633)
                      : const Color(0xFF8B95A5),
                  width: 2,
                ),
              ),
              child: item.checked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: item.checked ? Colors.white70 : Colors.white,
                decoration: item.checked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
