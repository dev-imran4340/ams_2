import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../services/notification_payload_handler.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../model/notification_item_model.dart';
import '../model/notification_preferences_model.dart';
import '../repo/notification_repo.dart';

/// GetX Controller managing in-app notifications and notification preferences.
/// Strictly enforces AMS 2 MVVM rules and zero memory leaks.
class NotificationController extends GetxController {
  final NotificationRepo repo;

  NotificationController({required this.repo});

  // Observables for In-App Notifications
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isMarkingAllRead = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  final RxList<NotificationItemModel> notifications = <NotificationItemModel>[].obs;
  final RxInt unreadCount = 0.obs;

  /// Filter: 'all' or 'unread'
  final RxString selectedFilter = 'all'.obs;

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;

  // Observables for Notification Preferences
  final RxBool isLoadingPreferences = false.obs;
  final RxBool isUpdatingPreference = false.obs;
  final Rxn<NotificationPreferencesModel> preferences = Rxn<NotificationPreferencesModel>();

  // Scroll Controller for pagination
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);

    loadNotifications();
    loadPreferences();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  /// Listens to scroll events for seamless infinite scroll pagination
  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200.0) {
      if (!isLoadingMore.value && hasMore.value && !isLoading.value) {
        loadMoreNotifications();
      }
    }
  }

  /// Fetches initial or refreshed notification list (GET /notifications)
  Future<void> loadNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      currentPage.value = 1;
      final response = await repo.fetchNotifications(
        page: 1,
        perPage: 25,
        unreadOnly: selectedFilter.value == 'unread',
      );

      if (response != null) {
        notifications.assignAll(response.data);
        unreadCount.value = response.meta.unread;
        currentPage.value = response.meta.page;
        lastPage.value = response.meta.lastPage;
        hasMore.value = response.meta.page < response.meta.lastPage;
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Loads next page of notifications
  Future<void> loadMoreNotifications() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      final nextPage = currentPage.value + 1;

      final response = await repo.fetchNotifications(
        page: nextPage,
        perPage: 25,
        unreadOnly: selectedFilter.value == 'unread',
      );

      if (response != null) {
        notifications.addAll(response.data);
        currentPage.value = response.meta.page;
        lastPage.value = response.meta.lastPage;
        hasMore.value = response.meta.page < response.meta.lastPage;
        unreadCount.value = response.meta.unread;
      } else {
        hasMore.value = false;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Switches filter between 'all' and 'unread'
  void changeFilter(String filter) {
    if (selectedFilter.value == filter) return;
    HapticFeedback.selectionClick();
    selectedFilter.value = filter;
    loadNotifications();
  }

  /// Handles user tapping a notification:
  /// 1. Marks as read immediately if unread (POST /notifications/{id}/read)
  /// 2. Dispatches navigation via NotificationPayloadHandler
  Future<void> onNotificationTap(NotificationItemModel item) async {
    HapticFeedback.lightImpact();

    // Optimistically mark as read in local list
    if (!item.read) {
      final index = notifications.indexWhere((n) => n.id == item.id);
      if (index != -1) {
        notifications[index] = item.copyWith(read: true);
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
      }
      // Fire and forget API call to server
      repo.markAsRead(item.id);
    }

    // Route according to target and screen specifications
    await NotificationPayloadHandler.handleTarget(
      screen: item.target.screen,
      id: item.target.id,
      link: item.link,
      origin: 'InAppNotificationTap',
    );
  }

  /// Marks a specific notification as read manually
  Future<void> markAsRead(NotificationItemModel item) async {
    if (item.read) return;

    final index = notifications.indexWhere((n) => n.id == item.id);
    if (index != -1) {
      notifications[index] = item.copyWith(read: true);
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
    }

    final success = await repo.markAsRead(item.id);
    if (!success) {
      // Revert if server failed
      if (index != -1) {
        notifications[index] = item.copyWith(read: false);
        unreadCount.value++;
      }
    }
  }

  /// Marks all notifications as read (POST /notifications/read-all)
  Future<void> markAllAsRead() async {
    if (isMarkingAllRead.value || unreadCount.value == 0) return;

    try {
      isMarkingAllRead.value = true;
      HapticFeedback.mediumImpact();

      final success = await repo.markAllAsRead();
      if (success) {
        // Mark all items as read locally
        final updated = notifications.map((n) => n.copyWith(read: true)).toList();
        notifications.assignAll(updated);
        unreadCount.value = 0;

        CustomSnackbar.showSuccess(
          title: 'All Caught Up',
          message: 'All notifications have been marked as read.',
        );

        if (selectedFilter.value == 'unread') {
          notifications.clear();
        }
      } else {
        CustomSnackbar.showError(
          title: 'Action Failed',
          message: 'Unable to mark all notifications as read. Please retry.',
        );
      }
    } finally {
      isMarkingAllRead.value = false;
    }
  }

  /// Hook called by PushNotificationService when a new foreground push is received
  void onPushReceived() {
    unreadCount.value++;
    // Silently refresh current view without blocking UI
    loadNotifications(isRefresh: true);
  }

  // --- Notification Preferences Logic ---

  /// Fetches user preferences from GET /me/notification-preferences
  Future<void> loadPreferences() async {
    try {
      isLoadingPreferences.value = true;
      final data = await repo.fetchPreferences();
      if (data != null) {
        preferences.value = data;
      }
    } finally {
      isLoadingPreferences.value = false;
    }
  }

  /// Toggles an individual notification channel for a specific kind
  /// Server rule: "bell" cannot be switched off (422 error if attempted).
  Future<void> togglePreferenceChannel({
    required String kind,
    required String channel,
    required bool newValue,
  }) async {
    if (channel == 'bell') {
      CustomSnackbar.showError(
        title: 'Mandatory Channel',
        message: 'In-app bell notifications cannot be turned off as per corporate policy.',
      );
      return;
    }

    if (isUpdatingPreference.value) return;

    final currentPrefs = preferences.value;
    if (currentPrefs == null) return;

    try {
      isUpdatingPreference.value = true;
      HapticFeedback.lightImpact();

      // Optimistic update
      final kindPref = currentPrefs.getForKind(kind);
      ChannelPreferenceModel updatedKindPref;
      if (channel == 'push') {
        updatedKindPref = kindPref.copyWith(push: newValue);
      } else if (channel == 'mail') {
        updatedKindPref = kindPref.copyWith(mail: newValue);
      } else {
        return;
      }

      // Update local observable model dynamically
      final updatedModel = currentPrefs.copyWithCategory(kind, updatedKindPref);
      preferences.value = updatedModel;

      // Send only changed channel to backend
      final changedChannels = {channel: newValue};
      final serverUpdated = await repo.updatePreferences(
        kind: kind,
        changedChannels: changedChannels,
      );

      if (serverUpdated != null) {
        preferences.value = serverUpdated;
      } else {
        // Revert to original
        preferences.value = currentPrefs;
        CustomSnackbar.showError(
          title: 'Update Failed',
          message: 'Unable to update notification settings. Please retry.',
        );
      }
    } finally {
      isUpdatingPreference.value = false;
    }
  }
}
