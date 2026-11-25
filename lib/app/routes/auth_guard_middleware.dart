import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/app_preferences.dart';
import 'app_routes.dart';

/// Navigation Guard enforcing authentication, module subscriptions, and permissions
/// against unauthorized direct route access and deep links.
class AuthGuardMiddleware extends GetMiddleware {
  final String? requiredModule;
  final String? requiredPermission;
  final String? requiredScope;

  AuthGuardMiddleware({
    this.requiredModule,
    this.requiredPermission,
    this.requiredScope,
    int? priority,
  }) : super(priority: priority ?? 1);

  @override
  RouteSettings? redirect(String? route) {
    // 0. Allow Kiosk hardware tablet routes when tablet is provisioned in Kiosk Mode
    if (AppPreferences.isKioskProvisioned &&
        (route == Routes.QR_SCANNER || route == Routes.FACE_RECOGNITION)) {
      return null;
    }

    // 1. Session verification: user must hold a valid auth token and logged-in state
    final bool hasToken = AppPreferences.token != null && AppPreferences.token!.trim().isNotEmpty;
    final bool isLoggedIn = AppPreferences.isLoggedIn;

    if (!hasToken || !isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    // 2. Determine appropriate authorized home fallback based on identity mode
    final String fallbackRoute =
        AppPreferences.isCompanyMode ? Routes.COMPANY_DASHBOARD : Routes.INDEX;

    // Root route or direct home entry: redirect according to identity
    if (route == '/' || route == null) {
      return RouteSettings(name: fallbackRoute);
    }

    // Destination is already the authorized fallback home: proceed without redirect
    if (route == fallbackRoute) {
      return null;
    }

    // Role/Account separation: Company accounts cannot access employee index directly
    if (route == Routes.INDEX && AppPreferences.isCompanyMode) {
      return const RouteSettings(name: Routes.COMPANY_DASHBOARD);
    }

    // Employee accounts cannot access company dashboard
    if (route == Routes.COMPANY_DASHBOARD && !AppPreferences.isCompanyMode) {
      return const RouteSettings(name: Routes.INDEX);
    }

    // 3. Module verification: check company paid module subscription
    if (requiredModule != null && requiredModule != 'core') {
      if (!AppPreferences.hasModule(requiredModule!)) {
        return RouteSettings(name: fallbackRoute);
      }
    }

    // 4. Permission verification: check server-granted permission and scope
    if (requiredPermission != null) {
      if (!AppPreferences.hasPermission(requiredPermission!, requiredScope)) {
        return RouteSettings(name: fallbackRoute);
      }
    }

    return null; // Route authorized
  }
}
