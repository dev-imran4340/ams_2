import '../model/department_employee_model.dart';

class DepartmentEmployeesRepo {
  final List<DepartmentEmployeeModel> _mockDepartmentStaff = const [
    DepartmentEmployeeModel(
      id: '01m5kmp9fmnb75vnt7z1k2pagv',
      employeeCode: 'KUM-1001',
      name: 'Maryam Malik',
      designation: 'Department Operations Lead',
      department: 'Operations & Management',
      email: 'maryam@example.com',
      status: 'Active',
      joiningDate: '12 Jan 2022',
      personalPhone: '+92 300 8547219',
      residentialAddress: 'House 14-B, Street 9, Sector F-8/3, Islamabad',
      emergencyContact: 'Tariq Malik (Spouse: +92 321 5567890)',
      passportOrCnicExpiry: '24 Nov 2029',
    ),
    DepartmentEmployeeModel(
      id: '01m5kmp9fmnb75vnt7z1k2pb01',
      employeeCode: 'KUM-1042',
      name: 'Farhan Ahmed',
      designation: 'Senior Systems Analyst',
      department: 'Operations & Management',
      email: 'farhan.ahmed@kumash.com',
      status: 'Active',
      joiningDate: '01 Mar 2023',
      personalPhone: '+92 333 4128976',
      residentialAddress: 'Apartment 402, Executive Heights, Gulberg III, Lahore',
      emergencyContact: 'Rehana Ahmed (Mother: +92 301 2233445)',
      passportOrCnicExpiry: '18 Jun 2028',
    ),
    DepartmentEmployeeModel(
      id: '01m5kmp9fmnb75vnt7z1k2pb02',
      employeeCode: 'KUM-1085',
      name: 'Ayesha Tariq',
      designation: 'HR Operations Specialist',
      department: 'Operations & Management',
      email: 'ayesha.tariq@kumash.com',
      status: 'Active',
      joiningDate: '15 Jul 2023',
      personalPhone: '+92 312 9988776',
      residentialAddress: 'House 88, Lane 4, DHA Phase 5, Karachi',
      emergencyContact: 'Tariq Mehmood (Father: +92 345 6677889)',
      passportOrCnicExpiry: '05 Sep 2027',
    ),
    DepartmentEmployeeModel(
      id: '01m5kmp9fmnb75vnt7z1k2pb03',
      employeeCode: 'KUM-1110',
      name: 'Bilal Raza',
      designation: 'Technical Support Specialist',
      department: 'Operations & Management',
      email: 'bilal.raza@kumash.com',
      status: 'Active',
      joiningDate: '10 Nov 2023',
      personalPhone: '+92 344 5544332',
      residentialAddress: 'Street 3, Block C, Soan Gardens, Islamabad',
      emergencyContact: 'Kamran Raza (Brother: +92 313 1122334)',
      passportOrCnicExpiry: '12 Jan 2030',
    ),
    DepartmentEmployeeModel(
      id: '01m5kmp9fmnb75vnt7z1k2pb04',
      employeeCode: 'KUM-1154',
      name: 'Zainab Noor',
      designation: 'Department Associate',
      department: 'Operations & Management',
      email: 'zainab.noor@kumash.com',
      status: 'Probation',
      joiningDate: '01 Feb 2024',
      personalPhone: '+92 321 7766554',
      residentialAddress: 'Flat 12, Pine Court, Sector G-11, Islamabad',
      emergencyContact: 'Dr. Noor (Father: +92 300 4433221)',
      passportOrCnicExpiry: '30 Mar 2026',
    ),
  ];

  Future<List<DepartmentEmployeeModel>> fetchDepartmentEmployees() async {
    // Simulated remote fetch with instantaneous local response
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockDepartmentStaff;
  }
}
