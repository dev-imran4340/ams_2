import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_spaces.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../controller/add_employee_controller.dart';

class AddEmployeeCityDialog {
  static void show(BuildContext context, AddEmployeeController controller) {
    controller.citySearchController.clear();
    controller.filterCities('');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.72,
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: Column(
              children: [
                // Modal Handle
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                AppSpaces.vSpace14,

                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select City',
                      style: AppTextStyles.text18.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20.sp,
                        color: AppColors.subTextColor,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),

                AppSpaces.vSpace12,

                // Search field
                CustomTextField(
                  controller: controller.citySearchController,
                  hintText: 'Search city...',
                  onChanged: controller.filterCities,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20.sp,
                    color: AppColors.secondary,
                  ),
                  suffixIcon: Obx(() {
                    final hasText = controller.filteredCities.length !=
                            controller.cities.length ||
                        controller.citySearchController.text.isNotEmpty;
                    if (!hasText) return const SizedBox.shrink();
                    return IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        size: 18.sp,
                        color: AppColors.subTextColor,
                      ),
                      onPressed: () {
                        controller.citySearchController.clear();
                        controller.filterCities('');
                      },
                    );
                  }),
                ),

                AppSpaces.vSpace14,

                // City list
                Expanded(
                  child: Obx(() {
                    if (controller.filteredCities.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 40.sp,
                              color: AppColors.subTextColor,
                            ),
                            AppSpaces.vSpace8,
                            Text(
                              controller.citySearchController.text.isEmpty
                                  ? 'No cities available for selected country'
                                  : 'No cities found matching "${controller.citySearchController.text}"',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.text12.copyWith(
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.filteredCities.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppColors.borderColor.withValues(alpha: 0.5),
                      ),
                      itemBuilder: (context, index) {
                        final city = controller.filteredCities[index];
                        final isSelected = controller.selectedCityModel.value?.name == city.name ||
                            controller.selectedCity.value == city.name;

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          leading: Container(
                            width: 34.r,
                            height: 34.r,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.secondary.withValues(alpha: 0.12)
                                  : AppColors.inputFill,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.location_city_rounded,
                              size: 18.sp,
                              color: isSelected ? AppColors.secondary : AppColors.subTextColor,
                            ),
                          ),
                          title: Text(
                            city.name,
                            style: AppTextStyles.text14.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.secondary : AppColors.textColor,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.secondary,
                                  size: 20.sp,
                                )
                              : null,
                          onTap: () {
                            controller.onCitySelected(city);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
