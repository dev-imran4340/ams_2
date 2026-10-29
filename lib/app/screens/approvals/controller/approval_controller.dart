import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../index/controller/index_controller.dart';
import '../model/approval_model.dart';
import '../repo/approval_repo.dart';
import '../view/components/approval_details_bottom_sheet.dart';

class ApprovalController extends GetxController {
  final ApprovalRepo repo;

  ApprovalController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isActionLoading = false.obs;

  /// Active Approvals Box filter ('waiting', 'mine', 'pending', 'decided')
  final RxString selectedBox = 'waiting'.obs;

  // Collections
  final RxList<ApprovalItemModel> approvalsList = <ApprovalItemModel>[].obs;
  final Rxn<ApprovalItemModel> selectedApproval = Rxn<ApprovalItemModel>();

  // Text and Focus Controllers for Reject / Action Comments
  final TextEditingController actionCommentController = TextEditingController();
  final FocusNode actionCommentFocusNode = FocusNode();

  // Reactive Validation Observable for Rejection Dialog
  final RxnString rejectionError = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['box'] != null) {
        selectedBox.value = args['box'].toString();
      }
      if (args['openId'] != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openApprovalDetailsById(args['openId'].toString());
        });
      }
    }
    fetchApprovals();
  }

  /// Switches active approvals box filter tab
  Future<void> changeBox(String box) async {
    if (selectedBox.value == box) return;
    HapticFeedback.selectionClick();
    selectedBox.value = box;
    await fetchApprovals();
  }

  /// Fetches approvals list for the currently selected box (API 6.1)
  Future<void> fetchApprovals() async {
    try {
      isLoading.value = true;
      final list = await repo.fetchApprovalsBox(box: selectedBox.value);
      approvalsList.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens the detailed audit view bottom sheet for a request (GET /approvals/{id})
  Future<void> openApprovalDetails(BuildContext context, ApprovalItemModel item) async {
    HapticFeedback.lightImpact();
    selectedApproval.value = item;
    isLoadingDetails.value = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withValues(alpha: 0.6),
      builder: (ctx) => const ApprovalDetailsBottomSheet(),
    );

    try {
      final detailed = await repo.fetchApprovalDetails(item.id);
      if (detailed != null) {
        selectedApproval.value = detailed;
      }
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Opens the detailed audit view bottom sheet directly by opaque ULID
  Future<void> openApprovalDetailsById(String id) async {
    HapticFeedback.lightImpact();

    final existing = approvalsList.firstWhereOrNull((e) => e.id == id);
    if (existing != null) {
      selectedApproval.value = existing;
    } else {
      selectedApproval.value = ApprovalItemModel(
        id: id,
        type: 'request',
        typeLabel: 'Request',
        title: 'Review Request',
        requestedBy: 'Employee',
        status: 'pending',
        statusLabel: 'Pending',
        statusTone: 'amber',
        submittedAgo: 'Just now',
      );
    }

    isLoadingDetails.value = true;
    final context = Get.context;
    if (context != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: AppColors.primary.withValues(alpha: 0.6),
        builder: (ctx) => const ApprovalDetailsBottomSheet(),
      );
    }

    try {
      final detailed = await repo.fetchApprovalDetails(id);
      if (detailed != null) {
        selectedApproval.value = detailed;
      }
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Retries fetching full audit details if previous attempt failed
  Future<void> reloadApprovalDetails(String id) async {
    try {
      isLoadingDetails.value = true;
      final detailed = await repo.fetchApprovalDetails(id);
      if (detailed != null) {
        selectedApproval.value = detailed;
      }
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Confirms and processes request approval (POST /approvals/{id}/approve)
  Future<void> approveRequest(String id, {String? comment}) async {
    if (isActionLoading.value) return;

    try {
      isActionLoading.value = true;
      HapticFeedback.mediumImpact();

      final updated = await repo.approveRequest(id, comment: comment);
      if (updated != null) {
        final index = approvalsList.indexWhere((e) => e.id == id);
        if (index != -1) {
          approvalsList[index] = updated;
        }
        selectedApproval.value = updated;

        _refreshMeBadge();

        CustomSnackbar.showSuccess(
          title: 'Request Approved',
          message: 'Approval has been registered successfully.',
        );

        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        await fetchApprovals();
      } else {
        CustomSnackbar.showError(
          title: 'Approval Failed',
          message: 'Unable to approve request. Please check permissions.',
        );
      }
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Confirms and processes request rejection (POST /approvals/{id}/reject)
  Future<void> rejectRequest(String id, {required String comment}) async {
    if (isActionLoading.value) return;

    final trimmed = comment.trim();
    if (trimmed.isEmpty) {
      rejectionError.value = 'Rejection reason is mandatory.';
      actionCommentFocusNode.requestFocus();
      return;
    }
    if (trimmed.length < 5) {
      rejectionError.value = 'Reason must be at least 5 characters long.';
      actionCommentFocusNode.requestFocus();
      return;
    }
    if (trimmed.length > 1000) {
      rejectionError.value = 'Reason cannot exceed 1000 characters.';
      actionCommentFocusNode.requestFocus();
      return;
    }

    try {
      isActionLoading.value = true;
      HapticFeedback.mediumImpact();

      final updated = await repo.rejectRequest(id, comment: trimmed);
      if (updated != null) {
        final index = approvalsList.indexWhere((e) => e.id == id);
        if (index != -1) {
          approvalsList[index] = updated;
        }
        selectedApproval.value = updated;

        _refreshMeBadge();

        CustomSnackbar.showSuccess(
          title: 'Request Rejected',
          message: 'The request has been rejected and the employee has been notified.',
        );

        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        await fetchApprovals();
      } else {
        CustomSnackbar.showError(
          title: 'Rejection Failed',
          message: 'Unable to reject request. Please check permissions.',
        );
      }
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Cancels an in-progress request submitted by this user (POST /approvals/{id}/cancel)
  Future<void> cancelRequest(String id) async {
    if (isActionLoading.value) return;

    try {
      isActionLoading.value = true;
      HapticFeedback.mediumImpact();

      final updated = await repo.cancelRequest(id);
      if (updated != null) {
        final index = approvalsList.indexWhere((e) => e.id == id);
        if (index != -1) {
          approvalsList[index] = updated;
        }
        selectedApproval.value = updated;

        _refreshMeBadge();

        CustomSnackbar.showSuccess(
          title: 'Request Cancelled',
          message: 'Your request has been withdrawn.',
        );

        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        await fetchApprovals();
      } else {
        CustomSnackbar.showError(
          title: 'Cancellation Failed',
          message: 'Unable to cancel this request.',
        );
      }
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Signals IndexController to re-fetch badges from /me
  void _refreshMeBadge() {
    if (Get.isRegistered<IndexController>()) {
      Get.find<IndexController>().fetchMe();
    }
  }

  @override
  void onClose() {
    actionCommentController.dispose();
    actionCommentFocusNode.dispose();
    super.onClose();
  }
}
