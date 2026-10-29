import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spaces.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../controller/money_request_controller.dart';
import '../../model/money_request_model.dart';

/// Modal bottom sheet for requesting a Staff Loan, Salary Advance, or Expense Claim
class ApplyMoneyRequestBottomSheet extends StatefulWidget {
  final MoneyRequestController controller;

  const ApplyMoneyRequestBottomSheet({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, MoneyRequestController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ApplyMoneyRequestBottomSheet(controller: controller),
    );
  }

  @override
  State<ApplyMoneyRequestBottomSheet> createState() =>
      _ApplyMoneyRequestBottomSheetState();
}

class _ApplyMoneyRequestBottomSheetState
    extends State<ApplyMoneyRequestBottomSheet> {
  // Temporary state for adding expense line
  String? _selectedExpenseCategoryId;
  final TextEditingController _lineAmountController = TextEditingController();
  final TextEditingController _lineNoteController = TextEditingController();
  DateTime _lineDate = DateTime.now();
  File? _lineReceipt;

  @override
  void dispose() {
    _lineAmountController.dispose();
    _lineNoteController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _lineReceipt = File(picked.path);
        });
      }
    } catch (_) {}
  }

  void _addCurrentLine() {
    if (_selectedExpenseCategoryId == null) {
      Get.snackbar('Category Required', 'Please select an expense category.');
      return;
    }
    final amount = _lineAmountController.text.trim();
    if (amount.isEmpty || (double.tryParse(amount) ?? 0) <= 0) {
      Get.snackbar('Amount Required', 'Please enter a valid expense amount.');
      return;
    }

    final cat = widget.controller.expenseCategories.firstWhere(
      (c) => c.id == _selectedExpenseCategoryId,
      orElse: () => ExpenseCategoryModel(
          id: _selectedExpenseCategoryId!, name: 'Category'),
    );

    final dateStr =
        '${_lineDate.year}-${_lineDate.month.toString().padLeft(2, '0')}-${_lineDate.day.toString().padLeft(2, '0')}';

    widget.controller.addExpenseLine(
      categoryId: cat.id,
      categoryName: cat.name,
      spentOn: dateStr,
      amount: amount,
      note: _lineNoteController.text.trim(),
      receiptFile: _lineReceipt,
    );

    // Reset line fields
    _lineAmountController.clear();
    _lineNoteController.clear();
    setState(() {
      _lineReceipt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Money / Claim',
                      style: AppTextStyles.text18.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Select type, enter details and submit for approval',
                      style: AppTextStyles.text12.copyWith(
                        color: AppColors.subTextColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.subTextColor,
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.borderColor, height: 1.h),

          // Scrollable Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Obx(() {
                final types = widget.controller.requestTypes;
                final selectedType = widget.controller.selectedFormType.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Request Type Selector Chips
                    Text(
                      'REQUEST TYPE',
                      style: AppTextStyles.text10.copyWith(
                        color: AppColors.subTextColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    AppSpaces.vSpace8,
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: types.map((type) {
                        final isSelected = selectedType?.id == type.id;
                        return ChoiceChip(
                          label: Text(
                            type.name,
                            style: AppTextStyles.text12.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textColor,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          avatar: Icon(
                            type.icon,
                            size: 16.sp,
                            color: isSelected
                                ? Colors.white
                                : AppColors.subTextColor,
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.cardBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.borderColor,
                              width: 1.w,
                            ),
                          ),
                          onSelected: (_) {
                            widget.controller.selectedFormType.value = type;
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),

                    if (selectedType != null) ...[
                      AppSpaces.vSpace12,

                      // Policy Limits Hint Banner
                      if (selectedType.maxPerRequest != null ||
                          selectedType.maxInstalments != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16.sp,
                                color: AppColors.secondary,
                              ),
                              AppSpaces.hSpace8,
                              Expanded(
                                child: Text(
                                  'Limits: '
                                  '${selectedType.maxPerRequest != null ? "Max ${selectedType.maxPerRequest} • " : ""}'
                                  '${selectedType.maxInstalments != null ? "Max ${selectedType.maxInstalments} months" : ""}',
                                  style: AppTextStyles.text12.copyWith(
                                    color: AppColors.textColor,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      AppSpaces.vSpace14,

                      // Non-Line Types (Loan, Advance, Payment): Single Amount + Instalments
                      if (!selectedType.hasLines) ...[
                        Text(
                          'REQUESTED AMOUNT',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        AppSpaces.vSpace6,
                        CustomTextField(
                          controller: widget.controller.amountController,
                          hintText: 'e.g. 50000',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),

                        // Instalments for repayable types
                        if (selectedType.repayable) ...[
                          AppSpaces.vSpace14,
                          Text(
                            'NUMBER OF MONTHLY INSTALMENTS',
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          AppSpaces.vSpace6,
                          CustomTextField(
                            controller:
                                widget.controller.instalmentsController,
                            hintText:
                                'e.g. 6 (max ${selectedType.maxInstalments ?? 24})',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ],

                      // Line Types (Expense Claim): Dynamic Expense Lines
                      if (selectedType.hasLines) ...[
                        Text(
                          'ADD EXPENSE LINES',
                          style: AppTextStyles.text10.copyWith(
                            color: AppColors.subTextColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        AppSpaces.vSpace8,
                        _buildAddExpenseLineCard(),
                        AppSpaces.vSpace12,

                        // List of already added draft lines
                        if (widget.controller.draftExpenseLines.isNotEmpty) ...[
                          Text(
                            'DRAFT CLAIM LINES (${widget.controller.draftExpenseLines.length})',
                            style: AppTextStyles.text10.copyWith(
                              color: AppColors.subTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppSpaces.vSpace8,
                          ...widget.controller.draftExpenseLines
                              .asMap()
                              .entries
                              .map((entry) {
                            final idx = entry.key;
                            final line = entry.value;
                            return Container(
                              margin: EdgeInsets.only(bottom: 6.h),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                    color: AppColors.borderColor, width: 1.w),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${line.categoryName} • ${line.spentOn}',
                                        style: AppTextStyles.text12.copyWith(
                                          color: AppColors.textColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (line.note.isNotEmpty)
                                        Text(
                                          line.note,
                                          style: AppTextStyles.text10.copyWith(
                                            color: AppColors.subTextColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        line.amount,
                                        style: AppTextStyles.text14.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline,
                                            size: 18.sp,
                                            color: AppColors.error),
                                        onPressed: () => widget.controller
                                            .removeExpenseLine(idx),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],

                      AppSpaces.vSpace14,

                      // Reason Field
                      Text(
                        'PURPOSE / REASON',
                        style: AppTextStyles.text10.copyWith(
                          color: AppColors.subTextColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      AppSpaces.vSpace6,
                      CustomTextField(
                        controller: widget.controller.reasonController,
                        hintText: 'Brief explanation for management approval',
                        maxLines: 2,
                      ),
                    ],

                    AppSpaces.vSpace20,
                  ],
                );
              }),
            ),
          ),

          // Submit Action Button
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(color: AppColors.borderColor, width: 1.w),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Obx(() => CustomButton(
                    isGradient: true,
                    isLoading: widget.controller.isSubmitting.value,
                    text: 'Submit Request for Approval',
                    icon: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    onPressed: () async {
                      final success =
                          await widget.controller.submitRequest();
                      if (success) {
                        Get.back();
                      }
                    },
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExpenseLineCard() {
    final categories = widget.controller.expenseCategories;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category dropdown
          if (categories.isNotEmpty)
            DropdownButtonFormField<String>(
              initialValue: _selectedExpenseCategoryId ?? categories.first.id,
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: AppTextStyles.text12,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, style: AppTextStyles.text12),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedExpenseCategoryId = val;
                });
              },
            ),

          AppSpaces.vSpace8,

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _lineAmountController,
                  hintText: 'Amount',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              AppSpaces.hSpace8,
              // Date picker button
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _lineDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _lineDate = picked;
                    });
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border:
                        Border.all(color: AppColors.borderColor, width: 1.w),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14.sp, color: AppColors.secondary),
                      AppSpaces.hSpace4,
                      Text(
                        '${_lineDate.month}/${_lineDate.day}',
                        style: AppTextStyles.text12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          AppSpaces.vSpace8,

          CustomTextField(
            controller: _lineNoteController,
            hintText: 'Line note / item detail',
          ),

          AppSpaces.vSpace8,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Receipt attachment button
              InkWell(
                onTap: _pickReceiptImage,
                child: Row(
                  children: [
                    Icon(
                      _lineReceipt != null
                          ? Icons.check_circle_rounded
                          : Icons.attach_file_rounded,
                      size: 16.sp,
                      color: _lineReceipt != null
                          ? AppColors.success
                          : AppColors.secondary,
                    ),
                    AppSpaces.hSpace4,
                    Text(
                      _lineReceipt != null ? 'Receipt Attached' : 'Attach Receipt',
                      style: AppTextStyles.text12.copyWith(
                        color: _lineReceipt != null
                            ? AppColors.success
                            : AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                ),
                onPressed: _addCurrentLine,
                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                label: Text(
                  'Add Line',
                  style: AppTextStyles.text12.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
