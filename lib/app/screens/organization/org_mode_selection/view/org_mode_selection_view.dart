import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/widgets/custom_state_view.dart';
import '../../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/org_mode_controller.dart';
import 'components/org_header_section.dart';
import 'components/org_selection_card.dart';

class OrgModeSelectionView extends GetView<OrgModeController> {
  const OrgModeSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkBoundaryWrapper(
      onRetry: controller.loadOptions,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Executive Curved Header Section (235.h)
              OrgHeaderSection(onLogout: controller.logout),
              AppSpaces.vSpace16,

              // 2. Overlap Card Section (-60.h translation: half card rests on the gradient container)
              Transform.translate(
                offset: Offset(0, -60.h),
                child: Padding(
                  padding: AppSpaces.horizontalPadding,
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

                    if (controller.options.isEmpty) {
                      return CustomStateView.empty(
                        title: 'No Operational Modules',
                        message:
                            'No organization modules are configured for this station.',
                        buttonText: 'Retry',
                        onAction: controller.loadOptions,
                      );
                    }

                    return Column(
                      children: controller.options.map((option) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: OrgSelectionCard(
                            option: option,
                            onTap: () => controller.selectOption(option.id),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ),
              ),

              // Bottom safety spacing
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
