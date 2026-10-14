import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
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

                            AppSpaces.vSpace18,

                            // Component 2: Quick Actions Bar (Flip, View PDF, Share, NFC)
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

  /// Signature Curved Ambient Gradient Header (240.h) with floating translucent rings
  Widget _buildCurvedAmbientHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primary,
            AppColors.accentNavy,
            AppColors.primary.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        child: Stack(
          children: [
            // Floating Translucent Ring 1 (Top Right)
            Positioned(
              top: -30.h,
              right: -30.w,
              child: Container(
                width: 150.r,
                height: 150.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.05),
                  border: Border.all(
                    color: AppColors.liteSecondary.withValues(alpha: 0.12),
                    width: 1.5.w,
                  ),
                ),
              ),
            ),

            // Floating Translucent Ring 2 (Bottom Left)
            Positioned(
              bottom: 15.h,
              left: -40.w,
              child: Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    width: 1.2.w,
                  ),
                ),
              ),
            ),

            // Subtle Halo (Center)
            Positioned(
              top: 45.h,
              right: 85.w,
              child: Container(
                width: 70.r,
                height: 70.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.02),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top executive navigation bar with Back Button, Title & Subtitle Capsule
  Widget _buildTopBar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back Glass Pill Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.28),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8.r,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15.sp,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),

        AppSpaces.hSpace12,

        // Title and Subtitle Capsule Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtitle Capsule: Digital Smart NFC & QR Card
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpaces.hSpace6,
                    Flexible(
                      child: Text(
                        'Digital Smart NFC & QR Card',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.liteSecondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpaces.vSpace4,

              // Title: Corporate Identity
              Text(
                'Corporate Identity',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text20.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
