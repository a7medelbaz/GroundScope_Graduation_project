import 'package:flutter/material.dart';
import '../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../core/widgets/info_card.dart';
import '../../../../../../core/widgets/info_row_data.dart';

class TaskFlightDetailsCard extends StatelessWidget {
  const TaskFlightDetailsCard({super.key, required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    // Mock flight data — replace with joined data from Supabase
    return InfoCard(
      rows: [
        InfoRowData(
          icon: Icons.flight_rounded,
          label: 'Flight Number',
          value: task.flightNumber ?? '—',
          highlight: true,
        ),
        InfoRowData(
          icon: Icons.airplanemode_active_rounded,
          label: 'Aircraft Type',
          value:
              task.serviceTypeIcon ??
              'Boeing 737', // replace with flight.aircraft_type
        ),
        const InfoRowData(
          icon: Icons.confirmation_number_outlined,
          label: 'Registration',
          value: 'A6-EBB', // replace with flight.aircraft_registration
        ),
        const InfoRowData(
          icon: Icons.flight_land_rounded,
          label: 'Origin',
          value: 'DXB', // replace with flight.origin
        ),
        const InfoRowData(
          icon: Icons.flight_takeoff_rounded,
          label: 'Destination',
          value: 'CAI', // replace with flight.destination
        ),
        const InfoRowData(
          icon: Icons.people_rounded,
          label: 'Passengers',
          value: '280 pax', // replace with flight.pax_count
        ),
        const InfoRowData(
          icon: Icons.schedule_rounded,
          label: 'Scheduled Arrival',
          value: '07:15', // replace with flight.scheduled_arrival
        ),
        const InfoRowData(
          icon: Icons.flight_land_rounded,
          label: 'Actual Arrival',
          value: '07:22', // replace with flight.actual_arrival
        ),
      ],
    );
  }
}
