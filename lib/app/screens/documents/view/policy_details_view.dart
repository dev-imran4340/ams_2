import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/document_controller.dart';

class PolicyDetailsView extends GetView<DocumentController> {
  final String? policyId;

  const PolicyDetailsView({
    super.key,
    this.policyId,
  });

  @override
  Widget build(BuildContext context) {
    final targetId = policyId ??
        (Get.arguments is Map ? Get.arguments['policyId'] as String? : null) ??
        (Get.arguments is String ? Get.arguments as String : '');

    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadPolicyDetails(targetId),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Ambient Curved Gradient Header
            EmployeeAmbientHeader(height: 220.h),

            // 2. Safe Area Content
            SafeArea(
              child: Column(
                children: [
                  // Top Corporate Navigation Bar
                  Padding(
                    padding: AppSpaces.horizontalPadding,
                    child: CustomScreenHeader(
                      title: 'Company Policy',
                      subtitle: 'Official guidelines & handbook',
                      showBackButton: true,
                      onBack: () => Get.back(),
                    ),
                  ),

                  AppSpaces.vSpace10,

                  // Scrollable Body
                  Expanded(
                    child: Obx(() {
                      if (controller.isDetailsLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2.5.w,
                          ),
                        );
                      }

                      final policy = controller.selectedDocument.value;
                      if (policy == null) {
                        return Center(
                          child: CustomStateView.empty(
                            icon: Icons.article_outlined,
                            title: 'Policy Unavailable',
                            message:
                                'Company policy details could not be loaded at this time.',
                            buttonText: 'Retry',
                            onAction: () =>
                                controller.loadPolicyDetails(targetId),
                          ),
                        );
                      }

                      final curVer = policy.currentVersion;
                      final bool needsAck = policy.requiresAcknowledgement &&
                          policy.acknowledged == false;
                      final bool isSubmitting = controller.isSubmitting.value;

                      return Column(
                        children: [
                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.secondary,
                              onRefresh: () =>
                                  controller.loadPolicyDetails(targetId),
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 8.h,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // 1. Policy Overview Header Card
                                    CustomCard(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 14.h,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  policy.title,
                                                  style: AppTextStyles.text16
                                                      .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              AppSpaces.hSpace8,
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 3.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                ),
                                                child: Text(
                                                  'Version ${policy.version}',
                                                  style: AppTextStyles.text10
                                                      .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (policy.publishedOn != null) ...[
                                            AppSpaces.vSpace8,
                                            Text(
                                              'Published: ${policy.publishedOn}',
                                              style:
                                                  AppTextStyles.text12.copyWith(
                                                color: AppColors.subTextColor,
                                              ),
                                            ),
                                          ],
                                          if (curVer?.publishedBy != null) ...[
                                            AppSpaces.vSpace4,
                                            Text(
                                              'Author: ${curVer!.publishedBy}',
                                              style:
                                                  AppTextStyles.text12.copyWith(
                                                color: AppColors.subTextColor,
                                              ),
                                            ),
                                          ],
                                          if (curVer?.changeNote != null &&
                                              curVer!.changeNote!
                                                  .isNotEmpty) ...[
                                            AppSpaces.vSpace10,
                                            Container(
                                              padding: EdgeInsets.all(8.w),
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColors.backgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.info_outline_rounded,
                                                    size: 14.w,
                                                    color: AppColors.secondary,
                                                  ),
                                                  AppSpaces.hSpace6,
                                                  Expanded(
                                                    child: Text(
                                                      'Change note: ${curVer.changeNote}',
                                                      style: AppTextStyles
                                                          .text10
                                                          .copyWith(
                                                        color: AppColors
                                                            .subTextColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    AppSpaces.vSpace14,

                                    // 2. Policy File / Document Content Card
                                    if (curVer?.fileName != null) ...[
                                      CustomCard(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 14.h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 36.r,
                                                  height: 36.r,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.secondary
                                                        .withValues(
                                                            alpha: 0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.r),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons
                                                          .picture_as_pdf_rounded,
                                                      size: 18.w,
                                                      color:
                                                          AppColors.secondary,
                                                    ),
                                                  ),
                                                ),
                                                AppSpaces.hSpace10,
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        curVer!.fileName!,
                                                        style: AppTextStyles
                                                            .text12
                                                            .copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      AppSpaces.vSpace2,
                                                      Text(
                                                        'Official Company Document',
                                                        style: AppTextStyles
                                                            .text10
                                                            .copyWith(
                                                          color: AppColors
                                                              .subTextColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            AppSpaces.vSpace12,
                                            Obx(() {
                                              final isDl = controller
                                                  .downloadingFileIds
                                                  .contains(
                                                      '${policy.id}-${curVer.version}');
                                              return CustomButton(
                                                text: isDl
                                                    ? 'Downloading...'
                                                    : 'Open Document File',
                                                icon: Icon(
                                                  Icons.open_in_new_rounded,
                                                  size: 16.sp,
                                                  color: Colors.white,
                                                ),
                                                isLoading: isDl,
                                                onPressed: () => controller
                                                    .downloadAndOpenPolicyFile(
                                                  policy.id,
                                                  curVer.version,
                                                  curVer.fileName!,
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                      AppSpaces.vSpace14,
                                    ],

                                    // 3. HTML / Text Body Content (if provided)
                                    if (curVer?.body != null &&
                                        curVer!.body!.isNotEmpty) ...[
                                      CustomCard(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 14.h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Policy Guidelines',
                                              style:
                                                  AppTextStyles.text14.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            AppSpaces.vSpace10,
                                            Text(
                                              curVer.body!,
                                              style:
                                                  AppTextStyles.text12.copyWith(
                                                color: AppColors.textColor,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppSpaces.vSpace14,
                                    ],

                                    // 4. Version History List
                                    if (policy.versions.isNotEmpty) ...[
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w),
                                        child: Text(
                                          'Version History',
                                          style: AppTextStyles.text14.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      AppSpaces.vSpace8,
                                      ...policy.versions.map((v) {
                                        final bool isCurrent =
                                            v.version == policy.version;
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 8.h),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 10.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isCurrent
                                                ? AppColors.cardBackground
                                                : AppColors.backgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            border: Border.all(
                                              color: isCurrent
                                                  ? AppColors.secondary
                                                      .withValues(alpha: 0.5)
                                                  : AppColors.borderColor,
                                              width: 1.w,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 2.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isCurrent
                                                      ? AppColors.secondary
                                                      : AppColors.subTextColor
                                                          .withValues(
                                                              alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                                child: Text(
                                                  'v${v.version}',
                                                  style: AppTextStyles.text10
                                                      .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: isCurrent
                                                        ? Colors.white
                                                        : AppColors.textColor,
                                                  ),
                                                ),
                                              ),
                                              AppSpaces.hSpace10,
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      v.publishedBy != null
                                                          ? 'By ${v.publishedBy}'
                                                          : 'Version update',
                                                      style: AppTextStyles
                                                          .text12
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    if (v.changeNote != null &&
                                                        v.changeNote!
                                                            .isNotEmpty) ...[
                                                      AppSpaces.vSpace2,
                                                      Text(
                                                        v.changeNote!,
                                                        style: AppTextStyles
                                                            .text10
                                                            .copyWith(
                                                          color: AppColors
                                                              .subTextColor,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      AppSpaces.vSpace14,
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Bottom Sticky Acknowledgment Action
                          if (needsAck)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.borderColor,
                                    width: 1.w,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.08),
                                    blurRadius: 10.r,
                                    offset: Offset(0, -3.h),
                                  ),
                                ],
                              ),
                              child: CustomButton(
                                text: 'I Have Read & Acknowledge',
                                isGradient: true,
                                isLoading: isSubmitting,
                                onPressed: () =>
                                    controller.acknowledgePolicy(policy.id),
                              ),
                            )
                          else if (policy.requiresAcknowledgement &&
                              policy.acknowledged == true)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.success,
                                    width: 2.w,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 16.w,
                                    color: AppColors.success,
                                  ),
                                  AppSpaces.hSpace8,
                                  Text(
                                    'You have acknowledged this policy',
                                    style: AppTextStyles.text12.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
