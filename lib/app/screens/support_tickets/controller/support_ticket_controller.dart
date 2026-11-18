import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../api/app_preferences.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../model/support_ticket_model.dart';
import '../repo/support_ticket_repo.dart';

/// GetX Controller for Support Tickets & Helpdesk (Phase 10)
/// Strictly adheres to .agents/rules/ams.md:
/// - Resource disposal in onClose()
/// - try-finally wrapped async loading & double-tap prevention
/// - Permission checks (support.view and support.raise)
class SupportTicketController extends GetxController {
  final SupportTicketRepo repo;

  SupportTicketController({required this.repo});

  // Permission Observables
  final isForbidden = false.obs;
  final forbiddenMessage = ''.obs;

  bool get canView => AppPreferences.hasPermission('support.view');
  bool get canRaise => AppPreferences.hasPermission('support.raise');

  // Main Section Tab: 0 = Support Tickets, 1 = Training Videos
  final selectedMainTab = 0.obs;

  // Training Videos
  final trainingVideos = <TrainingVideoModel>[].obs;
  final isLoadingVideos = false.obs;

  // Fetched Completion Flags (Prevents redundant API spam on empty lists)
  final hasLoadedActiveTickets = false.obs;
  final hasLoadedFinishedTickets = false.obs;
  final hasLoadedTrainingVideos = false.obs;

  // Loading States
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isReplying = false.obs;
  final isChangingStatus = false.obs;
  final isDownloadingFile = false.obs;
  final downloadingFileId = ''.obs;

  // Filter: false = Active/Open Tickets, true = Finished/Resolved Tickets
  final showFinished = false.obs;

  // Dedicated ticket lists to prevent cross-tab stale item flicker
  final activeTickets = <SupportTicketItemModel>[].obs;
  final finishedTickets = <SupportTicketItemModel>[].obs;

  // Active view getter for UI convenience
  List<SupportTicketItemModel> get currentTickets =>
      showFinished.value ? finishedTickets : activeTickets;

  final selectedTicket = Rxn<SupportTicketDetailsModel>();
  final isLoadingThread = false.obs;

  // Text Controllers
  final subjectController = TextEditingController();
  final bodyController = TextEditingController();
  final replyController = TextEditingController();

  // Scroll Controllers
  final scrollController = ScrollController();
  final threadScrollController = ScrollController();

