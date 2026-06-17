part of 'dashboard_cubit.dart';

enum DashboardStatus { initial, loading, loaded, failure }

final class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.activeTaskCount = 0,
    this.pendingRequestCount = 0,
    this.availableUnitCount = 0,
    this.totalUnitCount = 0,
    this.openReportCount = 0,
    this.pendingRequests = const [],
    this.unitsPreview = const [],
    this.serviceTypeName,
    this.error,
  });

  final DashboardStatus status;
  final int activeTaskCount;
  final int pendingRequestCount;
  final int availableUnitCount;
  final int totalUnitCount;
  final int openReportCount;
  final List<ServiceRequestModel> pendingRequests;
  final List<UnitModel> unitsPreview;
  final String? serviceTypeName;
  final AppError? error;

  DashboardState copyWith({
    DashboardStatus? status,
    int? activeTaskCount,
    int? pendingRequestCount,
    int? availableUnitCount,
    int? totalUnitCount,
    int? openReportCount,
    List<ServiceRequestModel>? pendingRequests,
    List<UnitModel>? unitsPreview,
    String? serviceTypeName,
    AppError? error,
  }) {
    return DashboardState(
      status: status ?? this.status,
      activeTaskCount: activeTaskCount ?? this.activeTaskCount,
      pendingRequestCount: pendingRequestCount ?? this.pendingRequestCount,
      availableUnitCount: availableUnitCount ?? this.availableUnitCount,
      totalUnitCount: totalUnitCount ?? this.totalUnitCount,
      openReportCount: openReportCount ?? this.openReportCount,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      unitsPreview: unitsPreview ?? this.unitsPreview,
      serviceTypeName: serviceTypeName ?? this.serviceTypeName,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeTaskCount,
        pendingRequestCount,
        availableUnitCount,
        totalUnitCount,
        openReportCount,
        pendingRequests,
        unitsPreview,
        serviceTypeName,
        error,
      ];
}
