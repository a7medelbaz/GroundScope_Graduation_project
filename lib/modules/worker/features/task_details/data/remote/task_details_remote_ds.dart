import '../../../../../../core/error/types/error_handler.dart';
import '../../../../../../core/networking/supabase_service.dart';
import '../../../../../../core/shared/data/models/task_model.dart';

class TaskDetailsRemoteDs {
  const TaskDetailsRemoteDs({required this.supabaseService});

  final SupabaseService supabaseService;

  Future<void> updateChecklistItem({
    required String itemId,
    required bool isChecked,
    required String userId,
  }) async {
    try {
      await supabaseService.client
          .from('task_checklists')
          .update({
            'is_checked': isChecked,
            'checked_at': isChecked ? DateTime.now().toIso8601String() : null,
            'checked_by': isChecked ? userId : null,
          })
          .eq('id', itemId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> pauseTask({
    required String taskId,
    required String reason,
    required String userId,
  }) async {
    try {
      final taskData = await supabaseService.client
          .from('tasks')
          .select('actual_start')
          .eq('id', taskId)
          .single();

      final updateMap = <String, dynamic>{'status': 'paused'};
      if (taskData['actual_start'] == null) {
        updateMap['actual_start'] = DateTime.now().toIso8601String();
      }

      await supabaseService.client
          .from('tasks')
          .update(updateMap)
          .eq('id', taskId);

      await supabaseService.client.from('task_pauses').insert({
        'task_id': taskId,
        'reason': reason.trim(),
        'paused_by': userId,
      });
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> resumePause({
    required String pauseId,
    required String taskId,
  }) async {
    try {
      await supabaseService.client
          .from('tasks')
          .update({'status': 'in_progress'})
          .eq('id', taskId);
      await supabaseService.client
          .from('task_pauses')
          .update({'resumed_at': DateTime.now().toIso8601String()})
          .eq('id', pauseId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required TaskStatus newStatus,
  }) async {
    try {
      // Step 1: Update task status
      await supabaseService.client
          .from('tasks')
          .update({
            'status': newStatus.dbValue,
            'updated_at': DateTime.now().toIso8601String(),
            if (newStatus == TaskStatus.inProgress)
              'actual_start': DateTime.now().toIso8601String(),
            if (newStatus == TaskStatus.completed ||
                newStatus == TaskStatus.cancelled)
              'actual_end': DateTime.now().toIso8601String(),
          })
          .eq('id', taskId);

      // Step 2: Fetch task to get unit_id and service request keys
      final taskData = await supabaseService.client
          .from('tasks')
          .select('unit_id, flight_id, service_type_id')
          .eq('id', taskId)
          .single();

      final unitId        = taskData['unit_id'] as String?;
      final flightId      = taskData['flight_id'] as String?;
      final serviceTypeId = taskData['service_type_id'] as String?;

      // Step 3: Update unit status
      if (unitId != null) {
        final unitStatus = switch (newStatus) {
          TaskStatus.inProgress => 'busy',
          TaskStatus.completed  => 'available',
          TaskStatus.cancelled  => 'available',
          _                     => null,
        };
        if (unitStatus != null) {
          await supabaseService.client
              .from('units')
              .update({'status': unitStatus})
              .eq('id', unitId);
        }
      }

      // Step 4: Update flight_service_request status
      if (flightId != null && serviceTypeId != null) {
        final fsrStatus = switch (newStatus) {
          TaskStatus.inProgress => 'in_progress',
          TaskStatus.completed  => 'completed',
          TaskStatus.cancelled  => 'cancelled',
          _                     => null,
        };
        if (fsrStatus != null) {
          await supabaseService.client
              .from('flight_service_requests')
              .update({
                'status': fsrStatus,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('flight_id', flightId)
              .eq('service_type_id', serviceTypeId)
              .eq('status', 'assigned');
        }
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
