import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peoplesync/core/constants/app_strings.dart';
import 'package:peoplesync/routes/app_routes.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final List<_NavItem> _items = const [
    _NavItem(Icons.home, AppStrings.home, AppRoutes.home),
    _NavItem(Icons.person, AppStrings.profile, AppRoutes.profile),
    // Future items can be added here
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.profile)) {
      return 1;
    }
    return 0; // Default to home
  }

  void _onItemTapped(int index) {
    if (index != _calculateSelectedIndex(context)) {
      context.go(_items[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      currentIndex: _calculateSelectedIndex(context),
      onTap: _onItemTapped,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurfaceVariant,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      elevation: 8,
      items: _items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.label, this.route);
}
