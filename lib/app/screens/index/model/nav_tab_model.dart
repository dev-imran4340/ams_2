import 'package:flutter/material.dart';

typedef NavWidgetBuilder = Widget Function();

/// Dynamic Bottom Navigation Tab Model
/// Encapsulates screen constructor, visual icons/labels, and permission/module invariants.
class DynamicNavTab {
  final String id;
  final String label;
  final IconData icon;
  final NavWidgetBuilder builder;
  final String requiredModule;
  final String? requiredPermission;
  final String? permissionScope;
  final bool Function()? hasBadge;
  final int Function()? badgeCount;

  const DynamicNavTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.builder,
    required this.requiredModule,
    this.requiredPermission,
    this.permissionScope,
    this.hasBadge,
    this.badgeCount,
  });

  Widget buildWidget() => builder();
}
