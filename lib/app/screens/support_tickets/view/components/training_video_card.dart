import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../model/support_ticket_model.dart';

/// Card widget for AMS Training Videos (GET /support/training-videos)
/// Strictly adheres to .agents/rules/ams.md:
/// - Padding: 12.w horizontal, 14.h vertical
/// - Border radius: 15.r
/// - Signature bottom border accent: 3.w Modern Teal
/// - flutter_screenutil responsiveness with zero pixel overflow
class TrainingVideoCard extends StatelessWidget {
  final TrainingVideoModel video;
  final VoidCallback onTap;

  const TrainingVideoCard({
    super.key,
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: CustomCard(
        onTap: onTap,
        accentColor: AppColors.secondary,
        showBottomAccent: true,
        accentWidth: 3.w,
        borderRadius: 15.r,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Video Thumbnail with Play Overlay & Badge
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Thumbnail Image
                        if (video.thumbnailUrl.isNotEmpty)
                          Image.network(
                            video.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: AppColors.accentNavy,
                              child: Center(
                                child: Icon(
                                  Icons.video_library_rounded,
                                  size: 40.r,
                                  color: AppColors.litePrimary,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            color: AppColors.accentNavy,
                            child: Center(
                              child: Icon(
                                Icons.video_library_rounded,
                                size: 40.r,
                                color: AppColors.litePrimary,
                              ),
                            ),
                          ),

                        // Subtle dark gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.45),
                              ],
                            ),
                          ),
                        ),

                        // Center Play Button Icon
                        Center(
                          child: Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.85),
                              border: Border.all(
                                color: AppColors.secondary,
                                width: 2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 12.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 28.r,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // AMS Official Guide Badge
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: AppColors.secondary.withValues(alpha: 0.6),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 11.r,
                                  color: AppColors.secondary,
                                ),
                                AppSpaces.hSpace4,
                                Text(
                                  'AMS Guide',
                                  style: AppTextStyles.text10.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                AppSpaces.vSpace12,

                // 2. Video Title
                Text(
                  video.title.isNotEmpty ? video.title : 'Training Video',
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // 3. Video Description (if present)
                if (video.description.isNotEmpty) ...[
                  AppSpaces.vSpace6,
                  Text(
                    video.description,
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                AppSpaces.vSpace12,

                // 4. Action Row (Watch Video Action)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.ondemand_video_rounded,
                          size: 14.r,
                          color: AppColors.secondary,
                        ),
                        AppSpaces.hSpace6,
                        Text(
                          'YouTube Official',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Watch Video',
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppSpaces.hSpace4,
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13.r,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }
