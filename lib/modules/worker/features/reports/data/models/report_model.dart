class ReportModel {
  final String title;
  final String description;
  final DateTime date;
  // Key: Hour (0-23), Value: Data points for that hour
  final Map<int, dynamic> hourlyData;
  final List<String> images;

  ReportModel({
    required this.title,
    required this.description,
    required this.date,
    required this.hourlyData,
    required this.images,
  });
}
