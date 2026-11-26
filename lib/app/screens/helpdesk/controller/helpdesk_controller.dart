import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/custom_snackbar.dart';
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

  // Scroll Controller for ticket conversation chat
  final ScrollController chatScrollController = ScrollController();
  Timer? _chatPollingTimer;

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

  /// Whether current user has permission to handle, resolve, or assign tickets
  bool get canHandleTickets => AppPreferences.hasPermission(AppPermissions.helpdeskHandle);

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
    _chatPollingTimer?.cancel();
    _chatPollingTimer = null;
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    chatScrollController.dispose();
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
      scrollChatToBottom();
    }
  }

  /// Direct load by ID (used by deep linking or direct screen routing)
  Future<void> loadTicketById(String id) async {
    try {
      isDetailsLoading.value = true;
      final details = await repo.fetchTicketDetails(id);
      if (details != null) {
        selectedTicket.value = details;
        final index = tickets.indexWhere((t) => t.id == id);
        if (index != -1) {
          tickets[index] = details;
        }
      }
    } finally {
      isDetailsLoading.value = false;
      scrollChatToBottom();
    }
  }

  /// Automatically scrolls chat list to the newest message
  void scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatScrollController.hasClients) {
        chatScrollController.animateTo(
          chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Starts real-time periodic polling while the discussion view is active
  void startChatPolling(String ticketId) {
    _chatPollingTimer?.cancel();
    _chatPollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      syncTicketDetailsSilently(ticketId);
    });
  }

  /// Stops real-time polling when user leaves the chat view
  void stopChatPolling() {
    _chatPollingTimer?.cancel();
    _chatPollingTimer = null;
  }

  /// Silently checks for new incoming messages from HR without blocking UI
  Future<void> syncTicketDetailsSilently(String ticketId) async {
    if (isPostingMessage.value) return;

    try {
      final details = await repo.fetchTicketDetails(ticketId);
      if (details != null) {
        final currentCount = selectedTicket.value?.messages.length ?? 0;
        final hasNewMessages = details.messages.length > currentCount;
        selectedTicket.value = details;

        final index = tickets.indexWhere((t) => t.id == ticketId);
        if (index != -1) {
          tickets[index] = details;
        }

        if (hasNewMessages) {
          scrollChatToBottom();
          HapticFeedback.lightImpact();
        }
      }
    } catch (_) {
      // Silent catch during periodic background polling
    }
  }

  /// Submits a new ticket with form validation & auto-scroll/focus on error
  Future<bool> submitNewTicket() async {
    if (createFormKey.currentState != null &&
        !createFormKey.currentState!.validate()) {
      if (subjectController.text.trim().isEmpty ||
          subjectController.text.trim().length > 150) {
        final ctx = subjectFocusNode.context;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
        subjectFocusNode.requestFocus();
      } else if (descriptionController.text.trim().isEmpty ||
          descriptionController.text.trim().length > 5000) {
        final ctx = descriptionFocusNode.context;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
        descriptionFocusNode.requestFocus();
      }
      return false;
    }

    if (subjectController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      return false;
    }

    final catId = selectedCategoryId.value;
    if (catId == null || catId.isEmpty) {
      CustomSnackbar.showError(
        title: 'Category Required',
        message: 'Please select a category for your ticket.',
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
        CustomSnackbar.showSuccess(
          title: 'Ticket Created',
          message:
              'Ticket #${created.reference} has been submitted to the HR Helpdesk.',
        );
        return true;
      }
      return false;
    } finally {
      isCreatingTicket.value = false;
    }
  }

  /// Submits a reply message on active ticket with immediate Optimistic UI update
  Future<bool> sendReplyMessage() async {
    final ticket = selectedTicket.value;
    if (ticket == null) return false;

    final body = messageController.text.trim();
    if (body.isEmpty) return false;

    // 1. Optimistic UI update: Immediately append message to chat
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    String currentUserName = 'Me';
    try {
      currentUserName = AppPreferences.getUser()?.name ?? 'Me';
    } catch (_) {}
    final optimisticMessage = HelpdeskMessageModel(
      id: tempId,
      author: currentUserName,
      fromRaiser: true,
      body: body,
      createdAt: DateTime.now().toIso8601String(),
    );

    final previousTicket = ticket;
    final updatedMessages = List<HelpdeskMessageModel>.from(ticket.messages)..add(optimisticMessage);
    final optimisticTicket = ticket.copyWith(
      messages: updatedMessages,
      lastActivityAt: optimisticMessage.createdAt,
      status: ticket.isResolved ? 'open' : ticket.status,
      statusLabel: ticket.isResolved ? 'Open' : ticket.statusLabel,
    );

    selectedTicket.value = optimisticTicket;
    final ticketIndex = tickets.indexWhere((t) => t.id == ticket.id);
    if (ticketIndex != -1) {
      tickets[ticketIndex] = optimisticTicket;
    }

    messageController.clear();
    scrollChatToBottom();
    HapticFeedback.lightImpact();

    try {
      isPostingMessage.value = true;
      final serverMessage = await repo.postMessage(
        ticketId: ticket.id,
        body: body,
      );

      // 2. Fetch authoritative ticket state from server to guarantee synchronization
      final freshTicket = await repo.fetchTicketDetails(ticket.id);
      if (freshTicket != null) {
        selectedTicket.value = freshTicket;
        final idx = tickets.indexWhere((t) => t.id == ticket.id);
        if (idx != -1) {
          tickets[idx] = freshTicket;
        }
      } else if (serverMessage != null) {
        final syncedMessages = List<HelpdeskMessageModel>.from(previousTicket.messages)..add(serverMessage);
        final syncedTicket = previousTicket.copyWith(messages: syncedMessages);
        selectedTicket.value = syncedTicket;
        if (ticketIndex != -1) {
          tickets[ticketIndex] = syncedTicket;
        }
      }
      scrollChatToBottom();
      return true;
    } catch (e) {
      // Revert optimistic update on network error
      selectedTicket.value = previousTicket;
      if (ticketIndex != -1) {
        tickets[ticketIndex] = previousTicket;
      }
      messageController.text = body;
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
