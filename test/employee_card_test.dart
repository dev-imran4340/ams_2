import 'package:ams_2/app/screens/employee_card/controller/employee_card_controller.dart';
import 'package:ams_2/app/screens/employee_card/model/employee_card_model.dart';
import 'package:ams_2/app/screens/employee_card/repo/employee_card_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
    await GetStorage.init();
  });

  group('EmployeeCardDetails Model Tests', () {
    test('serializes and deserializes correctly', () {
      const details = EmployeeCardDetails(
        company: EmployeeCardCompany(
          name: 'Kumash',
          shortName: 'Ku',
          phone: '03155109822',
          address: 'test ad 1, Islamabad, 44000',
        ),
        name: 'Maryam Malik',
        employeeNumber: 'EMP-0002',
        designation: 'Sales Manager',
        department: 'Sales',
        cardNo: 1,
        issuedOn: '2023-07-15',
        colour: '#7f1d1d',
        orientation: 'vertical',
        qrValue: 'AMS1:MX0zbHeRVbzPIlBb8SjAwBChWK0oZvsb',
        pdfDocumentUrl: 'https://laravel.ams-hrpayroll.com/cards/EMP-0002.pdf',
        isNfcVerified: true,
      );

      final json = details.toJson();
      expect(json['name'], 'Maryam Malik');
      expect(json['employee_number'], 'EMP-0002');
      expect(json['designation'], 'Sales Manager');
      expect(json['colour'], '#7f1d1d');
      expect(json['orientation'], 'vertical');
      expect(json['card_no'], 1);

      final parsed = EmployeeCardDetails.fromJson(json);
      expect(parsed.name, details.name);
      expect(parsed.employeeId, 'EMP-0002');
      expect(parsed.company.name, 'Kumash');
      expect(parsed.cardNo, 1);
      expect(parsed.colour, '#7f1d1d');
      expect(parsed.orientation, 'vertical');
      expect(parsed.initials, 'MM');
      expect(parsed.isNfcVerified, true);
    });

    test('copyWith preserves existing fields and modifies targeted values', () {
      final mock = EmployeeCardDetails.mock();
      final modified = mock.copyWith(
        designation: 'VP of Global Sales',
        validTill: '31 Dec 2030',
      );

      expect(modified.name, 'Maryam Malik');
      expect(modified.designation, 'VP of Global Sales');
      expect(modified.validTill, '31 Dec 2030');
      expect(modified.employeeId, 'EMP-0002');
      expect(modified.colour, '#012b43');
      expect(modified.orientation, 'vertical');
    });

    test('initials and cardColor helpers evaluate properly', () {
      final card = EmployeeCardDetails.mock();
      expect(card.initials, 'MM');
      expect(card.cardColor.toARGB32(), 0xff012b43);
      expect(card.cardSubtitle, contains('Card 1'));
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
      expect(card!.employeeId, 'EMP-0002');
      expect(card.name, 'Maryam Malik');
      expect(card.isNfcVerified, true);
      expect(card.qrPayload.contains('AMS1:'), true);
      expect(card.orientation, 'vertical');
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
        expect(controller.cardData.value!.employeeId, 'EMP-0002');
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

    test('downloadCardPdf handles state and triggers without errors', () async {
      expect(controller.isPdfLoading.value, false);
      await controller.downloadCardPdf();
      expect(controller.isPdfLoading.value, false);
    });
  });
}

