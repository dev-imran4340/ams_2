import 'package:ams_2/app/screens/employee_card/controller/employee_card_controller.dart';
import 'package:ams_2/app/screens/employee_card/model/employee_card_model.dart';
import 'package:ams_2/app/screens/employee_card/repo/employee_card_repo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmployeeCardDetails Model Tests', () {
    test('serializes and deserializes correctly', () {
      const details = EmployeeCardDetails(
        name: 'Muhammad Imran',
        employeeId: 'SFT-1024',
        designation: 'Senior Flutter Engineer',
        department: 'Mobile & AI Solutions',
        bloodGroup: 'O+',
        emergencyContact: '+92 300 1234567',
        joiningDate: '15 Jan 2024',
        validTill: '31 Dec 2027',
        qrPayload: 'AMS2::SFT-1024::ORG-HQ::SECURE_TOKEN',
        pdfDocumentUrl:
            'https://mock.Softech Business Services.com/cards/SFT-1024.pdf',
        isNfcVerified: true,
      );

      final json = details.toJson();
      expect(json['name'], 'Muhammad Imran');
      expect(json['employee_id'], 'SFT-1024');
      expect(json['designation'], 'Senior Flutter Engineer');
      expect(json['blood_group'], 'O+');
      expect(json['is_nfc_verified'], true);

      final parsed = EmployeeCardDetails.fromJson(json);
      expect(parsed.name, details.name);
      expect(parsed.employeeId, details.employeeId);
      expect(parsed.bloodGroup, 'O+');
      expect(parsed.validTill, '31 Dec 2027');
      expect(parsed.isNfcVerified, true);
    });

    test('copyWith preserves existing fields and modifies targeted values', () {
      const details = EmployeeCardDetails(
        name: 'Muhammad Imran',
        employeeId: 'SFT-1024',
        designation: 'Senior Flutter Engineer',
        department: 'Mobile & AI Solutions',
        bloodGroup: 'O+',
        emergencyContact: '+92 300 1234567',
        joiningDate: '15 Jan 2024',
        validTill: '31 Dec 2027',
        qrPayload: 'AMS2::SFT-1024::ORG-HQ::SECURE_TOKEN',
        pdfDocumentUrl:
            'https://mock.Softech Business Services.com/cards/SFT-1024.pdf',
        isNfcVerified: true,
      );

      final modified = details.copyWith(
        designation: 'Principal Architect',
        validTill: '31 Dec 2030',
      );

      expect(modified.name, 'Muhammad Imran');
      expect(modified.designation, 'Principal Architect');
      expect(modified.validTill, '31 Dec 2030');
      expect(modified.employeeId, 'SFT-1024');
    });
  });

  group('EmployeeCardRepo Tests', () {
    late EmployeeCardRepo repo;

    setUp(() {
      repo = EmployeeCardRepo();
    });

    test('fetchCardDetails returns valid authenticated details', () async {
      final card = await repo.fetchCardDetails();
      expect(card, isNotNull);
      expect(card!.employeeId, 'SFT-1024');
      expect(card.name, 'Muhammad Imran');
      expect(card.isNfcVerified, true);
      expect(card.qrPayload.contains('SFT-1024'), true);
    });

    test(
      'generateOfficialCardPdf returns valid official document link',
      () async {
        final pdfUrl = await repo.generateOfficialCardPdf();
        expect(pdfUrl, isNotNull);
        expect(pdfUrl!.endsWith('.pdf'), true);
      },
    );
  });

  group('EmployeeCardController Logic Tests', () {
    late EmployeeCardRepo repo;
    late EmployeeCardController controller;

    setUp(() {
      repo = EmployeeCardRepo();
      controller = EmployeeCardController(repo: repo);
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
    });

    test(
      'initializes with flip animation controller and loads card data',
      () async {
        expect(controller.flipAnimationController, isNotNull);
        expect(controller.isFlipped.value, false);

        await controller.loadCardData();
        expect(controller.cardData.value, isNotNull);
        expect(controller.cardData.value!.employeeId, 'SFT-1024');
        expect(controller.isLoading.value, false);
      },
    );

    test('flipCard toggles 3D flip state accurately', () {
      expect(controller.isFlipped.value, false);

      controller.flipCard();
      expect(controller.isFlipped.value, true);

      controller.flipCard();
      expect(controller.isFlipped.value, false);
    });
  });
}
