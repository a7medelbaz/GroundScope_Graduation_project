import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/shared/data/models/report_model.dart';
import '../../logic/cubit/add_report_cubit.dart';

class ReportSeveritySelector extends StatelessWidget {
  const ReportSeveritySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<AddReportCubit>().state.severity;

    return Row(
      children: ReportSeverity.values.map((s) {
        final isSelected = s == selected;
        final data = _severityData[s]!;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<AddReportCubit>().selectSeverity(s);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: s == ReportSeverity.values.last ? 0 : 8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? data.color.withOpacity(0.15)
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? data.color
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    data.icon,
                    size: 18,
                    color: isSelected
                        ? data.color
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? data.color
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SeverityData {
  const _SeverityData({required this.color, required this.icon});
  final Color color;
  final IconData icon;
}

const _severityData = {
  ReportSeverity.low: _SeverityData(
    color: Color(0xFF22C55E),
    icon: Icons.arrow_downward_rounded,
  ),
  ReportSeverity.medium: _SeverityData(
    color: Color(0xFFF59E0B),
    icon: Icons.remove_rounded,
  ),
  ReportSeverity.high: _SeverityData(
    color: Color(0xFFEF4444),
    icon: Icons.arrow_upward_rounded,
  ),
  ReportSeverity.critical: _SeverityData(
    color: Color(0xFF7C3AED),
    icon: Icons.priority_high_rounded,
  ),
};
