import 'package:flutter/material.dart';

import '../../../../../../core/shared/data/models/task_model.dart';
import '../../../../../../core/widgets/info_card.dart';
import '../../../../../../core/widgets/info_row_data.dart';

class TaskStandDetailsCard extends StatelessWidget {
  const TaskStandDetailsCard({super.key, required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    // Mock stand data — replace with joined data from Supabase
    return InfoCard(
      rows: [
        InfoRowData(
          icon: Icons.location_on_rounded,
          label: 'Stand Code',
          value: task.standCode ?? '—',
          highlight: true,
        ),
        const InfoRowData(
          icon: Icons.business_rounded,
          label: 'Terminal',
          value: 'Terminal 2', // replace with stand.terminal
        ),
        const InfoRowData(
          icon: Icons.videocam_rounded,
          label: 'Camera',
          value: 'CAM-B1 · Active', // replace with camera data
        ),
        const InfoRowData(
          icon: Icons.airplanemode_active_rounded,
          label: 'Compatible Aircraft',
          value: 'B777, A380', // replace with stand.compatible_aircraft
        ),
      ],
    );
  }
}
