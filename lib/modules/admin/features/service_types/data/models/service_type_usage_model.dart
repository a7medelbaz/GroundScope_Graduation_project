class ServiceTypeUsageModel {
  const ServiceTypeUsageModel({
    required this.unitsCount,
    required this.activeTasksCount,
  });

  final int unitsCount;
  final int activeTasksCount;

  bool get isInUse => unitsCount > 0 || activeTasksCount > 0;
}
