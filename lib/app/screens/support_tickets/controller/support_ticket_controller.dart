import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

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

  // Loading States
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isReplying = false.obs;
  final isChangingStatus = false.obs;
  final isDownloadingFile = false.obs;
  final downloadingFileId = ''.obs;

  // Filter: false = Active/Open Tickets, true = Finished/Resolved Tickets
  final showFinished = false.obs;

  // Lists & Selected Thread
  final tickets = <SupportTicketItemModel>[].obs;
  final selectedTicket = Rxn<SupportTicketDetailsModel>();

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

  /// Initial Permission-Driven Gate
  void checkPermissionsAndLoad() {
    if (!canView) {
      isForbidden.value = true;
      forbiddenMessage.value =
          'You do not have permission to view support tickets. Please contact your organization administrator.';
      return;
    }
    isForbidden.value = false;
    loadTickets();
  }

  /// Loads tickets list with active/finished filter
  Future<void> loadTickets({bool isRefresh = false}) async {
    if (!canView) return;

    try {
      if (!isRefresh) isLoading.value = true;
      final results = await repo.fetchTickets(
        finished: showFinished.value,
        page: 1,
        perPage: 25,
      );
      tickets.assignAll(results);
    } finally {
      isLoading.value = false;
    }
  }

  /// Switch filter between Active and Finished tickets
  void setFilter(bool finished) {
    if (showFinished.value == finished) return;
    showFinished.value = finished;
    loadTickets();
  }

  /// Loads full discussion thread and opens bottom sheet
  Future<void> openTicketThread(String ticketId) async {
    try {
      isLoading.value = true;
      final details = await repo.fetchTicketDetails(ticketId);
      if (details != null) {
        selectedTicket.value = details;
      }
    } finally {
      isLoading.value = false;
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
