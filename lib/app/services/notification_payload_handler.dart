import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../screens/index/controller/index_controller.dart';
import '../screens/leaves/controller/leave_controller.dart';

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
        final leaveIdx = indexCtrl.navTabs.indexWhere((t) => t.id == 'leave' || t.id == 'leaves' || t.id == 'requests');
        if (leaveIdx != -1) {
          indexCtrl.changeTab(leaveIdx);
        }
      }

      if (Get.isRegistered<LeaveController>()) {
        final leaveCtrl = Get.find<LeaveController>();
        await leaveCtrl.openApprovalDetailsById(cleanId);
      } else {
        await Get.toNamed(
          Routes.LEAVE,
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
        final leaveIdx = indexCtrl.navTabs.indexWhere((t) => t.id == 'leave' || t.id == 'leaves' || t.id == 'requests');
        if (leaveIdx != -1) {
          indexCtrl.changeTab(leaveIdx);
        }
      }

      if (Get.isRegistered<LeaveController>()) {
        final leaveCtrl = Get.find<LeaveController>();
        leaveCtrl.changeBox('waiting');
        if (Get.currentRoute != Routes.INDEX && Get.currentRoute != Routes.LEAVE) {
          Get.toNamed(Routes.LEAVE, arguments: {'box': 'waiting'});
        }
      } else {
        await Get.toNamed(Routes.LEAVE, arguments: {'box': 'waiting'});
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
