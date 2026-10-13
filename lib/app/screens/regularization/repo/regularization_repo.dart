import 'dart:async';

import '../../../api/exception_handler.dart';
import '../model/regularization_model.dart';

class RegularizationDataResult {
  final RegularizationTelemetry telemetry;
  final List<AdjustmentRequestItem> requests;

  const RegularizationDataResult({
    required this.telemetry,
    required this.requests,
  });
}

class RegularizationRepo {
  static const String _tag = 'RegularizationRepo';

  /// Fetches overtime telemetry and active adjustment request history
  Future<RegularizationDataResult?> fetchRegularizationData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      const telemetry = RegularizationTelemetry(
        monthlyOvertimeHours: 12.5,
        adjustmentsRemaining: 2,
        maxAdjustments: 3,
        pendingApprovalsCount: 1,
      );

      final requests = [
        const AdjustmentRequestItem(
          id: 'REG-4402',
          type: 'Missed Punch',
          date: '10 Oct 2026',
          details: 'Check-In: 09:05 AM (Biometric Hardware Glitch)',
          status: 'Pending',
          appliedAt: '11 Oct 2026',
          remarks:
              'Biometric scanner was offline upon morning entry; supervisor acknowledged on floor.',
          reviewerNotes: 'Pending HR review with floor attendance log.',
        ),
        const AdjustmentRequestItem(
          id: 'OT-1088',
          type: 'Overtime Claim',
          date: '08 Oct 2026',
          details: 'Overtime: 2.5 Hours (Production Sprint Deployment)',
          status: 'Approved',
          appliedAt: '09 Oct 2026',
          remarks:
              'Stayed post-shift for release candidate regression testing and server patch.',
          reviewerNotes: 'Approved by Hamza Sheikh (Tech Lead).',
        ),
        const AdjustmentRequestItem(
          id: 'REG-4190',
          type: 'Missed Punch',
          date: '28 Sep 2026',
          details: 'Check-Out: 06:15 PM (Power Interruption)',
          status: 'Approved',
          appliedAt: '29 Sep 2026',
          remarks: 'Main building UPS tripped during departure hour.',
          reviewerNotes: 'Approved. Power log verified by Facilities.',
        ),
        const AdjustmentRequestItem(
          id: 'OT-0941',
          type: 'Overtime Claim',
          date: '15 Sep 2026',
          details: 'Overtime: 4.0 Hours (Weekend Client Support)',
          status: 'Rejected',
          appliedAt: '16 Sep 2026',
          remarks: 'Emergency bugfix for beta pilot deployment.',
          reviewerNotes: 'Pre-approval requisition form was not submitted in advance.',
        ),
      ];

      return RegularizationDataResult(
        telemetry: telemetry,
        requests: requests,
      );
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch regularization data: $e'),
        tag:
            '$_tag -> fetchRegularizationData() [${stackTrace.toString().split('\n').first}]',
      );
      return null;
    }
  }

  /// Submits a missed punch regularization request
  Future<bool> submitMissedPunch(Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to submit missed punch request: $e'),
        tag:
            '$_tag -> submitMissedPunch() [${stackTrace.toString().split('\n').first}]',
      );
      return false;
    }
  }

  /// Submits an overtime compensation claim
  Future<bool> submitOvertimeClaim(Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to submit overtime claim: $e'),
        tag:
            '$_tag -> submitOvertimeClaim() [${stackTrace.toString().split('\n').first}]',
      );
      return false;
    }
  }
}
