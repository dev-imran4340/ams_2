import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_colors.dart';
import '../model/helpdesk_model.dart';
import '../repo/helpdesk_repo.dart';

class HelpdeskController extends GetxController {
  final HelpdeskRepo repo;

  HelpdeskController({required this.repo});

  // State Observables
  final RxBool isLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxBool isCreatingTicket = false.obs;
  final RxBool isPostingMessage = false.obs;
  final RxBool isCancelling = false.obs;

  /// Active filter: 'all', 'open', 'in_progress', 'resolved'
  final RxString selectedFilter = 'all'.obs;
  final RxString selectedCategoryFilter = 'All'.obs;

  final RxList<HelpdeskTicketModel> tickets = <HelpdeskTicketModel>[].obs;
  final RxList<HelpdeskCategoryModel> categories = <HelpdeskCategoryModel>[].obs;
  final Rxn<HelpdeskTicketModel> selectedTicket = Rxn<HelpdeskTicketModel>();

  // Scroll Controller for dynamic background contrast adaptation
  final ScrollController scrollController = ScrollController();
  final RxDouble scrollOffset = 0.0.obs;

  // New Ticket Form
  final GlobalKey<FormState> createFormKey = GlobalKey<FormState>();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode subjectFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final RxnString selectedCategoryId = RxnString();
  final RxString selectedPriority = 'normal'.obs;
  final RxBool isConfidential = false.obs;

  // Reply Message Form
  final GlobalKey<FormState> replyFormKey = GlobalKey<FormState>();
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();

  // Telemetry Counts
  int get totalCount => tickets.length;
  int get openCount => tickets.where((t) => t.isOpen).length;
  int get inProgressCount => tickets.where((t) => t.isInProgress || t.isWaitingOnUser).length;
  int get resolvedCount => tickets.where((t) => t.isResolved || t.isClosed).length;

