class TaskCheckListModel {
  final String id;
  final String taskId;
  final String item;
  final bool isChecked;
  final DateTime? checkedAt;
  final String? checkedBy;
  final int orderIndex;

  TaskCheckListModel({
    required this.id,
    required this.taskId,
    required this.item,
    required this.isChecked,
    this.checkedAt,
    this.checkedBy,
    required this.orderIndex,
  });

  /// Factory to create model from Supabase (Map)
  factory TaskCheckListModel.fromMap(Map<String, dynamic> map) {
    return TaskCheckListModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      item: map['item'] as String,
      isChecked: map['is_checked'] as bool? ?? false,
      checkedAt: map['checked_at'] != null
          ? DateTime.parse(map['checked_at'] as String)
          : null,
      checkedBy: map['checked_by'] as String?,
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  /// Convert to Map for creating/updating in Supabase
  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'item': item,
      'is_checked': isChecked,
      'checked_at': checkedAt?.toIso8601String(),
      'checked_by': checkedBy,
      'order_index': orderIndex,
    };
  }

  /// Helper method to create a copy with updated fields
  /// (Useful for toggling a checkbox in the UI)
  TaskCheckListModel copyWith({
    bool? isChecked,
    DateTime? checkedAt,
    String? checkedBy,
  }) {
    return TaskCheckListModel(
      id: id,
      taskId: taskId,
      item: item,
      isChecked: isChecked ?? this.isChecked,
      checkedAt: checkedAt ?? this.checkedAt,
      checkedBy: checkedBy ?? this.checkedBy,
      orderIndex: orderIndex,
    );
  }
}
