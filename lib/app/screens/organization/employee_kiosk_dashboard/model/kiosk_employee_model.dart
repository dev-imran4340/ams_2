class KioskEmployeeProfileModel {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String shift;
  final String avatarUrl;
  final bool isCheckedIn;
  final bool isOnBreak;
  final String? checkInTime;
  final String? breakTime;

  const KioskEmployeeProfileModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.shift,
    required this.avatarUrl,
    required this.isCheckedIn,
    required this.isOnBreak,
    this.checkInTime,
    this.breakTime,
  });

  factory KioskEmployeeProfileModel.mock() {
    return const KioskEmployeeProfileModel(
      id: 'EMP-0482',
      name: 'Muhammad Zeeshan',
      designation: 'Senior Flutter Developer',
      department: 'Software Engineering',
      shift: 'Morning General (09:00 AM - 06:00 PM)',
      avatarUrl: '',
      isCheckedIn: true,
      isOnBreak: false,
      checkInTime: '08:54 AM',
      breakTime: null,
    );
  }
}