  // New Ticket Form State
  final selectedCategory = 'technical'.obs;
  final selectedPriority = 'normal'.obs;
  final newTicketAttachments = <File>[].obs;
  final replyAttachments = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    checkPermissionsAndLoad();
  }

  @override
  void onClose() {
    subjectController.dispose();
    bodyController.dispose();
    replyController.dispose();
    scrollController.dispose();
    threadScrollController.dispose();
    super.onClose();
  }

  /// Initial Permission-Driven Gate:
  /// Strictly loads ONLY the active tab to prevent unnecessary parallel API calls
  void checkPermissionsAndLoad() {
    if (!canView) {
      isForbidden.value = true;
      forbiddenMessage.value =
          'You do not have permission to view support tickets. Please contact your organization administrator.';
      selectedMainTab.value = 1; // Default to Training Videos if tickets are restricted
      loadTrainingVideos(); // Load ONLY training videos
      return;
    }
    isForbidden.value = false;
    selectedMainTab.value = 0;
    loadTickets(); // Load ONLY active tickets for Tab 0
  }

  /// Switch main view between Support Tickets and Training Videos
  /// Lazy loads only when the tab has not been fetched yet
  void setMainTab(int index) {
    if (selectedMainTab.value == index) return;
    selectedMainTab.value = index;

    if (index == 0) {
      final alreadyLoaded = showFinished.value
          ? hasLoadedFinishedTickets.value
          : hasLoadedActiveTickets.value;
      if (!alreadyLoaded && !isLoading.value) {
        loadTickets();
      }
    } else if (index == 1) {
      if (!hasLoadedTrainingVideos.value && !isLoadingVideos.value) {
        loadTrainingVideos();
      }
    }
  }

  /// Loads AMS Training Videos (GET /support/training-videos)
  Future<void> loadTrainingVideos({bool isRefresh = false}) async {
    try {
      isLoadingVideos.value = true;
      final results = await repo.fetchTrainingVideos();
      trainingVideos.assignAll(results);
      hasLoadedTrainingVideos.value = true;
    } finally {
      isLoadingVideos.value = false;
    }
  }

  /// Opens video in YouTube app or external browser
  Future<void> openTrainingVideo(TrainingVideoModel video) async {
    final url = video.watchUrl.isNotEmpty ? video.watchUrl : video.embedUrl;
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackbar.showError(
          title: 'Playback Error',
          message: 'Unable to open video URL.',
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Playback Error',
        message: 'Could not open video: $e',
      );
    }
  }

  /// Loads tickets list with active/finished filter
  Future<void> loadTickets({bool isRefresh = false}) async {
    if (!canView) return;

    final targetFinished = showFinished.value;
    try {
      isLoading.value = true;
      final results = await repo.fetchTickets(
        finished: targetFinished,
        page: 1,
        perPage: 25,
      );
      if (targetFinished) {
        finishedTickets.assignAll(results);
        hasLoadedFinishedTickets.value = true;
      } else {
        activeTickets.assignAll(results);
        hasLoadedActiveTickets.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Switch filter between Active and Finished tickets
  /// Uses cached results if already fetched without re-firing API
  void setFilter(bool finished) {
    if (showFinished.value == finished) return;
    showFinished.value = finished;

    final alreadyLoaded = finished
        ? hasLoadedFinishedTickets.value
        : hasLoadedActiveTickets.value;
    if (!alreadyLoaded && !isLoading.value) {
      loadTickets();
    }
  }

  /// Loads full discussion thread and opens bottom sheet
  Future<bool> openTicketThread(String ticketId) async {
    if (isLoadingThread.value) return false;
    try {
      isLoadingThread.value = true;
      final details = await repo.fetchTicketDetails(ticketId);
      if (details != null) {
        selectedTicket.value = details;
        return true;
      }
      return false;
    } finally {
      isLoadingThread.value = false;
    }
  }

  /// Creates a new support ticket
  Future<bool> submitNewTicket() async {
    if (!canRaise) {
      CustomSnackbar.showError(
        message: 'You do not have permission to raise support tickets.',
      );
      return false;
    }

    final subject = subjectController.text.trim();
    final body = bodyController.text.trim();

    if (subject.isEmpty) {
      CustomSnackbar.showError(message: 'Please enter a ticket subject.');
      return false;
    }

    if (body.length < 2) {
      CustomSnackbar.showError(
        message: 'Please provide at least 2 characters describing your issue.',
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      final created = await repo.createTicket(
        subject: subject,
        body: body,
        category: selectedCategory.value,
        priority: selectedPriority.value,
        attachments: newTicketAttachments.isNotEmpty
            ? List<File>.from(newTicketAttachments)
            : null,
      );

      if (created != null) {
        // Reset form
        subjectController.clear();
        bodyController.clear();
        newTicketAttachments.clear();
        selectedCategory.value = 'technical';
        selectedPriority.value = 'normal';

        // Auto close bottom sheet if open
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }

        CustomSnackbar.showSuccess(
          message: 'Support ticket #${created.number} submitted successfully.',
        );

        // Refresh tickets
        await loadTickets(isRefresh: true);
        return true;
      }
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Sends reply message on the open ticket thread
  Future<bool> sendReply() async {
    if (!canRaise) {
      CustomSnackbar.showError(
        message: 'You do not have permission to reply to support tickets.',
      );
      return false;
    }

    final ticket = selectedTicket.value;
    if (ticket == null) return false;

    final body = replyController.text.trim();
    if (body.isEmpty) {
      CustomSnackbar.showError(message: 'Please write a message to reply.');
      return false;
    }

    try {
      isReplying.value = true;
      final updated = await repo.replyTicket(
        ticket.id,
        body: body,
        attachments: replyAttachments.isNotEmpty
            ? List<File>.from(replyAttachments)
            : null,
      );

      if (updated != null) {
        selectedTicket.value = updated;
        replyController.clear();
        replyAttachments.clear();

        // Scroll thread to bottom
        if (threadScrollController.hasClients) {
          threadScrollController.animateTo(
            threadScrollController.position.maxScrollExtent + 120,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }

        // Refresh background tickets list
        loadTickets(isRefresh: true);
        return true;
      }
      return false;
    } finally {
      isReplying.value = false;
    }
  }

  /// Closes an active ticket
  Future<void> closeTicket() async {
    final ticket = selectedTicket.value;
    if (ticket == null) return;

    try {
      isChangingStatus.value = true;
      final updated = await repo.closeTicket(ticket.id);
      if (updated != null) {
        selectedTicket.value = updated;
        CustomSnackbar.showSuccess(
          message: 'Ticket #${ticket.number} has been closed.',
        );
        loadTickets(isRefresh: true);
      }
    } finally {
      isChangingStatus.value = false;
    }
  }

  /// Reopens a resolved ticket
  Future<void> reopenTicket() async {
    final ticket = selectedTicket.value;
    if (ticket == null) return;

    try {
      isChangingStatus.value = true;
      final updated = await repo.reopenTicket(ticket.id);
      if (updated != null) {
        selectedTicket.value = updated;
        CustomSnackbar.showSuccess(
          message: 'Ticket #${ticket.number} has been reopened.',
        );
        loadTickets(isRefresh: true);
      }
    } finally {
      isChangingStatus.value = false;
    }
  }

  /// Downloads and opens an attachment file
  Future<void> openAttachment(SupportAttachmentModel attachment) async {
    final ticket = selectedTicket.value;
    if (ticket == null) return;

    try {
      isDownloadingFile.value = true;
      downloadingFileId.value = attachment.id;

      final file = await repo.downloadAttachment(
        ticket.id,
        attachment.id,
        attachment.name,
      );

      if (file != null && await file.exists()) {
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          CustomSnackbar.showInfo(
            message: 'File downloaded: ${attachment.name}',
          );
        }
      } else {
        CustomSnackbar.showError(
          message: 'Unable to open attachment. Please try again.',
        );
      }
    } catch (_) {
      CustomSnackbar.showError(message: 'Failed to download attachment file.');
    } finally {
      isDownloadingFile.value = false;
      downloadingFileId.value = '';
    }
  }

  // Attachment Picker Helpers
  void addNewTicketAttachment(File file) {
    if (newTicketAttachments.length >= 5) {
      CustomSnackbar.showError(
        message: 'You can attach up to 5 files per ticket.',
      );
      return;
    }
    newTicketAttachments.add(file);
  }

  void removeNewTicketAttachment(int index) {
    if (index >= 0 && index < newTicketAttachments.length) {
      newTicketAttachments.removeAt(index);
    }
  }

  void addReplyAttachment(File file) {
    if (replyAttachments.length >= 5) {
      CustomSnackbar.showError(
        message: 'You can attach up to 5 files per reply.',
      );
      return;
    }
    replyAttachments.add(file);
  }

  void removeReplyAttachment(int index) {
    if (index >= 0 && index < replyAttachments.length) {
      replyAttachments.removeAt(index);
    }
  }
}
