import 'package:flutter/material.dart';

/// Represents an operational module option in Organization Mode
class OrgModeOption {
  final String id;
  final String title;
  final String badge;
  final String description;
  final IconData icon;
  final Color? badgeColor;
  final String? route;

  const OrgModeOption({
    required this.id,
    required this.title,
    required this.badge,
    required this.description,
    required this.icon,
    this.badgeColor,
    this.route,
  });

  factory OrgModeOption.fromJson(Map<String, dynamic> json) {
    return OrgModeOption(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: _resolveIcon(json['id']?.toString()),
      route: json['route']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'badge': badge,
      'description': description,
      'route': route,
    };
  }

  static IconData _resolveIcon(String? id) {
    switch (id) {
      case 'visitor':
        return Icons.badge_rounded;
      case 'employee':
        return Icons.co_present_rounded;
      case 'add_employee':
        return Icons.person_add_alt_1_rounded;
      default:
        return Icons.domain_rounded;
    }
  }
}
