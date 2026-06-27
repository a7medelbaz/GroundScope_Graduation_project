class ReportRecipientModel {
  const ReportRecipientModel({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.userName,
    this.userRole,
  });

  final String id;
  final String reportId;
  final String userId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final String? userName;
  final String? userRole;

  factory ReportRecipientModel.fromMap(Map<String, dynamic> map) {
    final userMap = map['user'] as Map<String, dynamic>?;
    return ReportRecipientModel(
      id: map['id'] as String,
      reportId: map['report_id'] as String,
      userId: map['user_id'] as String,
      isRead: map['is_read'] as bool? ?? false,
      readAt: map['read_at'] != null
          ? DateTime.parse(map['read_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      userName: userMap?['full_name'] as String?,
      userRole: userMap?['role'] as String?,
    );
  }
}
