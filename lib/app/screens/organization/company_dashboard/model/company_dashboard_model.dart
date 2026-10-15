class CompanyDashboardModel {
  final int totalEmployees;
  final int presentToday;
  final int absentToday;
  final int unmarkedToday;
  final int leavesToday;
  final List<CompanyRecentActivityModel> recentActivities;
  final List<CompanyRecentLeaveModel> recentLeaves;

  const CompanyDashboardModel({
    required this.totalEmployees,
    required this.presentToday,
    required this.absentToday,
    required this.unmarkedToday,
    required this.leavesToday,
    required this.recentActivities,
    required this.recentLeaves,
  });

  factory CompanyDashboardModel.mock() {
    return CompanyDashboardModel(
      totalEmployees: 160,
      presentToday: 138,
      absentToday: 14,
      unmarkedToday: 8,
      leavesToday: 6,
      recentActivities: [
        const CompanyRecentActivityModel(
          name: 'Muhammad Zeeshan',
          department: 'Software Engineering',
          type: 'Check-In',
          dated: 'Today',
          time: '08:54 AM',
          inTime: '08:54 AM',
          outTime: '—',
          isCheckIn: true,
        ),
        const CompanyRecentActivityModel(
          name: 'Ayesha Siddiqua',
          department: 'Product Design',
          type: 'Check-In',
          dated: 'Today',
          time: '09:02 AM',
          inTime: '09:02 AM',
          outTime: '—',
          isCheckIn: true,
        ),
        const CompanyRecentActivityModel(
          name: 'Bilal Farooq',
          department: 'Quality Assurance',
          type: 'Check-In',
          dated: 'Today',
          time: '09:15 AM',
          inTime: '09:15 AM',
          outTime: '—',
          isCheckIn: true,
        ),
        const CompanyRecentActivityModel(
          name: 'Usman Tariq',
          department: 'Operations',
          type: 'Check-Out',
          dated: 'Today',
          time: '01:05 PM',
          inTime: '08:45 AM',
          outTime: '01:05 PM',
          isCheckIn: false,
        ),
        const CompanyRecentActivityModel(
          name: 'Hamza Malik',
          department: 'Backend Infrastructure',
          type: 'Check-In',
          dated: 'Today',
          time: '09:22 AM',
          inTime: '09:22 AM',
          outTime: '—',
          isCheckIn: true,
        ),
      ],
      recentLeaves: const [
        CompanyRecentLeaveModel(
          name: 'Sara Khan',
          reason: 'Medical Leave - Doctor Appointment',
          leaveFrom: '15 Oct 2026',
          leaveTo: '16 Oct 2026',
          status: 'Approved',
        ),
        CompanyRecentLeaveModel(
          name: 'Farhan Ali',
          reason: 'Annual Casual Leave',
          leaveFrom: '15 Oct 2026',
          leaveTo: '18 Oct 2026',
          status: 'Approved',
        ),
        CompanyRecentLeaveModel(
          name: 'Zainab Bibi',
          reason: 'Emergency Family Event',
          leaveFrom: '15 Oct 2026',
          leaveTo: '15 Oct 2026',
          status: 'In Review',
        ),
      ],
    );
  }
}

class CompanyRecentActivityModel {
  final String name;
  final String department;
  final String type;
  final String dated;
  final String time;
  final String inTime;
  final String outTime;
  final bool isCheckIn;

  const CompanyRecentActivityModel({
    required this.name,
    required this.department,
    required this.type,
    required this.dated,
    required this.time,
    this.inTime = '—',
    this.outTime = '—',
    required this.isCheckIn,
  });
}

class CompanyRecentLeaveModel {
  final String name;
  final String reason;
  final String leaveFrom;
  final String leaveTo;
  final String status;

  const CompanyRecentLeaveModel({
    required this.name,
    required this.reason,
    required this.leaveFrom,
    required this.leaveTo,
    required this.status,
  });
}
