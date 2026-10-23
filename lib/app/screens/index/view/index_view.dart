import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/index_controller.dart';
import '../../main_shell/view/components/app_drawer.dart';
import 'components/floating_bottom_nav_bar.dart';

class IndexView extends GetView<IndexController> {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: () async {
        await controller.fetchMe();
      },
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
          endDrawer: const AppDrawer(),
          backgroundColor: AppColors.backgroundColor,
          body: Stack(
            children: [
              // 1. IndexedStack preserves state & scroll position across all dynamic tabs
              Obx(() {
                final tabs = controller.navTabs;
                if (tabs.isEmpty) {
                  return const SizedBox.shrink();
                }
                final safeIndex = controller.currentIndex.value
                    .clamp(0, tabs.length - 1);

                final loaded = controller.loadedTabIndexes;

                return IndexedStack(
                  index: safeIndex,
                  children: List.generate(tabs.length, (i) {
                    if (loaded.contains(i)) {
                      return tabs[i].buildWidget();
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                );
              }),

              // 2. Floating Executive Bottom Navigation Bar
            ],
          ),
          bottomNavigationBar: const SafeArea(
            bottom: true,
            child: FloatingBottomNavBar(),
          ),
        ),
      ),
    );
  }
}
