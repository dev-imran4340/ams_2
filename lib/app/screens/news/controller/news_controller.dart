import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../api/app_preferences.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_routes.dart';
import '../model/news_model.dart';
import '../repo/news_repo.dart';

class NewsController extends GetxController {
  final NewsRepo repo;

  NewsController({required this.repo});

  // State Observables
  final RxInt selectedTabIndex = 0.obs; // 0: Announcements, 1: Events, 2: Milestones
  final RxBool isDetailsLoading = false.obs;
  final RxBool isUpdatingPrivacy = false.obs;

  // Tab-Specific Dedicated Loaders
  final RxBool isLoadingAnnouncements = false.obs;
  final RxBool isLoadingEvents = false.obs;
  final RxBool isLoadingMilestones = false.obs;

  // Combined convenience loader getter
  bool get isLoading =>
      isLoadingAnnouncements.value ||
      isLoadingEvents.value ||
      isLoadingMilestones.value;

  // Cached Loaded Flags (avoid redundant network calls when switching tabs)
  bool _hasLoadedAnnouncements = false;
  bool _hasLoadedEvents = false;
  bool _hasLoadedMilestones = false;

  // Announcements Observables
  final RxList<AnnouncementItemModel> announcements = <AnnouncementItemModel>[].obs;
  final RxInt unreadAnnouncementsCount = 0.obs;
  final Rxn<AnnouncementItemModel> selectedAnnouncement = Rxn<AnnouncementItemModel>();

  // Events Observables & Date Filtering
  final RxList<CompanyEventItemModel> events = <CompanyEventItemModel>[].obs;
  final RxString eventFromDate = ''.obs;
  final RxString eventToDate = ''.obs;
  final RxString activeEventRangeLabel = 'Next 60 Days (Default)'.obs;
  final RxBool hasCustomEventDateFilter = false.obs;

  // Milestones Observables
  final RxList<ColleagueMilestoneItemModel> milestones = <ColleagueMilestoneItemModel>[].obs;

