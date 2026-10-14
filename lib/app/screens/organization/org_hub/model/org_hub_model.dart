/// Data model representing high-level operational metrics and terminal telemetry
/// for the Organization Portal Hub.
class OrgPortalSummaryModel {
  final String organizationName;
  final String branchLocation;
  final int activeVisitorsCount;
  final int todayEmployeesPresent;
  final int totalStaff;
  final bool isGateTerminalActive;

  const OrgPortalSummaryModel({
    required this.organizationName,
    required this.branchLocation,
    required this.activeVisitorsCount,
    required this.todayEmployeesPresent,
    required this.totalStaff,
    required this.isGateTerminalActive,
  });

  /// Formatted attendance percentage (e.g. "88.8%")
  String get attendancePercentage {
    if (totalStaff <= 0) return '0.0';
    final percentage = (todayEmployeesPresent / totalStaff) * 100;
    return percentage.toStringAsFixed(1);
  }

  /// Decimal ratio for progress bars (0.0 to 1.0)
  double get attendanceRatio {
    if (totalStaff <= 0) return 0.0;
    return (todayEmployeesPresent / totalStaff).clamp(0.0, 1.0);
  }

  /// Absent staff count
  int get absentEmployeesCount {
    final diff = totalStaff - todayEmployeesPresent;
    return diff > 0 ? diff : 0;
  }

  factory OrgPortalSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrgPortalSummaryModel(
      organizationName: json['organization_name']?.toString() ??
          'SoftGenie Global Technologies',
      branchLocation:
          json['branch_location']?.toString() ?? 'HQ Campus • Islamabad',
      activeVisitorsCount: (json['active_visitors_count'] as num?)?.toInt() ?? 0,
      todayEmployeesPresent:
          (json['today_employees_present'] as num?)?.toInt() ?? 0,
      totalStaff: (json['total_staff'] as num?)?.toInt() ?? 0,
      isGateTerminalActive: json['is_gate_terminal_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization_name': organizationName,
      'branch_location': branchLocation,
      'active_visitors_count': activeVisitorsCount,
      'today_employees_present': todayEmployeesPresent,
      'total_staff': totalStaff,
      'is_gate_terminal_active': isGateTerminalActive,
    };
  }

  OrgPortalSummaryModel copyWith({
    String? organizationName,
    String? branchLocation,
    int? activeVisitorsCount,
    int? todayEmployeesPresent,
    int? totalStaff,
    bool? isGateTerminalActive,
  }) {
    return OrgPortalSummaryModel(
      organizationName: organizationName ?? this.organizationName,
      branchLocation: branchLocation ?? this.branchLocation,
      activeVisitorsCount: activeVisitorsCount ?? this.activeVisitorsCount,
      todayEmployeesPresent:
          todayEmployeesPresent ?? this.todayEmployeesPresent,
      totalStaff: totalStaff ?? this.totalStaff,
      isGateTerminalActive: isGateTerminalActive ?? this.isGateTerminalActive,
    );
  }
}
