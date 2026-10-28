import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/correction_controller.dart';
import 'components/missed_punch_form_card.dart';

class CorrectionView extends GetView<CorrectionController> {
  const CorrectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Curved Ambient Gradient Header
            EmployeeAmbientHeader(height: 230.h),

            // 2. Main Scrollable Content Overlapping Header
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Executive Navigation Header with Back Button
                    const CustomScreenHeader(
                      title: 'Attendance Correction',
                      subtitle: 'Submit punch timing correction request',
                    ),

                    AppSpaces.vSpace14,

                    // Dynamic Body: Either the Form or the Post-Submission Action Card
                    Obx(() {
                      final reqId = controller.lastSubmittedRequestId.value;

                      if (reqId != null) {
                        return _buildSubmissionSuccessCard(reqId);
                      }

                      return const MissedPunchFormCard();
                    }),

                    // Bottom safe clearance
                    SizedBox(height: 70.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays the confirmation state with an action button navigating to Requests & Approvals
  Widget _buildSubmissionSuccessCard(String reqId) {
    final shortId = reqId.length > 8
        ? reqId.substring(reqId.length - 8)
        : reqId;

    return CustomCard(
      accentColor: AppColors.onTimeColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
      child: Column(
        children: [
          Container(
            width: 58.r,
            height: 58.r,
            decoration: BoxDecoration(
              color: AppColors.onTimeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 34.sp,
              color: AppColors.onTimeColor,
            ),
          ),
          AppSpaces.vSpace12,
          Text(
            'Request Submitted!',
            style: AppTextStyles.text18.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          AppSpaces.vSpace4,
          Text(
            'Reference #$shortId',
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          AppSpaces.vSpace8,
          Text(
            'Your attendance correction request has been sent for approval.',
            textAlign: TextAlign.center,
            style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
          ),
          AppSpaces.vSpace20,

          // Action Button: View in Requests & Approvals
          CustomButton(
            text: 'View in Requests & Approvals',
            isGradient: true,
            icon: Icon(
              Icons.inbox_rounded,
              size: 16.sp,
              color: AppColors.white,
            ),
            height: 48.h,
            borderRadius: 12.r,
            onPressed: controller.navigateToApprovals,
          ),

          AppSpaces.vSpace10,

          // Secondary Action: Submit Another Correction
          CustomButton(
            text: 'Submit Another Correction',
            isOutlined: true,
            borderColor: AppColors.borderColor,
            textColor: AppColors.textColor,
            height: 44.h,
            borderRadius: 12.r,
            onPressed: controller.resetForm,
          ),
        ],
      ),
    );
  }
}
