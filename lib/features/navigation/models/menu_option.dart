import 'package:flutter/material.dart';

class MenuOption {
  final String id;
  final String title;
  final String route;
  final String iconName;
  final int order;

  MenuOption({
    required this.id,
    required this.title,
    required this.route,
    required this.iconName,
    required this.order,
  });

  factory MenuOption.fromMap(Map<String, dynamic> map, String id) {
    return MenuOption(
      id: id,
      title: map['title'] ?? '',
      route: map['route'] ?? '',
      iconName: map['icon'] ?? 'help_outline',
      order: map['order']?.toInt() ?? 0,
    );
  }

  IconData get iconData {
    switch (iconName) {
      case 'home_rounded':
        return Icons.home_rounded;
      case 'people_alt_outlined':
        return Icons.people_alt_outlined;
      case 'hub_outlined':
        return Icons.hub_outlined;
      case 'diversity_3_rounded':
        return Icons.diversity_3_rounded;
      case 'groups_rounded':
        return Icons.groups_rounded;
      case 'person_outline':
        return Icons.person_outline;
      case 'settings_outlined':
        return Icons.settings_outlined;
      // Add more icon mappings as needed for your application
      default:
        // Attempt a basic mapping check, fallback to help_outline
        if (iconName.contains('home')) return Icons.home;
        if (iconName.contains('person') || iconName.contains('user')) {
          return Icons.person;
        }
        if (iconName.contains('group') || iconName.contains('people')) {
          return Icons.groups_rounded;
        }
        return Icons.help_outline;
    }
  }
}
