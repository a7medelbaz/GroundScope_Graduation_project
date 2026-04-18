class ChecklistItemModel {
  const ChecklistItemModel({
    required this.id,
    required this.taskId,
    required this.item,
    required this.isChecked,
    this.checkedAt,
    this.checkedBy,
    required this.orderIndex,
  });

  final String id;
  final String taskId;
  final String item;
  final bool isChecked;
  final DateTime? checkedAt;
  final String? checkedBy;
  final int orderIndex;

  factory ChecklistItemModel.fromMap(Map<String, dynamic> map) {
    return ChecklistItemModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      item: map['item'] as String,
      isChecked: map['is_checked'] as bool,
      checkedAt: map['checked_at'] != null
          ? DateTime.parse(map['checked_at'] as String)
          : null,
      checkedBy: map['checked_by'] as String?,
      orderIndex: map['order_index'] as int,
    );
  }

  ChecklistItemModel copyWith({bool? isChecked, DateTime? checkedAt}) {
    return ChecklistItemModel(
      id: id,
      taskId: taskId,
      item: item,
      isChecked: isChecked ?? this.isChecked,
      checkedAt: checkedAt ?? this.checkedAt,
      checkedBy: checkedBy,
      orderIndex: orderIndex,
    );
  }
}
