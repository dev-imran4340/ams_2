import 'package:flutter/material.dart';

import '../../../../api/exception_handler.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../model/org_mode_model.dart';

class OrgModeRepo {
  final String _tag = 'OrgModeRepo / OrgModeSelectionScreen';

  /// Fetches operational mode modules with simulated 300ms network delay
  Future<List<OrgModeOption>> getModeOptions() async {
    try {
      // 300ms simulated network latency for UI & Prototyping Phase
      await Future.delayed(const Duration(milliseconds: 300));

      final List<OrgModeOption> options = [
        const OrgModeOption(
          id: 'visitor',
          title: 'Visitor Management',
          badge: 'Reception & Security',
          description:
              'Manage guest check-ins with selfie capture, digital badges, and face-verified checkout.',
          icon: Icons.badge_rounded,
          badgeColor: AppColors.secondary,
          route: Routes.VISITOR_MANAGEMENT,
        ),
        const OrgModeOption(
          id: 'employee',
          title: 'Employee',
          badge: 'Company Dashboard',
          description:
              'Open company dashboard, view attendance roster, and scan employee QR.',
          icon: Icons.badge_rounded,
          badgeColor: AppColors.secondary,
          route: Routes.COMPANY_DASHBOARD,
        ),
        const OrgModeOption(
          id: 'add_employee',
          title: 'Add New Employee',
          badge: 'HR Administration',
          description:
              'Register new staff members, assign shift timings, and enroll biometric profile.',
          icon: Icons.person_add_alt_1_rounded,
          badgeColor: AppColors.warning,
          route: Routes.ADD_EMPLOYEE,
        ),
      ];

      return options;
    } catch (e, stackTrace) {
      ExceptionHandler.handle(
        ApiException(
          message: 'Failed to retrieve organization mode options: $e',
        ),
        tag:
            '$_tag -> getModeOptions() [${stackTrace.toString().split('\n').first}]',
      );
      return [];
    }
  }
}
