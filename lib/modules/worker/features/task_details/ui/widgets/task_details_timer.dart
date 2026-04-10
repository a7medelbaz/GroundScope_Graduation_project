import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../core/themes/app_colors.dart';
import '../../../../../../core/themes/app_text_styles.dart';
import '../../../../../../core/utils/spacing.dart';
import '../../../home/data/models/task_model.dart';

class TaskDetailsTimer extends StatefulWidget {
  const TaskDetailsTimer({super.key, required this.task});
  final TaskModel task;

  @override
  State<TaskDetailsTimer> createState() => _TaskDetailsTimerState();
}

class _TaskDetailsTimerState extends State<TaskDetailsTimer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() {
    final parts = widget.task.timeRange.split(' - ');
    if (parts.length != 2) return;

    final endParts = parts[1].split(':');
    if (endParts.length != 2) return;

    final now = DateTime.now();
    final endTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    _remaining = endTime.difference(now);
    if (_remaining.isNegative) _remaining = Duration.zero;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 0) {
        _timer?.cancel();
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hours = _pad(_remaining.inHours);
    final minutes = _pad(_remaining.inMinutes.remainder(60));
    final seconds = _pad(_remaining.inSeconds.remainder(60));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Time Remaining', style: AppTextStyles.font16ExtraBold),
        verticalSpacing(12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: rh(12)),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimerUnit(value: hours, label: 'Hours'),
              _Colon(),
              _TimerUnit(value: minutes, label: 'Mins'),
              _Colon(),
              _TimerUnit(value: seconds, label: 'Secs'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: rw(6), right: rw(6), bottom: rh(20)),
      child: Text(
        ':',
        style: AppTextStyles.font18ExtraBold.copyWith(fontSize: rf(24)),
      ),
    );
  }
}

class _TimerUnit extends StatelessWidget {
  const _TimerUnit({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(final BuildContext context) {
    final digits = value.trim().split('');
    return Column(
      children: [
        Row(children: digits.map((digit) => _DigitBox(digit: digit)).toList()),
        verticalSpacing(6),
        Text(label, style: AppTextStyles.font12Light.copyWith()),
      ],
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({required this.digit});
  final String digit;

  @override
  Widget build(final BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rw(4)),
      width: rw(42),
      height: rh(62),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rr(10)),
        border: Border.all(color: AppColors.green200.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: AppTextStyles.font18ExtraBold.copyWith(fontSize: rf(36)),
      ),
    );
  }
}