  /// Filtered tickets list based on telemetry strip and category filter
  List<HelpdeskTicketModel> get filteredTickets {
    var list = tickets.toList();

    // 1. Status Filter
    switch (selectedFilter.value.toLowerCase()) {
      case 'open':
        list = list.where((t) => t.isOpen).toList();
        break;
      case 'in_progress':
        list = list.where((t) => t.isInProgress || t.isWaitingOnUser).toList();
        break;
      case 'resolved':
        list = list.where((t) => t.isResolved || t.isClosed).toList();
        break;
      case 'all':
      default:
        break;
    }

    // 2. Category Filter
    if (selectedCategoryFilter.value != 'All') {
      list = list.where((t) => t.category == selectedCategoryFilter.value).toList();
    }

    return list;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadInitialData();
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      scrollOffset.value = scrollController.offset;
    }
  }

  /// Mandatory Resource Disposal (.agents/rules/ams.md)
  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    messageController.dispose();
    subjectFocusNode.dispose();
    descriptionFocusNode.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }

  /// Loads tickets and categories concurrently
  Future<void> loadInitialData({bool isRefresh = false}) async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        repo.fetchTickets(),
        repo.fetchCategories(),
      ]);

      final ticketList = results[0] as List<HelpdeskTicketModel>?;
      final catList = results[1] as List<HelpdeskCategoryModel>?;

      if (ticketList != null) {
        tickets.assignAll(ticketList);
      }
      if (catList != null) {
        categories.assignAll(catList);
        if (categories.isNotEmpty && selectedCategoryId.value == null) {
          selectedCategoryId.value = categories.first.id;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Sets telemetry status filter
  void setFilter(String filter) {
    if (selectedFilter.value == filter) return;
    HapticFeedback.selectionClick();
    selectedFilter.value = filter;
  }

  /// Sets category chip filter
  void setCategoryFilter(String category) {
    if (selectedCategoryFilter.value == category) return;
    HapticFeedback.selectionClick();
    selectedCategoryFilter.value = category;
  }

  /// Loads full ticket details including message thread
  Future<void> openTicketDetails(HelpdeskTicketModel ticket) async {
    HapticFeedback.lightImpact();
    selectedTicket.value = ticket;
    try {
      isDetailsLoading.value = true;
      final details = await repo.fetchTicketDetails(ticket.id);
      if (details != null) {
        selectedTicket.value = details;
        final index = tickets.indexWhere((t) => t.id == ticket.id);
        if (index != -1) {
          tickets[index] = details;
        }
      }
    } finally {
      isDetailsLoading.value = false;
    }
  }

  /// Submits a new ticket with form validation
  Future<bool> submitNewTicket() async {
    if (createFormKey.currentState != null && !createFormKey.currentState!.validate()) {
      if (subjectController.text.trim().isEmpty) {
        subjectFocusNode.requestFocus();
      } else if (descriptionController.text.trim().isEmpty) {
        descriptionFocusNode.requestFocus();
      }
      return false;
    }

    if (subjectController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
      return false;
    }

    final catId = selectedCategoryId.value;
    if (catId == null) {
      Get.snackbar(
        'Category Required',
        'Please select a category for your ticket.',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
      return false;
    }

    try {
      isCreatingTicket.value = true;
      final created = await repo.createTicket(
        categoryId: catId,
        subject: subjectController.text.trim(),
        message: descriptionController.text.trim(),
        priority: selectedPriority.value,
        isConfidential: isConfidential.value,
      );

      if (created != null) {
        tickets.insert(0, created);
        subjectController.clear();
        descriptionController.clear();
        isConfidential.value = false;
        selectedPriority.value = 'normal';
        HapticFeedback.heavyImpact();
        if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
          Get.back(); // Close modal
        }
        if (Get.context != null) {
          Get.snackbar(
            'Ticket Created',
            'Ticket #${created.reference} has been submitted to the HR Helpdesk.',
            backgroundColor: AppColors.success.withValues(alpha: 0.1),
            colorText: AppColors.success,
          );
        }
        return true;
      }
      return false;
    } finally {
      isCreatingTicket.value = false;
    }
  }

  /// Submits a reply message on active ticket
  Future<bool> sendReplyMessage() async {
    final ticket = selectedTicket.value;
    if (ticket == null) return false;

    final body = messageController.text.trim();
    if (body.isEmpty) return false;

    try {
      isPostingMessage.value = true;
      final message = await repo.postMessage(
        ticketId: ticket.id,
        body: body,
      );

      if (message != null) {
        messageController.clear();
        final updatedMessages = List<HelpdeskMessageModel>.from(ticket.messages)..add(message);
        final updatedTicket = HelpdeskTicketModel(
          id: ticket.id,
          reference: ticket.reference,
          subject: ticket.subject,
          category: ticket.category,
          isConfidential: ticket.isConfidential,
          status: ticket.status,
          statusLabel: ticket.statusLabel,
          statusTone: ticket.statusTone,
          priority: ticket.priority,
          raisedByName: ticket.raisedByName,
          assigneeName: ticket.assigneeName,
          createdAt: ticket.createdAt,
          lastActivityAt: message.createdAt,
          resolvedAt: ticket.resolvedAt,
          messages: updatedMessages,
        );
        selectedTicket.value = updatedTicket;
        final index = tickets.indexWhere((t) => t.id == ticket.id);
        if (index != -1) {
          tickets[index] = updatedTicket;
        }
        HapticFeedback.lightImpact();
        return true;
      }
      return false;
    } finally {
      isPostingMessage.value = false;
    }
  }

  /// Cancels an open ticket
  Future<void> cancelTicket(String ticketId) async {
    try {
      isCancelling.value = true;
      final success = await repo.cancelTicket(ticketId);
      if (success) {
        HapticFeedback.mediumImpact();
        if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
          Get.back(); // Close details sheet if open
        }
        await loadInitialData();
        if (Get.context != null) {
          Get.snackbar(
            'Ticket Cancelled',
            'The ticket has been successfully cancelled.',
            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
            colorText: AppColors.secondary,
          );
        }
      }
    } finally {
      isCancelling.value = false;
    }
  }
}
