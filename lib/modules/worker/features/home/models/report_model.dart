class Report {
  final String taskName;
  final String description;
  final String? imagePath;
  final String timestamp;
  final String location;

  Report({
    required this.taskName,
    required this.description,
    this.imagePath,
    required this.timestamp,
    required this.location,
  });
}
