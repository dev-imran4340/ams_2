import 'dart:async';
import '../../../api/exception_handler.dart';
import '../model/leave_model.dart';

class LeaveRepo {
  static const String _tag = 'LeaveRepo';

  /// Fetches quota and utilization breakdown across leave categories
  Future<List<LeaveBalanceModel>> fetchLeaveBalances() async {
    try {
      // Realistic simulation delay for network loader verification
      await Future.delayed(const Duration(milliseconds: 600));

      return const [
        LeaveBalanceModel(
          leaveType: 'Casual Leave',
          totalQuota: 12,
          usedCount: 4,
          remainingCount: 8,
          colorHex: '0xFF0DA6A3', // Secondary Teal
        ),
        LeaveBalanceModel(
          leaveType: 'Annual Leave',
          totalQuota: 18,
          usedCount: 4,
          remainingCount: 14,
          colorHex: '0xFF012B43', // Primary Navy
        ),
        LeaveBalanceModel(
          leaveType: 'Medical / Sick',
          totalQuota: 8,
          usedCount: 2,
          remainingCount: 6,
          colorHex: '0xFFF59E0B', // Amber / Warning
        ),
      ];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch leave balances: $e'),
        tag:
            '$_tag -> fetchLeaveBalances() [${stackTrace.toString().split('\n').first}]',
      );
      return [];
    }
  }

  /// Fetches recent leave request history with approval workflows
  Future<List<LeaveRequestItemModel>> fetchRecentRequests() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      return const [
        LeaveRequestItemModel(
          id: 'LR-8921',
          leaveType: 'Casual Leave',
          startDate: '18 Oct 2026',
          endDate: '20 Oct 2026',
          totalDays: 3,
          reason:
              'Attending family wedding ceremony and related festivities in hometown.',
          status: 'Pending',
          appliedAt: '14 Oct 2026',
          managerNotes: 'Under review by Engineering Team Lead.',
        ),
        LeaveRequestItemModel(
          id: 'LR-8812',
          leaveType: 'Medical / Sick',
          startDate: '06 Oct 2026',
          endDate: '07 Oct 2026',
          totalDays: 2,
          reason:
              'Severe viral fever and seasonal flu; medical consultation advised complete bed rest.',
          status: 'Approved',
          appliedAt: '05 Oct 2026',
          managerNotes: 'Approved. Medical certificate verified by HR.',
          attachmentName: 'Clinical_Prescription_Oct06.pdf',
        ),
        LeaveRequestItemModel(
          id: 'LR-8640',
          leaveType: 'Annual Leave',
          startDate: '22 Sep 2026',
          endDate: '26 Sep 2026',
          totalDays: 5,
          reason:
              'Pre-planned annual vacation with family to northern valleys.',
          status: 'Approved',
          appliedAt: '12 Sep 2026',
          managerNotes: 'Approved. Project deliverables handed over to Imran.',
        ),
        LeaveRequestItemModel(
          id: 'LR-8422',
          leaveType: 'Casual Leave',
          startDate: '01 Sep 2026',
          endDate: '02 Sep 2026',
          totalDays: 2,
          reason: 'Urgent documentation and property transfer appointment.',
          status: 'Rejected',
          appliedAt: '31 Aug 2026',
          managerNotes:
              'Declined due to scheduled client production deployment sprint.',
        ),
      ];
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to fetch recent requests: $e'),
        tag:
            '$_tag -> fetchRecentRequests() [${stackTrace.toString().split('\n').first}]',
      );
      return [];
    }
  }

  /// Submits a new leave request application
  Future<bool> submitLeaveApplication(Map<String, dynamic> body) async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      return true;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(message: 'Failed to submit leave application: $e'),
        tag:
            '$_tag -> submitLeaveApplication() [${stackTrace.toString().split('\n').first}]',
      );
      return false;
    }
  }
}
