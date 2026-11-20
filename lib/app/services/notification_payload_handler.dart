import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../screens/index/controller/index_controller.dart';
import '../screens/approvals/controller/approval_controller.dart';

/// Centralized navigation engine for opening target screens from
/// in-app notification bell items and FCM push notifications.
/// Strictly adheres to doc/api.md specifications:
/// - screen: "request"  -> Opens request page (GET /approvals/{id})
/// - screen: "requests" -> Opens Requests inbox, box "Waiting for me" (GET /approvals?box=waiting)
/// - unknown screen     -> Opens Notifications list
class NotificationPayloadHandler {
  static const String _tag = 'NotificationPayloadHandler';

  /// Routes to the intended screen given target metadata
  static Future<void> handleTarget({
    String? screen,
    String? id,
    String? link,
    String origin = 'InAppBell',
  }) async {
    Get.log('🔔 [$_tag] Processing navigation from $origin -> screen: "$screen", id: "$id", link: "$link"');

    final cleanScreen = screen?.trim().toLowerCase();
    final cleanId = id?.trim();

    // 1. Single Request Details (screen: "request", with ULID)
    if (cleanScreen == 'request' && cleanId != null && cleanId.isNotEmpty) {
      Get.log('🧭 [$_tag] Navigating to Approval Request Details for ID: $cleanId');

      if (Get.currentRoute == Routes.INDEX && Get.isRegistered<IndexController>()) {
        final indexCtrl = Get.find<IndexController>();
        final reqIdx = indexCtrl.navTabs.indexWhere((t) => t.id == 'requests');
        if (reqIdx != -1) {
          indexCtrl.changeTab(reqIdx);
        }
      }

      if (Get.isRegistered<ApprovalController>()) {
        final approvalCtrl = Get.find<ApprovalController>();
        await approvalCtrl.openApprovalDetailsById(cleanId);
      } else {
        await Get.toNamed(
          Routes.APPROVALS,
          arguments: {
            'box': 'waiting',
            'openId': cleanId,
          },
        );
      }
      return;
    }

    // 2. Requests Inbox (screen: "requests" -> box: "waiting")
    if (cleanScreen == 'requests') {
      Get.log('🧭 [$_tag] Navigating to Requests Inbox (Waiting for me)');

      if (Get.currentRoute == Routes.INDEX && Get.isRegistered<IndexController>()) {
        final indexCtrl = Get.find<IndexController>();
        final reqIdx = indexCtrl.navTabs.indexWhere((t) => t.id == 'requests');
        if (reqIdx != -1) {
          indexCtrl.changeTab(reqIdx);
        }
      }

      if (Get.isRegistered<ApprovalController>()) {
        final approvalCtrl = Get.find<ApprovalController>();
        approvalCtrl.changeBox('waiting');
        if (Get.currentRoute != Routes.INDEX && Get.currentRoute != Routes.APPROVALS) {
          Get.toNamed(Routes.APPROVALS, arguments: {'box': 'waiting'});
        }
      } else {
        await Get.toNamed(Routes.APPROVALS, arguments: {'box': 'waiting'});
      }
      return;
    }

    // 2.1 Leave Management Screen (screen: "leave")
    if (cleanScreen == 'leave') {
      Get.log('🧭 [$_tag] Navigating to Leave Management');
      if (Get.currentRoute != Routes.LEAVE) {
        await Get.toNamed(Routes.LEAVE);
      }
      return;
    }

    // 2.2 Payroll & Payslips Screen (screen: "payslips" or "payroll")
    if (cleanScreen == 'payslips' || cleanScreen == 'payroll') {
      Get.log('🧭 [$_tag] Navigating to Payroll & Payslips');
      if (Get.currentRoute != Routes.PAYROLL) {
        await Get.toNamed(Routes.PAYROLL);
      }
      return;
    }

    // 2.3 Loans & Money Requests Screen (screen: "money_request" or "loans")
    if (cleanScreen == 'money_request' || cleanScreen == 'loans') {
      Get.log('🧭 [$_tag] Navigating to Loans & Money Requests');
      if (Get.currentRoute != Routes.LOANS) {
        await Get.toNamed(Routes.LOANS);
      }
      return;
    }

    // 2.4 Support Tickets Screen (screen: "support" or "ticket")
    if (cleanScreen == 'support' ||
        cleanScreen == 'support_tickets' ||
        cleanScreen == 'ticket') {
      Get.log('🧭 [$_tag] Navigating to Support Tickets');
      if (Get.currentRoute != Routes.SUPPORT_TICKETS) {
        await Get.toNamed(Routes.SUPPORT_TICKETS);
      }
      return;
    }

    // 2.5 Attendance Screen (screen: "attendance")
    if (cleanScreen == 'attendance') {
      Get.log('🧭 [$_tag] Navigating to Attendance History');
      if (Get.currentRoute != Routes.ATTENDANCE_HISTORY) {
        await Get.toNamed(Routes.ATTENDANCE_HISTORY);
      }
      return;
    }

    // 2.6 Schedule Screen (screen: "schedule")
    if (cleanScreen == 'schedule') {
      Get.log('🧭 [$_tag] Navigating to Schedule & Rota');
      if (Get.currentRoute != Routes.SCHEDULE) {
        await Get.toNamed(Routes.SCHEDULE);
      }
      return;
    }

    // 2.7 Performance Evaluation Screen (screen: "review")
    if (cleanScreen == 'review') {
      Get.log('🧭 [$_tag] Navigating to Evaluation Screen for ID: $cleanId');
      if (Get.currentRoute != Routes.EVALUATION) {
        await Get.toNamed(
          Routes.EVALUATION,
          arguments: {
            if (cleanId != null && cleanId.isNotEmpty) 'openId': cleanId,
          },
        );
      }
      return;
    }

    // 2.8 Documents, Policies & Letters Screens (Phase 17)
    if (cleanScreen == 'my_documents' || cleanScreen == 'documents') {
      Get.log('🧭 [$_tag] Navigating to Documents (My Files)');
      if (Get.currentRoute != Routes.DOCUMENTS) {
        await Get.toNamed(Routes.DOCUMENTS, arguments: {'tab': 1});
      }
      return;
    }
    if (cleanScreen == 'company_document') {
      Get.log('🧭 [$_tag] Navigating to Company Policy: $cleanId');
      if (cleanId != null && cleanId.isNotEmpty) {
        await Get.toNamed(Routes.POLICY_DETAILS, arguments: {'policyId': cleanId});
      } else {
        await Get.toNamed(Routes.DOCUMENTS, arguments: {'tab': 0});
      }
      return;
    }
    if (cleanScreen == 'letter') {
      Get.log('🧭 [$_tag] Navigating to Letters');
      if (Get.currentRoute != Routes.DOCUMENTS) {
        await Get.toNamed(Routes.DOCUMENTS, arguments: {'tab': 2});
      }
      return;
    }
    if (cleanScreen == 'announcement') {
      Get.log('🧭 [$_tag] Navigating to Announcement: $cleanId');
      if (cleanId != null && cleanId.isNotEmpty) {
        await Get.toNamed(Routes.ANNOUNCEMENT_DETAILS, arguments: {'announcementId': cleanId});
      } else {
        await Get.toNamed(Routes.NEWS, arguments: {'initialTab': 0});
      }
      return;
    }

    // 2.9 HR Helpdesk & Support Tickets
    if (cleanScreen == 'helpdesk_ticket' || cleanScreen == 'helpdesk') {
      Get.log('🧭 [$_tag] Navigating to Helpdesk Ticket: $cleanId');
      if (cleanId != null && cleanId.isNotEmpty) {
        await Get.toNamed(Routes.HELPDESK_TICKET, arguments: cleanId);
      } else {
        await Get.toNamed(Routes.HELPDESK);
      }
      return;
    }

    // 2.10 Tasks (Onboarding / General)
    if (cleanScreen == 'task' || cleanScreen == 'tasks') {
      Get.log('🧭 [$_tag] Navigating to Tasks: $cleanId');
      await Get.toNamed(Routes.TASKS);
      return;
    }

    // 2.11 Training & Certifications
    if (cleanScreen == 'training') {
      Get.log('🧭 [$_tag] Navigating to Training: $cleanId');
      await Get.toNamed(Routes.TRAINING);
      return;
    }

    // 2.12 Company Assets
    if (cleanScreen == 'asset' || cleanScreen == 'assets') {
      Get.log('🧭 [$_tag] Navigating to Assets: $cleanId');
      await Get.toNamed(Routes.ASSETS);
      return;
    }

    // 2.13 Checklists
    if (cleanScreen == 'checklist' || cleanScreen == 'checklists') {
      Get.log('🧭 [$_tag] Navigating to Checklists: $cleanId');
      await Get.toNamed(Routes.CHECKLISTS);
      return;
    }

    // 3. Fallback for Unknown Screen Values -> Open Notifications List
    Get.log('🧭 [$_tag] Screen "$screen" unknown or general notification. Opening Notifications View.');
    if (Get.currentRoute != Routes.NOTIFICATIONS) {
      await Get.toNamed(Routes.NOTIFICATIONS);
    }
  }

  /// Parses Firebase RemoteMessage data map and navigates
  static Future<void> handleRemoteMessage(Map<String, dynamic>? data, {String origin = 'FCM'}) async {
    if (data == null || data.isEmpty) {
      Get.log('⚠️ [$_tag] Remote message payload empty. Opening Notifications List.');
      if (Get.currentRoute != Routes.NOTIFICATIONS) {
        await Get.toNamed(Routes.NOTIFICATIONS);
      }
      return;
    }

    final screen = data['screen']?.toString();
    final id = data['id']?.toString();
    final link = data['link']?.toString();

    await handleTarget(
      screen: screen,
      id: id,
      link: link,
      origin: origin,
    );
  }
}
