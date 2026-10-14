import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../../attendance_history/view/attendance_history_view.dart';
import '../../dashboard/view/dashboard_view.dart';
import '../../leaves/view/leave_requests_view.dart';
import '../../profile/view/profile_view.dart';
import '../controller/index_controller.dart';
import 'components/executive_app_drawer.dart';
import 'components/floating_bottom_nav_bar.dart';

class IndexView extends GetView<IndexController> {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () async {},
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          final canExit = controller.handleBackPress();
          if (canExit) {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          key: controller.scaffoldKey,
          endDrawer: const ExecutiveAppDrawer(),
          backgroundColor: AppColors.backgroundColor,
          body: Stack(
            children: [
              // 1. IndexedStack preserves state & scroll position across all 4 tabs
              Obx(
                () => IndexedStack(
                  index: controller.currentIndex.value,
                  children: const [
                    DashboardView(),
                    AttendanceHistoryView(),
                    LeaveRequestsView(),
                    ProfileView(),
                  ],
                ),
              ),

              // 2. Floating Executive Bottom Navigation Bar
            ],
          ),
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: FloatingBottomNavBar(),
          ),
        ),
      ),
    );
  }
}
