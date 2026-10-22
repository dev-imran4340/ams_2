import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../controller/edit_profile_controller.dart';

class EditProfileAvatarPicker extends GetView<EditProfileController> {
  const EditProfileAvatarPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final photo = controller.selectedPhoto.value;
      final profile = controller.currentProfile.value;
      final initials = profile?.initials ?? 'EM';

      return Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar Circle Container
              Container(
                width: 96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  gradient: photo == null
                      ? const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.accentNavy,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 2.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 18.r,
                      offset: Offset(0, 6.h),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: photo != null
                      ? Image.file(
                          photo,
                          fit: BoxFit.cover,
                          width: 96.r,
                          height: 96.r,
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: AppTextStyles.text28.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                ),
              ),

              // Camera Action Badge
              Positioned(
                bottom: 2.h,
                right: 2.w,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showPhotoSourceSheet(context),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cardBackground,
                          width: 2.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace10,

          // Helper Caption & Remove Photo Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _showPhotoSourceSheet(context),
                icon: Icon(
                  Icons.photo_library_outlined,
                  size: 15.sp,
                  color: AppColors.secondary,
                ),
                label: Text(
                  'Change Photo',
                  style: AppTextStyles.text12.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              if (photo != null) ...[
                Text(
                  '•',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
                TextButton(
                  onPressed: controller.removePhoto,
                  child: Text(
                    'Remove',
                    style: AppTextStyles.text12.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    });
  }

  /// Modern Bottom Sheet to pick photo source
  void _showPhotoSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                AppSpaces.vSpace14,
                Text(
                  'Profile Picture',
                  style: AppTextStyles.text16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                AppSpaces.vSpace4,
                Text(
                  'Choose a source to update your workplace avatar',
                  style: AppTextStyles.text12.copyWith(
                    color: AppColors.subTextColor,
                  ),
                ),
                AppSpaces.vSpace16,
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  title: Text(
                    'Take Photo',
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Capture instant portrait using camera',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.pickPhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.secondary,
                      size: 20.sp,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: AppTextStyles.text14.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Select high resolution image from storage',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.pickPhoto(ImageSource.gallery);
                  },
                ),
                if (controller.selectedPhoto.value != null)
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      'Remove Photo',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    subtitle: Text(
                      'Revert to initials avatar',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                    onTap: () {
                      Get.back();
                      controller.removePhoto();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
