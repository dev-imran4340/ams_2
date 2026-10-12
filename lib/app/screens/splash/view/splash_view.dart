import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../components/splash_branding_logo.dart';
import '../controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.checkAuthentication,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SplashBrandingLogo(),
                Positioned(
                  bottom: 40.h,
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5.w,
                        ),
                      );
                    }
                    return AppSpaces.vSpace24;
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
