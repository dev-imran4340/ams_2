import 'package:flutter/material.dart';

/// Global navigator observer that automatically scrolls screens to top
/// whenever navigating to any screen across the entire app.
class AutoScrollNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _attemptScrollToTop(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _attemptScrollToTop(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _attemptScrollToTop(newRoute);
    }
  }

  void _attemptScrollToTop(Route<dynamic> route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final context = route.navigator?.context;
        if (context == null) return;

        // Try primary scroll controller
        final primary = PrimaryScrollController.maybeOf(context);
        if (primary != null && primary.hasClients) {
          primary.animateTo(
            0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
          return;
        }

        // Try searching any active Scrollable in route context
        Scrollable.maybeOf(context)?.position.animateTo(
              0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            );
      } catch (_) {}
    });
  }
}
