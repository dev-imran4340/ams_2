class DashboardModel {
  final int totalEmployees;
  final int onTimeToday;
  final int lateToday;
  final int absentToday;

  DashboardModel({
    this.totalEmployees = 0,
    this.onTimeToday = 0,
    this.lateToday = 0,
    this.absentToday = 0,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalEmployees: json['total_employees'] as int? ?? 142,
      onTimeToday: json['on_time_today'] as int? ?? 118,
      lateToday: json['late_today'] as int? ?? 14,
      absentToday: json['absent_today'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_employees': totalEmployees,
      'on_time_today': onTimeToday,
      'late_today': lateToday,
      'absent_today': absentToday,
    };
  }
}
