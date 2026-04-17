import 'package:flutter/material.dart';

import '../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../core/widgets/info_card.dart';
import '../../../../../../core/widgets/info_row_data.dart';

class TaskFlightDetailsCard extends StatelessWidget {
  const TaskFlightDetailsCard({super.key, required this.task});
  final TaskModel task;

  // Helper to format DateTime to 24h time string
  String _formatTime(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Access the nested flight object
    final flight = task.flight;

    return InfoCard(
      rows: [
        InfoRowData(
          icon: Icons.flight_rounded,
          label: 'Flight Number',
          value: flight?.flightNumber ?? '—',
          highlight: true,
        ),
        InfoRowData(
          icon: Icons.airplanemode_active_rounded,
          label: 'Aircraft Type',
          value: flight?.aircraftType ?? '—',
        ),
        InfoRowData(
          icon: Icons.confirmation_number_outlined,
          label: 'Registration',
          value: flight?.aircraftRegistration ?? '—',
        ),
        InfoRowData(
          icon: Icons.flight_land_rounded,
          label: 'Origin',
          value: flight?.origin ?? '—',
        ),
        InfoRowData(
          icon: Icons.flight_takeoff_rounded,
          label: 'Destination',
          value: flight?.destination ?? '—',
        ),
        InfoRowData(
          icon: Icons.people_rounded,
          label: 'Passengers',
          value: flight?.paxCount != null ? '${flight!.paxCount} pax' : '—',
        ),
        InfoRowData(
          icon: Icons.schedule_rounded,
          label: 'Scheduled Arrival',
          value: _formatTime(flight?.scheduledArrival),
        ),
        InfoRowData(
          icon: Icons.flight_land_rounded,
          label: 'Actual Arrival',
          value: _formatTime(flight?.actualArrival),
        ),
        // Adding Status for better context
        InfoRowData(
          icon: Icons.info_outline_rounded,
          label: 'Flight Status',
          value: flight?.status.label ?? '—',
        ),
      ],
    );
  }
}
