import 'dart:async';

import '../../../api/exception_handler.dart';
import '../model/employee_card_model.dart';

class EmployeeCardRepo {
  final String _tag = 'EmployeeCardRepo / EmployeeCardScreen';

  final EmployeeCardDetails _mockCard = const EmployeeCardDetails(
    name: 'Muhammad Imran',
    employeeId: 'SFT-1024',
    designation: 'Senior Flutter Engineer',
    department: 'Mobile & AI Solutions',
    bloodGroup: 'O+',
    emergencyContact: '+92 300 1234567',
    joiningDate: '15 Jan 2024',
    validTill: '31 Dec 2027',
    qrPayload: 'AMS2::SFT-1024::SOFTGENIE-HQ::2027-12-31::VERIFIED',
    pdfDocumentUrl: 'https://docs.softgenie.com/cards/SFT-1024_Official_ID.pdf',
    isNfcVerified: true,
  );

  /// Fetches authenticated employee digital ID card credentials
  Future<EmployeeCardDetails?> fetchCardDetails() async {
    try {
      // Simulate backend secure vault latency
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockCard;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch employee card details: $e'),
        tag: '$_tag -> fetchCardDetails() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Generates official signed digital identity PDF document payload
  Future<String?> generateOfficialCardPdf() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockCard.pdfDocumentUrl;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to prepare official card PDF: $e'),
        tag: '$_tag -> generateOfficialCardPdf() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
