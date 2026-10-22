import 'package:ams_2/app/screens/edit_profile/controller/edit_profile_controller.dart';
import 'package:ams_2/app/screens/edit_profile/model/edit_profile_model.dart';
import 'package:ams_2/app/screens/edit_profile/repo/edit_profile_repo.dart';
import 'package:ams_2/app/screens/profile/model/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmployeeProfileModel Tests', () {
    test('serializes and deserializes correctly with all fields', () {
      const profile = EmployeeProfileModel(
        name: 'Malik Imran',
        email: 'imran@Softech Business Services.com',
        phone: '+92 300 9876543',
        cnic: '37405-9876543-1',
        dob: '15 June 1995',
        gender: 'Male',
        bloodGroup: 'B+',
        employeeId: 'EMP-2048',
        designation: 'Tech Lead',
        department: 'Mobility',
        joiningDate: '01 Feb 2023',
        reportingManager: 'Hamza Sheikh',
        shiftName: 'Morning Shift',
        shiftTime: '08:00 AM - 05:00 PM',
        graceMinutes: 20,
        workLocation: 'Islamabad HQ',
        address: 'Sector F-7/2, Street 10',
        city: 'Islamabad',
        postalCode: '44000',
        emergencyContactName: 'Ahmed Malik',
        emergencyContactPhone: '+92 333 1122334',
        emergencyContactRelation: 'Father',
      );

      final json = profile.toJson();
      expect(json['name'], 'Malik Imran');
      expect(json['phone'], '+92 300 9876543');
      expect(json['cnic'], '37405-9876543-1');
      expect(json['blood_group'], 'B+');
      expect(json['address'], 'Sector F-7/2, Street 10');

      final parsed = EmployeeProfileModel.fromJson(json);
      expect(parsed.name, profile.name);
      expect(parsed.phone, profile.phone);
      expect(parsed.cnic, profile.cnic);
      expect(parsed.bloodGroup, profile.bloodGroup);
      expect(parsed.initials, 'MI');
    });

    test('initials computation handles single and multi-word names', () {
      const singleName = EmployeeProfileModel(
        name: 'Rashid',
        email: 'test@test.com',
        employeeId: 'EMP-1',
        designation: 'Lead',
        department: 'Eng',
        joiningDate: '01 Jan 2024',
        reportingManager: 'Lead',
        shiftName: 'General',
        shiftTime: '9-5',
        graceMinutes: 15,
        workLocation: 'HQ',
      );
      expect(singleName.initials, 'RA');

      const multiName = EmployeeProfileModel(
        name: 'Malik Muhammad Imran',
        email: 'test@test.com',
        employeeId: 'EMP-1',
        designation: 'Lead',
        department: 'Eng',
        joiningDate: '01 Jan 2024',
        reportingManager: 'Lead',
        shiftName: 'General',
        shiftTime: '9-5',
        graceMinutes: 15,
        workLocation: 'HQ',
      );
      expect(multiName.initials, 'MI');
    });
  });

  group('EditProfileRequestModel Tests', () {
    test('applyTo updates all personal and contact fields', () {
      const initial = EmployeeProfileModel(
        name: 'Original Name',
        email: 'original@test.com',
        phone: '+92 300 0000000',
        cnic: '00000-0000000-0',
        dob: '01 Jan 1990',
        gender: 'Male',
        bloodGroup: 'A+',
        employeeId: 'EMP-100',
        designation: 'Engineer',
        department: 'Eng',
        joiningDate: '01 Jan 2020',
        reportingManager: 'Manager',
        shiftName: 'General',
        shiftTime: '9-5',
        graceMinutes: 15,
        workLocation: 'HQ',
        address: 'Old Address',
        city: 'Rawalpindi',
        postalCode: '46000',
        emergencyContactName: 'Old Contact',
        emergencyContactPhone: '+92 300 1111111',
        emergencyContactRelation: 'Friend',
      );

      const request = EditProfileRequestModel(
        name: 'Updated Name',
        email: 'updated@test.com',
        phone: '+92 300 9999999',
        cnic: '37405-1111111-1',
        dob: '14 May 1996',
        gender: 'Female',
        bloodGroup: 'AB+',
        address: 'New Street 12',
        city: 'Islamabad',
        postalCode: '44000',
        emergencyContactName: 'New Contact',
        emergencyContactPhone: '+92 321 9999999',
        emergencyContactRelation: 'Spouse',
      );

      final updated = request.applyTo(initial);

      expect(updated.name, 'Updated Name');
      expect(updated.email, 'updated@test.com');
      expect(updated.phone, '+92 300 9999999');
      expect(updated.gender, 'Female');
      expect(updated.bloodGroup, 'AB+');
      expect(updated.address, 'New Street 12');
      expect(updated.city, 'Islamabad');
      expect(updated.emergencyContactName, 'New Contact');
      expect(updated.emergencyContactRelation, 'Spouse');

      // Locked organizational fields should remain intact
      expect(updated.employeeId, 'EMP-100');
      expect(updated.designation, 'Engineer');
      expect(updated.department, 'Eng');
    });
  });

  group('EditProfileController Logic Tests', () {
    test('updates gender and blood group observables', () {
      final controller = EditProfileController(repo: EditProfileRepo());

      controller.setGender('Female');
      expect(controller.selectedGender.value, 'Female');

      controller.setBloodGroup('AB+');
      expect(controller.selectedBloodGroup.value, 'AB+');

      controller.onClose();
    });
  });
}
