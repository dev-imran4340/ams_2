import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../../../routes/app_routes.dart';
import '../../index/controller/index_controller.dart';
import '../controller/employee_card_controller.dart';
import 'components/card_quick_actions_bar.dart';
import 'components/card_security_info_card.dart';
import 'components/digital_id_card_widget.dart';

class EmployeeCardView extends GetView<EmployeeCardController> {
  const EmployeeCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadCardData,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Header (240.h)
            _buildCurvedAmbientHeader(context),

            // 2. Main Scrollable Content Overlapping the Header
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: controller.loadCardData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar: Back Glass Pill, Title & Subtitle Capsule
                      _buildTopBar(context),

                      AppSpaces.vSpace16,

                      // Dynamic Loading or Loaded Card View
                      Obx(() {
                        if (controller.isLoading.value) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 60.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5.w,
                              ),
                            ),
                          );
                        }

                        final card = controller.cardData.value;
                        if (card == null) {
                          return CustomStateView.empty(
                            title: 'Card Data Unavailable',
                            message: 'Could not load verified digital ID credentials.',
                            buttonText: 'Retry',
                            onAction: controller.loadCardData,
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Component 1: 3D Flip Smart Digital ID Card
                            const DigitalIdCardWidget(),

                            AppSpaces.vSpace16,

                            // Primary Action: Download Official ID Card PDF Button
                            Obx(() {
                              return CustomButton(
                                text: 'Download Official Card (PDF)',
                                icon: Icon(
                                  Icons.download_rounded,
                                  size: 18.sp,
                                  color: AppColors.white,
                                ),
                                isGradient: true,
                                isLoading: controller.isPdfLoading.value,
                                onPressed: controller.downloadCardPdf,
                              );
                            }),

                            AppSpaces.vSpace16,

                            // Component 2: Quick Actions Bar (Flip, Download, View PDF, Share)
                            const CardQuickActionsBar(),

                            AppSpaces.vSpace18,

                            // Component 3: Security & Cryptographic Telemetry Card
                            const CardSecurityInfoCard(),

                            // Bottom clearance
                            SizedBox(height: 70.h),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Signature Curved Ambient Gradient Header (220.h) matching Profile Screen light-to-dark gradient
  Widget _buildCurvedAmbientHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        gradient: const LinearGradient(
          colors: [
            AppColors.liteSecondary,
            AppColors.liteSecondary,
            AppColors.liteSecondary,
            AppColors.liteSecondary,
            AppColors.secondary,
            AppColors.primary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60.r,
            right: -40.r,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 20.r,
            left: -50.r,
            child: Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top navigation bar with Back Button, Title & Subtitle matching Profile Screen style
  Widget _buildTopBar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back Pill Button matching Profile Screen
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              if (Navigator.canPop(context)) {
                Get.back();
              } else if (Get.isRegistered<IndexController>()) {
                Get.find<IndexController>().changeTab(0);
              } else {
                Get.offAllNamed(Routes.INDEX);
              }
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(8.r),
              margin: EdgeInsets.only(right: 10.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 0.8.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: AppColors.textColor,
              ),
            ),
          ),
        ),

        // Title and Subtitle with flex protection
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Corporate Identity',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              AppSpaces.vSpace2,
              Text(
                'Digital Smart NFC & QR Card',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text10.copyWith(
                  color: AppColors.textColor.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
