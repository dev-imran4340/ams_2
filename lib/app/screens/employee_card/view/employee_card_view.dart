import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/employee_card_controller.dart';
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
            // 1. Signature Curved Ambient Gradient Header (220.h)
            EmployeeAmbientHeader(height: 230.h),

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
                      const CustomScreenHeader(
                        title: 'Employee Card',
                        subtitle: 'Digital ID & QR Access Pass',
                      ),

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


}
