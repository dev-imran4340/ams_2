import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/add_employee_controller.dart';
import 'components/add_employee_address_card.dart';
import 'components/add_employee_emergency_card.dart';
import 'components/add_employee_org_card.dart';
import 'components/add_employee_personal_card.dart';
import 'components/add_employee_photo_picker.dart';

class AddEmployeeView extends GetView<AddEmployeeController> {
  const AddEmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadLookupData,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Executive Curved Header Section
              _buildHeader(context),

              // 2. Overlapping Interactive Body Content (-45.h)
              Transform.translate(
                offset: Offset(0, -45.h),
                child: Padding(
                  padding: AppSpaces.horizontalPadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 640.w),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 60.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.secondary,
                                strokeWidth: 3.w,
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Photo Picker Component (preview, camera/gallery dialog)
                            const AddEmployeePhotoPicker(),

                            AppSpaces.vSpace16,

                            // 2. Personal Information Section
                            const AddEmployeePersonalCard(),

                            AppSpaces.vSpace16,

                            // 3. Address Information Section
                            const AddEmployeeAddressCard(),

                            AppSpaces.vSpace16,

                            // 4. Emergency Contact Section
                            const AddEmployeeEmergencyCard(),

                            AppSpaces.vSpace16,

                            // 5. Organization Placement Section
                            const AddEmployeeOrgCard(),

                            AppSpaces.vSpace24,

                            // 6. Submit Action Control
                            Obx(
                              () => CustomButton(
                                isGradient: true,
                                isLoading: controller.isSubmitting.value,
                                text: 'Submit',
                                icon: Icon(
                                  Icons.check_circle_rounded,
                                  size: 20.sp,
                                  color: AppColors.white,
                                ),
                                onPressed: controller.submitEmployeeRegistration,
                              ),
                            ),

                            AppSpaces.vSpace30,
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Executive Curved Header with Back Pill, Ambient Circles, and Corporate Title
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18.r),
          bottomRight: Radius.circular(18.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient Circles
          Positioned(
            top: -30.r,
            right: -20.r,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 20.r,
            left: -40.r,
            child: Container(
              width: 110.r,
              height: 110.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 64.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Navigation Bar
                  Row(
                    children: [
                      // Back Pill Button
                      InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.2),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 14.sp,
                                color: AppColors.white,
                              ),
                              AppSpaces.hSpace4,
                              Text(
                                'Back',
                                style: AppTextStyles.text12.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Terminal Station Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.4),
                            width: 0.8.w,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 13.sp,
                              color: AppColors.liteSecondary,
                            ),
                            AppSpaces.hSpace4,
                            Text(
                              'HR Administration',
                              style: AppTextStyles.text10.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpaces.vSpace16,

                  // Title & Subtitle
                  Text(
                    'Employee Registration',
                    style: AppTextStyles.text24.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpaces.vSpace4,
                  Text(
                    'Register new employee with personal, address, and emergency contact details.',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
