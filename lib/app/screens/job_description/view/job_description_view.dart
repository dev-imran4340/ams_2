import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_spaces.dart';
import '../../../core/widgets/custom_screen_header.dart';
import '../../../core/widgets/custom_state_view.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../components/job_description_content_card.dart';
import '../controller/job_description_controller.dart';

class JobDescriptionView extends GetView<JobDescriptionController> {
  const JobDescriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadJobDescription,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // 1. Signature Ambient Header (Corporate Navy Gradient)
            EmployeeAmbientHeader(height: 220.h),

            // 2. Sticky Header + Scrollable Body
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 0),
                    child: const CustomScreenHeader(
                      title: 'Job Description',
                      subtitle: 'Role overview & terms of reference',
                    ),
                  ),
                  AppSpaces.vSpace14,
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.secondary,
                      backgroundColor: AppColors.cardBackground,
                      onRefresh: controller.loadJobDescription,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 4.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Body State or Content
                      Obx(() {
                        if (controller.isLoading.value) {
                          return SizedBox(
                            height: 0.6.sh,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.secondary,
                              ),
                            ),
                          );
                        }

                        if (controller.errorMessage.value.isNotEmpty) {
                          return SizedBox(
                            height: 0.6.sh,
                            child: Center(
                              child: CustomStateView.error(
                                title: 'Failed to Load',
                                message: controller.errorMessage.value,
                                onRetry: controller.loadJobDescription,
                              ),
                            ),
                          );
                        }

                        final data = controller.jobDescription.value;
                        if (data == null) {
                          return SizedBox(
                            height: 0.6.sh,
                            child: Center(
                              child: CustomStateView.empty(
                                title: 'No Job Description',
                                message:
                                    'No formal job description is currently published for your designation.',
                                onAction: controller.loadJobDescription,
                              ),
                            ),
                          );
                        }

                        return JobDescriptionContentCard(
                          data: data,
                          onDownloadPdf: () =>
                              controller.openAttachedFile(data.fileUrl),
                        );
                      }),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
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
