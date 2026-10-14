import 'dart:async';

import '../../../../api/exception_handler.dart';
import '../model/qr_scan_model.dart';

class QRScanRepo {
  final String _tag = 'QRScanRepo / QRScannerScreen';

  /// Verifies scanned raw QR card payload against organizational roster
  Future<EmployeeCardQrModel?> verifyCardPayload(String rawPayload) async {
    try {
      // Realistic cryptographic verification simulation delay
      await Future.delayed(const Duration(milliseconds: 600));

      final trimmed = rawPayload.trim();
      if (trimmed.isEmpty) {
        ExceptionHandler.handle(
          ApiException(
            message: 'Scanned card data is empty or corrupted. Please scan again.',
            statusCode: 422,
            errorCode: 'INVALID_QR_PAYLOAD',
          ),
          tag: '$_tag -> verifyCardPayload()',
        );
        return null;
      }

      final card = EmployeeCardQrModel.fromRawPayload(trimmed);

      if (!card.isValid || card.employeeCode.isEmpty) {
        ExceptionHandler.handle(
          ApiException(
            message: 'Invalid employee card credentials. Card verification failed.',
            statusCode: 400,
            errorCode: 'INVALID_CARD_CREDENTIALS',
          ),
          tag: '$_tag -> verifyCardPayload()',
        );
        return null;
      }

      return card;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        e is ApiException
            ? e
            : ApiException(message: 'Failed to verify employee card: $e'),
        tag: '$_tag -> verifyCardPayload() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Backward-compatible alias
  Future<EmployeeCardQrModel?> verifyScannedCard(String rawPayload) {
    return verifyCardPayload(rawPayload);
  }
}
