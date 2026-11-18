import 'dart:convert';
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
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/employee_ambient_header.dart';
import '../../../core/widgets/network_boundary_wrapper.dart';
import '../controller/evaluation_controller.dart';
import '../model/evaluation_model.dart';

class EvaluationDetailsView extends GetView<EvaluationController> {
  final String? evaluationId;

  const EvaluationDetailsView({
    super.key,
    this.evaluationId,
  });

  @override
  Widget build(BuildContext context) {
    final String targetId = evaluationId ??
        (Get.arguments is Map ? Get.arguments['evaluationId'] as String? : null) ??
        (Get.arguments is String ? Get.arguments as String : '');

    return NetworkBoundaryWrapper(
      onRetry: () => controller.loadReviewDetails(targetId),
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
                      title: 'Evaluation Details',
                      subtitle: 'Performance & review assessment',
                      showBackButton: true,
                      onBack: () => Get.back(),
                    ),
                  ),

                  AppSpaces.vSpace10,

                  // Body Content
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

                      final details = controller.selectedReview.value;
                      if (details == null) {
                        return Center(
                          child: CustomStateView.empty(
                            icon: Icons.assignment_outlined,
                            title: 'No Evaluation Found',
                            message:
                                'Evaluation details could not be loaded at this time.',
                            buttonText: 'Retry',
                            onAction: () =>
                                controller.loadReviewDetails(targetId),
                          ),
                        );
                      }

                      final canEdit = (details.can.save || details.can.submit);
                      final writesAs = details.viewer.writesAs;

                      return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.secondary,
                  onRefresh: () => controller.loadReviewDetails(targetId),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 14.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Overview Metadata Card
                        _buildHeaderCard(details),

                        AppSpaces.vSpace14,

                        // 2. Final Score / Result Card (if finalized)
                        if (details.result != null) ...[
                          _buildResultCard(details.result!),
                          AppSpaces.vSpace14,
                        ],

                        // 3. Sections & Questions
                        ...details.sections.map(
                          (section) => _buildSectionWidget(
                            section,
                            details,
                            canEdit,
                            writesAs,
                          ),
                        ),

                        // 4. Goals Section (if present)
                        if (details.goals.isNotEmpty || details.can.editGoals) ...[
                          _buildGoalsSection(details, canEdit, writesAs),
                          AppSpaces.vSpace14,
                        ],

                        // 5. Manager Summary & Recommendation (if applicable)
                        if (writesAs == 'manager' ||
                            (details.summary != null &&
                                details.summary!.isNotEmpty)) ...[
                          _buildManagerSummarySection(details, canEdit, writesAs),
                          AppSpaces.vSpace14,
                        ],

                        // 6. Acknowledgement Section (if acknowledged or can acknowledge)
                        if (details.can.acknowledge ||
                            details.acknowledgedAt != null) ...[
                          _buildAcknowledgementSection(details),
                          AppSpaces.vSpace14,
                        ],

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Sticky Action Bar
              if (details.can.save ||
                  details.can.submit ||
                  details.can.acknowledge ||
                  details.can.decline)
                _buildBottomActionBar(details),
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

