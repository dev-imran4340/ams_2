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
