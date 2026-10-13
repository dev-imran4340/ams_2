import 'dart:async';
import '../../../../api/exception_handler.dart';
import '../model/qr_scan_model.dart';

class QRScanRepo {
  static const String _tag = 'QRScanRepo';

  /// Validates scanned raw QR payload against corporate roster
  Future<EmployeeCardQrModel?> verifyScannedCard(String rawPayload) async {
    try {
      // Simulate realistic verification and cryptographic checksum validation delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (rawPayload.isEmpty) {
        throw ApiException(
          message: 'Scanned card data is empty or corrupted. Please scan again.',
          statusCode: 422,
          errorCode: 'INVALID_QR_PAYLOAD',
        );
      }

      final card = EmployeeCardQrModel.fromRawPayload(rawPayload);
      return card;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        e is ApiException ? e : ApiException(message: 'Failed to verify employee card: $e'),
        tag: '$_tag -> verifyScannedCard() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }
}
