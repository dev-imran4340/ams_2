import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/evaluation_controller.dart';

class QuarterlyCycleSelector extends GetView<EvaluationController> {
  const QuarterlyCycleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: Obx(() {
        final cycles = controller.cycles;
        final selected = controller.selectedCycle.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cycles.length,
          separatorBuilder: (_, _) => AppSpaces.hSpace8,
          itemBuilder: (context, index) {
            final cycle = cycles[index];
            final isSelected = selected == cycle;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.changeCycle(cycle),
                borderRadius: BorderRadius.circular(20.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderColor,
                      width: 1.w,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 10.r,
                              offset: Offset(0, 3.h),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpaces.hSpace6,
                      ],
                      Text(
                        cycle,
                        style: AppTextStyles.text12.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