  // Birthday Sharing Privacy: Defaults to false if unset; respects stored/server value
  final RxBool isBirthdayShared = AppPreferences.birthdaySharing.obs;

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
    isBirthdayShared.value = AppPreferences.birthdaySharing;
    loadActiveTab();
  }

  void _handleArguments() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['initialTab'] is int) {
        selectedTabIndex.value = args['initialTab'] as int;
      }
      if (args['announcementId'] is String) {
        final openId = args['announcementId'] as String;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openAnnouncementDetails(openId);
        });
      }
    }
  }

  /// Triggers API call specific to the currently selected tab
  Future<void> loadActiveTab({bool isRefresh = false}) async {
    switch (selectedTabIndex.value) {
      case 0:
        await loadAnnouncements(isRefresh: isRefresh);
        break;
      case 1:
        await loadEvents(isRefresh: isRefresh);
        break;
      case 2:
        await loadMilestones(isRefresh: isRefresh);
        break;
    }
  }

  /// Convenience fallback for root refresh/retry
  Future<void> loadAll({bool isRefresh = false}) async {
    await loadActiveTab(isRefresh: isRefresh);
  }

  /// Switches active view tab and loads its API on-demand
  void switchTab(int index) {
    if (selectedTabIndex.value == index) return;
    HapticFeedback.selectionClick();
    selectedTabIndex.value = index;
    loadActiveTab();
  }

  /// Tab 0: Loads published announcements
  Future<void> loadAnnouncements({bool isRefresh = false}) async {
    if (!isRefresh && _hasLoadedAnnouncements && announcements.isNotEmpty) {
      return;
    }

    try {
      isLoadingAnnouncements.value = true;
      final result = await repo.fetchAnnouncements();
      announcements.assignAll(result.announcements);
      unreadAnnouncementsCount.value = result.unreadCount;
      _hasLoadedAnnouncements = true;
    } finally {
      isLoadingAnnouncements.value = false;
    }
  }

  /// Tab 1: Loads upcoming company events with optional date filtering
  Future<void> loadEvents({bool isRefresh = false}) async {
    if (!isRefresh && _hasLoadedEvents && events.isNotEmpty) {
      return;
    }

    try {
      isLoadingEvents.value = true;
      final result = await repo.fetchEvents(
        from: eventFromDate.value.isNotEmpty ? eventFromDate.value : null,
        to: eventToDate.value.isNotEmpty ? eventToDate.value : null,
      );
      events.assignAll(result);
      _hasLoadedEvents = true;
    } finally {
      isLoadingEvents.value = false;
    }
  }

  /// Sets custom or preset date filter for company events and reloads
  Future<void> setEventDateFilter(
    DateTime from,
    DateTime to, {
    String? label,
  }) async {
    final fromStr = _formatDate(from);
    final toStr = _formatDate(to);

    eventFromDate.value = fromStr;
    eventToDate.value = toStr;
    hasCustomEventDateFilter.value = true;
    activeEventRangeLabel.value = label ?? '$fromStr - $toStr';

    _hasLoadedEvents = false;
    await loadEvents(isRefresh: true);
  }

  /// Resets event date filter to server default (from today to 60 days ahead)
  Future<void> resetEventDateFilter() async {
    eventFromDate.value = '';
    eventToDate.value = '';
    hasCustomEventDateFilter.value = false;
    activeEventRangeLabel.value = 'Next 60 Days (Default)';

    _hasLoadedEvents = false;
    await loadEvents(isRefresh: true);
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Tab 2: Loads colleague birthdays and work anniversaries
  Future<void> loadMilestones({bool isRefresh = false}) async {
    if (!isRefresh && _hasLoadedMilestones && milestones.isNotEmpty) {
      return;
    }

    try {
      isLoadingMilestones.value = true;
      final result = await repo.fetchMilestones();
      milestones.assignAll(result);
      _hasLoadedMilestones = true;
    } finally {
      isLoadingMilestones.value = false;
    }
  }

  /// Loads full announcement details and updates local read status
  Future<void> loadAnnouncementDetails(String id) async {
    try {
      isDetailsLoading.value = true;
      final details = await repo.fetchAnnouncementDetails(id);
      if (details != null) {
        selectedAnnouncement.value = details;

        // Mark local announcement item as read
        final idx = announcements.indexWhere((a) => a.id == id);
        if (idx != -1 && !announcements[idx].read) {
          announcements[idx] = announcements[idx].copyWith(read: true);
          if (unreadAnnouncementsCount.value > 0) {
            unreadAnnouncementsCount.value--;
          }
        }
      }
    } finally {
      isDetailsLoading.value = false;
    }
  }

  /// Navigates to Announcement Details screen adhering to View -> Controller policy
  void openAnnouncementDetails(String id) {
    HapticFeedback.lightImpact();
    loadAnnouncementDetails(id);
    Get.toNamed(
      Routes.ANNOUNCEMENT_DETAILS,
      arguments: {'announcementId': id},
    );
  }

  /// Toggles user's birthday sharing preference (PUT /me/birthday-sharing)
  Future<void> toggleBirthdaySharing(bool value) async {
    if (isUpdatingPrivacy.value) return;

    try {
      isUpdatingPrivacy.value = true;
      HapticFeedback.mediumImpact();
      final updated = await repo.updateBirthdaySharing(value);
      if (updated != null) {
        isBirthdayShared.value = updated;
        await AppPreferences.setBirthdaySharing(updated);
        CustomSnackbar.showSuccess(
          title: 'Privacy Updated',
          message: updated
              ? 'Your birthday will now appear in colleague milestones.'
              : 'Your birthday is now hidden from colleague milestones.',
        );
      }
    } finally {
      isUpdatingPrivacy.value = false;
    }
  }

  @override
  void onClose() {
    announcements.clear();
    events.clear();
    milestones.clear();
    selectedAnnouncement.value = null;
    super.onClose();
  }
}