  // --- Header Card ---
  Widget _buildHeaderCard(EvaluationDetailsModel details) {
    Color toneColor = AppColors.primary;
    switch (details.tone.toLowerCase()) {
      case 'emerald':
        toneColor = AppColors.success;
        break;
      case 'amber':
        toneColor = AppColors.warning;
        break;
      case 'rose':
        toneColor = AppColors.error;
        break;
      case 'slate':
        toneColor = AppColors.subTextColor;
        break;
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  details.cycle.name,
                  style: AppTextStyles.text14.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: toneColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: toneColor.withValues(alpha: 0.35),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  details.statusLabel,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                    color: toneColor,
                  ),
                ),
              ),
            ],
          ),
          AppSpaces.vSpace10,
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            title: 'Employee',
            value:
                '${details.employee.name} (${details.employee.number})${details.employee.designation != null ? " • ${details.employee.designation}" : ""}',
          ),
          if (details.reviewer != null && details.reviewer!.isNotEmpty) ...[
            AppSpaces.vSpace6,
            _buildInfoRow(
              icon: Icons.rate_review_outlined,
              title: 'Reviewer',
              value: details.reviewer!,
            ),
          ],
          if (details.cycle.periodFrom != null &&
              details.cycle.periodTo != null) ...[
            AppSpaces.vSpace6,
            _buildInfoRow(
              icon: Icons.date_range_rounded,
              title: 'Evaluation Period',
              value: '${details.cycle.periodFrom} to ${details.cycle.periodTo}',
            ),
          ],
          if (details.managerDueOn != null && details.managerDueOn!.isNotEmpty) ...[
            AppSpaces.vSpace6,
            _buildInfoRow(
              icon: Icons.event_note_rounded,
              title: 'Manager Due',
              value: details.managerDueOn!,
              valueColor: AppColors.warning,
            ),
          ] else if (details.selfDueOn != null && details.selfDueOn!.isNotEmpty) ...[
            AppSpaces.vSpace6,
            _buildInfoRow(
              icon: Icons.event_note_rounded,
              title: 'Self Due',
              value: details.selfDueOn!,
              valueColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.w, color: AppColors.secondary),
        AppSpaces.hSpace6,
        Text(
          '$title: ',
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.text12.copyWith(
              color: valueColor ?? AppColors.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // --- Result / Final Score Hero ---
  Widget _buildResultCard(EvaluationResultModel result) {
    return CustomCard(
      accentColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: AppColors.success, size: 22.w),
              AppSpaces.hSpace8,
              Text(
                'Final Appraisal Score',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (result.scoreText != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    result.scoreText!,
                    style: AppTextStyles.text16.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          if (result.levelLabel != null && result.levelLabel!.isNotEmpty) ...[
            AppSpaces.vSpace8,
            Text(
              'Appraisal Rating: ${result.levelLabel}',
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Sections & Questions ---
  Widget _buildSectionWidget(
    EvaluationSectionModel section,
    EvaluationDetailsModel details,
    bool canEdit,
    String? writesAs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Capsule
        Container(
          margin: EdgeInsets.only(top: 14.h, bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Text(
                section.title,
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              if (section.weight != '0' && section.weight.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Weight: ${section.weight}%',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Questions in this Section
        ...section.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final q = entry.value;

          final bool isMyTurn = (writesAs == 'self' && q.selfAnswers) ||
              (writesAs == 'manager' && q.managerAnswers) ||
              (writesAs == 'peer' && q.peersAnswer);
          final bool isEditable = canEdit && isMyTurn;

          return CustomCard(
            margin: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.text10.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    AppSpaces.hSpace8,
                    Expanded(
                      child: Text(
                        q.text,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (q.required)
                      Text(
                        '*',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),

                // Help Text
                if (q.help != null && q.help!.isNotEmpty) ...[
                  AppSpaces.vSpace8,
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14.w,
                          color: AppColors.subTextColor,
                        ),
                        AppSpaces.hSpace6,
                        Expanded(
                          child: Text(
                            q.help!,
                            style: AppTextStyles.text12.copyWith(
                              color: AppColors.subTextColor,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                AppSpaces.vSpace12,

                // Content / Input / Output
                if (isEditable)
                  _buildInteractiveQuestionInput(q, details)
                else
                  _buildReadOnlyQuestionOutput(q),
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- Interactive Question Input Form ---
  Widget _buildInteractiveQuestionInput(
    EvaluationQuestionModel q,
    EvaluationDetailsModel details,
  ) {
    if (q.kind == 'rating') {
      final scaleLevels = details.scale?.levels ?? [];
      final allowsNa = details.scale?.allowsNa ?? true;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final selected = controller.selectedRatings[q.id];
            final isNa = controller.isNaSelected[q.id] == true;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    ...scaleLevels.map((lvl) {
                      final isSelected = !isNa && selected == lvl.value;
                      return InkWell(
                        onTap: () {
                          controller.isNaSelected[q.id] = false;
                          controller.selectedRatings[q.id] = lvl.value;
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.borderColor,
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 15.w,
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.subTextColor,
                              ),
                              AppSpaces.hSpace4,
                              Text(
                                '${lvl.value} • ${lvl.label}',
                                style: AppTextStyles.text10.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (allowsNa)
                      InkWell(
                        onTap: () {
                          controller.isNaSelected[q.id] = true;
                          controller.selectedRatings[q.id] = null;
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isNa
                                ? AppColors.primary
                                : AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isNa
                                  ? AppColors.primary
                                  : AppColors.borderColor,
                              width: 1.w,
                            ),
                          ),
                          child: Text(
                            'N/A',
                            style: AppTextStyles.text10.copyWith(
                              color:
                                  isNa ? Colors.white : AppColors.subTextColor,
                              fontWeight:
                                  isNa ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Show level description if selected
                if (selected != null && !isNa) ...[
                  AppSpaces.vSpace8,
                  Text(
                    scaleLevels
                        .firstWhere(
                          (l) => l.value == selected,
                          orElse: () => const ReviewScaleLevelModel(
                              value: 0, label: '', description: ''),
                        )
                        .description,
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            );
          }),

          AppSpaces.vSpace10,

          CustomTextField(
            hintText: 'Comments or rationale (optional)...',
            controller: controller.textControllers[q.id],
            maxLines: 2,
            maxLength: 3000,
          ),
        ],
      );
    } else if (q.kind == 'text') {
      return CustomTextField(
        hintText: 'Type your response here...',
        controller: controller.textControllers[q.id],
        maxLines: 4,
        maxLength: 3000,
      );
    } else if (q.kind == 'number') {
      return CustomTextField(
        hintText: 'Enter numeric value...',
        controller: controller.textControllers[q.id],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (val) {
          controller.numberValues[q.id] = num.tryParse(val);
        },
      );
    } else if (q.kind == 'figures') {
      return _buildInteractiveFiguresInput(q, details);
    }

    return Text(
      'Question response form',
      style: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
    );
  }

  // --- Interactive Figures Month-by-Month Entry ---
  Widget _buildInteractiveFiguresInput(
    EvaluationQuestionModel q,
    EvaluationDetailsModel details,
  ) {
    final months = details.months;
    final columns = q.columns;

    return Obx(() {
      final currentMap = controller.figuresRows[q.id] ?? {};

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Figures (Tap a month to enter figures):',
            style: AppTextStyles.text12.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpaces.vSpace8,
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: months.map((m) {
              final hasData =
                  currentMap.containsKey(m) && currentMap[m]!.isNotEmpty;
              return ActionChip(
                label: Text(m),
                backgroundColor: hasData
                    ? AppColors.secondary.withValues(alpha: 0.15)
                    : AppColors.backgroundColor,
                labelStyle: TextStyle(
                  color: hasData ? AppColors.secondary : AppColors.textColor,
                  fontWeight: hasData ? FontWeight.w700 : FontWeight.w500,
                ),
                onPressed: () {
                  _showFigureMonthEditor(
                    questionId: q.id,
                    month: m,
                    columns: columns,
                  );
                },
              );
            }).toList(),
          ),
          AppSpaces.vSpace10,
          if (currentMap.isNotEmpty) ...[
            Text(
              'Entered Totals Summary:',
              style: AppTextStyles.text12.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            AppSpaces.vSpace6,
            _buildFiguresTable(currentMap, columns),
          ],
        ],
      );
    });
  }

  void _showFigureMonthEditor({
    required int questionId,
    required String month,
    required List<String> columns,
  }) {
    final controllers = <TextEditingController>[];
    final currentValues =
        controller.figuresRows[questionId]?[month] ?? <num>[];

    for (var i = 0; i < columns.length; i++) {
      final existingVal = i < currentValues.length ? currentValues[i] : 0;
      controllers.add(TextEditingController(text: existingVal.toString()));
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Enter Figures for $month',
                      style: AppTextStyles.text14.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                AppSpaces.vSpace10,
                ...columns.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final col = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            col,
                            style: AppTextStyles.text12.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        AppSpaces.hSpace8,
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            hintText: '0',
                            controller: controllers[idx],
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                AppSpaces.vSpace12,
                CustomButton(
                  text: 'Save Month Figures',
                  isGradient: true,
                  onPressed: () {
                    for (var i = 0; i < columns.length; i++) {
                      final val = num.tryParse(controllers[i].text) ?? 0;
                      controller.updateFigureCell(
                        questionId: questionId,
                        month: month,
                        columnIndex: i,
                        totalColumns: columns.length,
                        value: val,
                      );
                    }
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- Read-Only Question Output Display ---
  Widget _buildReadOnlyQuestionOutput(EvaluationQuestionModel q) {
    final selfAns = q.selfAnswer ?? q.mine;
    final mgrAns = q.managerAnswer;

    if (selfAns == null && mgrAns == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          'Pending response',
          style: AppTextStyles.text12.copyWith(
            color: AppColors.subTextColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selfAns != null) ...[
          _buildAnswerBlock(
            author: 'Employee Response',
            authorColor: AppColors.secondary,
            answer: selfAns,
            columns: q.columns,
          ),
        ],
        if (mgrAns != null) ...[
          if (selfAns != null) AppSpaces.vSpace10,
          _buildAnswerBlock(
            author: 'Manager Assessment',
            authorColor: AppColors.primary,
            answer: mgrAns,
            columns: q.columns,
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerBlock({
    required String author,
    required Color authorColor,
    required EvaluationAnswerModel answer,
    required List<String> columns,
  }) {
    dynamic parsedJson;
    if (answer.text != null && answer.text!.trim().startsWith('[')) {
      try {
        parsedJson = jsonDecode(answer.text!);
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: authorColor.withValues(alpha: 0.25),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: authorColor,
                  shape: BoxShape.circle,
                ),
              ),
              AppSpaces.hSpace6,
              Text(
                author,
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.w700,
                  color: authorColor,
                ),
              ),
              const Spacer(),
              if (answer.rating != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Score: ${answer.rating}/5 ${answer.ratingLabel != null ? "• ${answer.ratingLabel}" : ""}',
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else if (answer.na)
                Text(
                  'N/A',
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.subTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),

          AppSpaces.vSpace8,

          if (parsedJson is List &&
              parsedJson.isNotEmpty &&
              parsedJson.first is List) ...[
            _buildMatrixTable(parsedJson),
          ] else if (answer.rows != null && answer.rows!.isNotEmpty) ...[
            _buildFiguresTable(answer.rows!, columns),
          ] else if (answer.text != null && answer.text!.isNotEmpty) ...[
            Text(
              answer.text!,
              style: AppTextStyles.text12.copyWith(
                color: AppColors.textColor,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Figures Matrix Table ---
  Widget _buildFiguresTable(Map<String, dynamic> rows, List<String> columns) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: DataTable(
        headingRowHeight: 34.h,
        dataRowMinHeight: 30.h,
        dataRowMaxHeight: 34.h,
        columnSpacing: 16.w,
        horizontalMargin: 8.w,
        columns: [
          DataColumn(
            label: Text(
              'Month',
              style: AppTextStyles.text10.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          ...columns.map(
            (col) => DataColumn(
              label: Text(
                col,
                style: AppTextStyles.text10.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
        rows: rows.entries.map((e) {
          final month = e.key;
          final values = e.value is List ? (e.value as List) : [];
          return DataRow(
            cells: [
              DataCell(
                Text(
                  month,
                  style: AppTextStyles.text10.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...columns.asMap().entries.map((colEntry) {
                final idx = colEntry.key;
                final val = idx < values.length ? values[idx].toString() : '-';
                return DataCell(
                  Text(
                    val,
                    style: AppTextStyles.text10.copyWith(
                      color: AppColors.textColor,
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  // --- Product Matrix Table (Q64) ---
  Widget _buildMatrixTable(List<dynamic> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows.map((r) {
        if (r is! List) return const SizedBox.shrink();
        final title = r.isNotEmpty ? r[0].toString() : 'Product';
        final sub = r.length > 2 ? r[2].toString() : '';
        final status = r.length > 4 ? r[4].toString() : '';

        return Container(
          margin: EdgeInsets.only(bottom: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: AppColors.borderColor, width: 1.w),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.text12.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                    if (sub.isNotEmpty)
                      Text(
                        sub,
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (status.isNotEmpty)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: status.contains('Completed')
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.text10.copyWith(
                      color: status.contains('Completed')
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Goals Section ---
  Widget _buildGoalsSection(
    EvaluationDetailsModel details,
    bool canEdit,
    String? writesAs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 14.h, bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Text(
                'Evaluation Goals',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              if (details.can.editGoals)
                InkWell(
                  onTap: () => _showEditGoalsSheet(details),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note_rounded,
                          size: 16.w, color: AppColors.secondary),
                      AppSpaces.hSpace4,
                      Text(
                        'Edit Goals',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        ...details.goals.map((g) {
          final isManager = writesAs == 'manager';

          return CustomCard(
            margin: EdgeInsets.only(bottom: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        g.title,
                        style: AppTextStyles.text14.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'Weight: ${g.weight}%',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (g.measure != null && g.measure!.isNotEmpty) ...[
                  AppSpaces.vSpace4,
                  Text(
                    'Target: ${g.measure}',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
                AppSpaces.vSpace8,

                if (g.selfRating != null || g.selfComment != null) ...[
                  Text(
                    'Employee: ${g.selfRating != null ? "Score ${g.selfRating}/5" : ""} ${g.selfComment ?? ""}',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpaces.vSpace4,
                ],

                if (g.managerRating != null || g.managerComment != null) ...[
                  Text(
                    'Manager: ${g.managerRating != null ? "Score ${g.managerRating}/5" : ""} ${g.managerComment ?? ""}',
                    style: AppTextStyles.text12.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                if (canEdit && (isManager || writesAs == 'self')) ...[
                  AppSpaces.vSpace8,
                  CustomTextField(
                    hintText: 'Goal comment or progress notes...',
                    controller: controller.goalCommentControllers[g.id],
                    maxLines: 2,
                    maxLength: 1000,
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showEditGoalsSheet(EvaluationDetailsModel details) {
    Get.snackbar(
      'Goal Management',
      'Goals can be adjusted and weighted up to exactly 100%.',
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  // --- Manager Summary & Recommendation ---
  Widget _buildManagerSummarySection(
    EvaluationDetailsModel details,
    bool canEdit,
    String? writesAs,
  ) {
    final bool isManagerEditable = canEdit && writesAs == 'manager';

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manager Evaluation Summary',
            style: AppTextStyles.text14.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpaces.vSpace10,
          if (isManagerEditable) ...[
            CustomTextField(
              hintText: 'Provide comprehensive summary of evaluation...',
              controller: controller.managerSummaryController,
              maxLines: 4,
              maxLength: 3000,
            ),
            AppSpaces.vSpace10,
            if (details.recommendedActions.isNotEmpty) ...[
              Text(
                'Recommended Action',
                style: AppTextStyles.text12.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpaces.vSpace6,
              Obx(() {
                return Wrap(
                  spacing: 8.w,
                  children: details.recommendedActions.entries.map((e) {
                    final isSelected =
                        controller.selectedRecommendedAction.value == e.key;
                    return ChoiceChip(
                      label: Text(e.value),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textColor,
                      ),
                      onSelected: (val) {
                        controller.selectedRecommendedAction.value =
                            val ? e.key : null;
                      },
                    );
                  }).toList(),
                );
              }),
            ],
          ] else ...[
            Text(
              details.summary ?? 'No manager summary provided.',
              style: AppTextStyles.text12.copyWith(
                height: 1.4,
              ),
            ),
            if (details.recommendedActionLabel != null) ...[
              AppSpaces.vSpace8,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Recommended Action: ${details.recommendedActionLabel}',
                  style: AppTextStyles.text10.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // --- Acknowledgement Section ---
  Widget _buildAcknowledgementSection(EvaluationDetailsModel details) {
    return CustomCard(
      accentColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.secondary,
                size: 20.w,
              ),
              AppSpaces.hSpace8,
              Text(
                'Employee Acknowledgement',
                style: AppTextStyles.text14.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          AppSpaces.vSpace8,
          if (details.acknowledgedAt != null) ...[
            Text(
              'Acknowledged on ${details.acknowledgedAt}',
              style: AppTextStyles.text12.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (details.acknowledgementComment != null &&
                details.acknowledgementComment!.isNotEmpty) ...[
              AppSpaces.vSpace6,
              Text(
                'Comment: "${details.acknowledgementComment}"',
                style: AppTextStyles.text12.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ] else if (details.can.acknowledge) ...[
            Text(
              'You have read and can confirm your appraisal results.',
              style: AppTextStyles.text12.copyWith(
                color: AppColors.subTextColor,
              ),
            ),
            AppSpaces.vSpace10,
            CustomTextField(
              hintText: 'Optional acknowledgement remarks...',
              controller: controller.acknowledgeCommentController,
              maxLines: 2,
              maxLength: 3000,
            ),
          ],
        ],
      ),
    );
  }

  // --- Sticky Bottom Action Bar ---
  Widget _buildBottomActionBar(EvaluationDetailsModel details) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
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
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final isBusy = controller.isSubmitting.value;

          return Row(
            children: [
              if (details.can.decline) ...[
                Expanded(
                  child: CustomButton(
                    text: 'Decline',
                    isOutlined: true,
                    borderColor: AppColors.error,
                    textColor: AppColors.error,
                    isLoading: isBusy,
                    onPressed: isBusy
                        ? null
                        : () => _confirmDecline(details.id),
                  ),
                ),
                AppSpaces.hSpace10,
              ],

              if (details.can.save) ...[
                Expanded(
                  child: CustomButton(
                    text: 'Save Draft',
                    isOutlined: true,
                    borderColor: AppColors.secondary,
                    textColor: AppColors.secondary,
                    isLoading: isBusy,
                    onPressed: isBusy
                        ? null
                        : () => controller.saveDraft(details.id),
                  ),
                ),
                AppSpaces.hSpace10,
              ],

              if (details.can.submit) ...[
                Expanded(
                  child: CustomButton(
                    text: 'Submit Evaluation',
                    isGradient: true,
                    isLoading: isBusy,
                    onPressed: isBusy
                        ? null
                        : () => _confirmSubmit(details.id),
                  ),
                ),
              ],

              if (details.can.acknowledge) ...[
                Expanded(
                  child: CustomButton(
                    text: 'Acknowledge',
                    isGradient: true,
                    isLoading: isBusy,
                    onPressed: isBusy
                        ? null
                        : () => controller.acknowledgeReview(details.id),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  void _confirmSubmit(String id) {
    Get.defaultDialog(
      title: 'Submit Evaluation',
      titleStyle: AppTextStyles.text16.copyWith(fontWeight: FontWeight.w700),
      middleText:
          'Are you sure you want to finalize and submit this evaluation? This action cannot be undone.',
      middleTextStyle: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
      textConfirm: 'Confirm & Submit',
      textCancel: 'Review Again',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      cancelTextColor: AppColors.subTextColor,
      onConfirm: () {
        Get.back();
        controller.submitReview(id);
      },
    );
  }

  void _confirmDecline(String id) {
    Get.defaultDialog(
      title: 'Decline Feedback',
      titleStyle: AppTextStyles.text16.copyWith(fontWeight: FontWeight.w700),
      middleText:
          'Are you sure you want to decline this peer feedback request?',
      middleTextStyle: AppTextStyles.text12.copyWith(color: AppColors.subTextColor),
      textConfirm: 'Decline',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      cancelTextColor: AppColors.subTextColor,
      onConfirm: () {
        Get.back();
        controller.declineReview(id);
      },
    );
  }
}
